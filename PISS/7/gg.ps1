$url = "http://localhost:3000/rpc"

function Call-Curl($json) {
    Write-Host ">>> $json" -ForegroundColor Yellow
    
    $response = curl.exe --globoff -s -X POST $url `
        -H "Content-Type: application/json" `
        -d $json

    Write-Host $response -ForegroundColor Green
    Write-Host ""
}

Write-Host "=== Positional params ===" -ForegroundColor Cyan

Call-Curl '{"jsonrpc":"2.0","method":"sum","params":[5.05,3.33],"id":1}'
Call-Curl '{"jsonrpc":"2.0","method":"sub","params":[5.05,3.33],"id":2}'
Call-Curl '{"jsonrpc":"2.0","method":"mul","params":[5.05,3.33],"id":3}'
Call-Curl '{"jsonrpc":"2.0","method":"div","params":[5.05,3.33],"id":4}'

Write-Host "=== Named params ===" -ForegroundColor Cyan

Call-Curl '{"jsonrpc":"2.0","method":"sum","params":{"x":5.05,"y":3.33},"id":5}'
Call-Curl '{"jsonrpc":"2.0","method":"sub","params":{"x":5.05,"y":3.33},"id":6}'
Call-Curl '{"jsonrpc":"2.0","method":"mul","params":{"x":5.05,"y":3.33},"id":7}'
Call-Curl '{"jsonrpc":"2.0","method":"div","params":{"x":5.05,"y":3.33},"id":8}'

Write-Host "=== Notification (pre) ===" -ForegroundColor Cyan
Call-Curl '{"jsonrpc":"2.0","method":"pre","params":{"N":3}}'

Write-Host "=== After precision change ===" -ForegroundColor Cyan

Call-Curl '{"jsonrpc":"2.0","method":"sum","params":[5.05,3.33],"id":9}'
Call-Curl '{"jsonrpc":"2.0","method":"sub","params":[5.05,3.33],"id":10}'
Call-Curl '{"jsonrpc":"2.0","method":"mul","params":[5.05,3.33],"id":11}'
Call-Curl '{"jsonrpc":"2.0","method":"div","params":[5.05,3.33],"id":12}'

Write-Host "=== Reset precision ===" -ForegroundColor Cyan
Call-Curl '{"jsonrpc":"2.0","method":"pre","params":{"N":1}}'

Write-Host "=== Named again ===" -ForegroundColor Cyan

Call-Curl '{"jsonrpc":"2.0","method":"sum","params":{"x":5.05,"y":3.33},"id":13}'
Call-Curl '{"jsonrpc":"2.0","method":"sub","params":{"x":5.05,"y":3.33},"id":14}'
Call-Curl '{"jsonrpc":"2.0","method":"mul","params":{"x":5.05,"y":3.33},"id":15}'
Call-Curl '{"jsonrpc":"2.0","method":"div","params":{"x":5.05,"y":3.33},"id":16}'

Write-Host "=== Batch ===" -ForegroundColor Cyan

$batch = @'
[
{"jsonrpc":"2.0","method":"pre","params":{"N":4}},
{"jsonrpc":"2.0","method":"sum","params":{"x":5.05,"y":3.33},"id":17},
{"jsonrpc":"2.0","method":"sub","params":{"x":5.05,"y":3.33},"id":18},
{"jsonrpc":"2.0","method":"mul","params":{"x":5.05,"y":3.33},"id":19},
{"jsonrpc":"2.0","method":"div","params":{"x":5.05,"y":0},"id":20}
]
'@

Call-Curl $batch
