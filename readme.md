sudo openresty -c /Users/mac/code/openresty/nginx.conf




redis集群环境构建
```shell 
docker network create  --subnet=192.168.0.0/16  redis-network
cd docker/redis
docker build -t redis5 .
docker-composer up -d
docker exec -it cluster-1 /bin/sh
redis-cli --cluster create 192.168.1.2:6420 192.168.1.3:6421 192.168.1.4:6422 192.168.1.5:6423 192.168.1.6:6424 192.168.1.7:6425 --cluster-replicas 1

集群端口和服务端口差10000
```