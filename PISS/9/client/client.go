package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"
)

const (
	//baseURL = "http://ghigher:password@172.25.205.97:25070/"
	baseURL    = "http://localhost:3000/webdav/"
	baseFolder = "A"
)

func request(method, url string, body io.Reader, h map[string]string) {
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		log.Println(method, "error:", err)
		return
	}
	for k, v := range h {
		req.Header.Set(k, v)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Println(method, "error:", err)
		return
	}
	defer resp.Body.Close()
	b, _ := io.ReadAll(resp.Body)
	fmt.Println("=== ", method, url, " ===")
	fmt.Println("status:", resp.Status)
	fmt.Println(string(b))
	fmt.Println()
}

func main() {
	request("MKCOL", baseURL+baseFolder+"/", nil, nil)
	request("PUT", baseURL+baseFolder+"/hello.txt",
		bytes.NewBuffer([]byte("Hello WebDav")),
		map[string]string{"Content-Type": "text/plain"})
	request("GET", baseURL+baseFolder+"/hello.txt", nil, nil)
	request("PROPFIND", baseURL+baseFolder+"/",
		bytes.NewBuffer([]byte(`<?xml version="1.0"?>
<propfind xmlns="DAV:">
<allprop/>
</propfind>`)),
		map[string]string{"Content-Type": "application/xml",
			"Depth": "1"})

	request("PROPPATCH", baseURL+baseFolder+"/hello.txt",
		bytes.NewBuffer([]byte(`<?xml version="1.0"?>
<propertyupdate xmlns="DAV:">
<set>
<prop>
<description>test</description>
</prop>
</set>
</propertyupdate>`)),
		map[string]string{"Content-type": "application/xml"})
	request("DELETE", baseURL+baseFolder+"/", nil, nil)
	request("DELETE", baseURL+baseFolder+"/", nil, nil)
	request("MKCOL", baseURL+"GG"+"/", nil, nil)

}
