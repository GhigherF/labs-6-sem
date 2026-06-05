package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math"
	"net/http"
	"sync"

	"github.com/gorilla/mux"
)

var (
	mu        sync.Mutex
	precision = 0
	methods   = map[string]func(RPCRequest) RPCResponse{}
)

type RPCRequest struct {
	Jsonrpc string          `json:"jsonrpc"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params"`
	ID      interface{}     `json:"id"`
}

type RPCResponse struct {
	Jsonrpc string      `json:"jsonrpc"`
	Result  interface{} `json:"result,omitempty"`
	Error   interface{} `json:"error,omitempty"`
	ID      interface{} `json:"id"`
}

type SumArgs struct{ X, Y float64 }
type SumResult struct{ Value float64 }
type SubArgs struct{ X, Y float64 }
type SubResult struct{ Value float64 }
type MulArgs struct{ X, Y float64 }
type MulResult struct{ Value float64 }
type DivArgs struct{ X, Y float64 }
type DivResult struct{ Value float64 }
type PreArgs struct{ N int }
type PreResult struct{ Status string }

func round(v float64) float64 {
	mu.Lock()
	p := precision
	mu.Unlock()
	f := math.Pow(10, float64(p))
	return math.Floor(v*f) / f
}
func extractparams(raw json.RawMessage, dst interface{}) error {
	if len(raw) == 0 {
		return fmt.Errorf("empty params")
	}

	if raw[0] == '{' {
		return json.Unmarshal(raw, dst)
	}

	if raw[0] == '[' {
		var arr []float64
		if err := json.Unmarshal(raw, &arr); err != nil {
			return err
		}

		obj := map[string]float64{}
		if len(arr) > 0 {
			obj["x"] = arr[0]
		}
		if len(arr) > 1 {
			obj["y"] = arr[1]
		}

		b, _ := json.Marshal(obj)
		return json.Unmarshal(b, dst)
	}

	return fmt.Errorf("unsupported params format")
}

func register(name string, fn func(RPCRequest) RPCResponse) {
	methods[name] = fn
}

func CallMethod(r RPCRequest) RPCResponse {
	var rc RPCResponse
	if method := methods[r.Method]; method != nil {
		rc = method(r)
	} else {
		rc = RPCResponse{
			Jsonrpc: "2.0",
			Error:   fmt.Errorf("Method not found"),
			ID:      r.ID,
		}
	}
	return rc
}

func rpcHandler(w http.ResponseWriter, r *http.Request) {
	var raw json.RawMessage
	if err := json.NewDecoder(r.Body).Decode(&raw); err == nil {
		if len(raw) > 0 && raw[0] == '[' {
			var reqs []RPCRequest
			json.Unmarshal(raw, &reqs)
			responses := make([]RPCResponse, 0)
			for _, req := range reqs {
				responses = append(responses, CallMethod(req))
			}
			json.NewEncoder(w).Encode(responses)
		} else {
			var rq RPCRequest
			json.Unmarshal(raw, &rq)
			if rq.ID == nil {
				CallMethod(rq)
			} else {
				json.NewEncoder(w).Encode(CallMethod(rq))
			}
		}
	} else {
		json.NewEncoder(w).Encode(RPCResponse{Jsonrpc: "2.0",
			Error: "json error"})
	}
}

func main() {
	register("sum", func(r RPCRequest) RPCResponse {
		log.Println("sum")
		var p SumArgs
		extractparams(r.Params, &p)
		return RPCResponse{"2.0", SumResult{round(p.X + p.Y)}, nil, r.ID}
	})
	register("sub", func(r RPCRequest) RPCResponse {
		log.Println("sub")
		var p SubArgs
		extractparams(r.Params, &p)
		return RPCResponse{"2.0", SubResult{round(p.X - p.Y)}, nil, r.ID}
	})
	register("mul", func(r RPCRequest) RPCResponse {
		log.Println("mul")
		var p MulArgs
		extractparams(r.Params, &p)
		return RPCResponse{"2.0", MulResult{round(p.X * p.Y)}, nil, r.ID}
	})
	register("div", func(r RPCRequest) RPCResponse {
		log.Println("div")

		var p DivArgs
		if err := extractparams(r.Params, &p); err != nil {
			return RPCResponse{
				Jsonrpc: "2.0",
				Error:   "invalid params",
				ID:      r.ID,
			}
		}

		if p.Y == 0 {
			return RPCResponse{
				Jsonrpc: "2.0",
				Error: map[string]interface{}{
					"code":    -32000,
					"message": "division by zero",
				},
				ID: r.ID,
			}
		}

		return RPCResponse{
			Jsonrpc: "2.0",
			Result:  DivResult{round(p.X / p.Y)},
			ID:      r.ID,
		}
	})
	register("pre", func(r RPCRequest) RPCResponse {
		var p PreArgs
		log.Println("pre", p)
		extractparams(r.Params, &p)
		mu.Lock()
		precision = p.N
		mu.Unlock()
		return RPCResponse{"2.0", PreResult{"Ok"}, nil, nil}
	})
	router := mux.NewRouter()
	router.HandleFunc("/rpc", rpcHandler).Methods("POST")
	log.Println("Starting server on 3000")
	http.ListenAndServe(":3000", router)
}
