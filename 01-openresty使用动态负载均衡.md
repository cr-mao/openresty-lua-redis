启动consul
```shell   
docker run -d  --net redis-network --ip 192.168.1.20 -p 8700:8500 -h node1 --name openresty-redis-consul  consul1.4  ./consul  agent -server -bootstrap-expect=1  -data-dir /tmp/consul -node=node1 -bind=192.168.1.20 -client 0.0.0.0  -ui
```

注册 2台 应用层 nginx
```shell  
curl -X PUT -d '{"weight":1,"max_fails":2,"fail_timeout":10}' http://127.0.0.1:8700/v1/kv/upstreams/servers/192.168.1.9:80
curl -X PUT -d '{"weight":1,"max_fails":2,"fail_timeout":10}' http://127.0.0.1:8700/v1/kv/upstreams/servers/192.168.1.10:80
```

分发层

```
    upstream upstream_server {
        hash $key; #商品id
        server 192.168.1.9:80 max_fails=3 fail_timeout=5s;
        upsync 192.168.1.20:8500/v1/kv/upstreams/servers upsync_timeout=20s upsync_interval=60s upsync_type=consul strong_dependency=off;
        upsync_dump_path /usr/local/openresty/nginx/conf/servers.conf;
        include /usr/local/openresty/nginx/conf/servers.conf;
    }
```