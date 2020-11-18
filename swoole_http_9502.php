<?php

$http = new Swoole\Http\Server("0.0.0.0", 9502);

$http->on("start", function ($server) {
    echo "Swoole http server is started at http://127.0.0.1:9502\n";
});
$http->on("request", function ($request, $response) {
    $response->header("Content-Type", "text/plain");
    $response->end("9502 Hello World\n");
});

$http->start();
