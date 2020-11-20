
## 环境构建
自定义网络
```shell 
docker network create  --subnet=192.168.0.0/16  redis-network
```

openresty环境
```shell 
cd docker/nginx
docker build -t  myopenresty . 
docker-composer up -d
```

php + mysql环境
```shell 
cd docker/php
docker build -t  php-fpm-with-redis-swoole .
docker-composer up -d
```


redis集群环境构建
```shell 
cd docker/redis
docker build -t redis5 .
docker-composer up -d
docker exec -it cluster-1 /bin/sh
redis-cli --cluster create 192.168.1.2:6420 192.168.1.3:6421 192.168.1.4:6422 192.168.1.5:6423 192.168.1.6:6424 192.168.1.7:6425 --cluster-replicas 1
```