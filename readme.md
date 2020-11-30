## openresty+lua+redis 


 - 应用openresty+lua 通用http服务网关解决方案
 
 - 深入应用redis使用场景



### 环境构建
采用docker构建环境

#### 1.自定义网络
```shell 
docker network create  --subnet=192.168.0.0/16  redis-network
```

#### 2.openresty环境
```shell 
cd docker/nginx
docker build -t  myopenresty . 
docker-compose up -d
```

#### 3.php + mysql环境
```shell 
cd docker/php
docker build -t  php-fpm-with-redis-swoole .
docker-compose up -d
```


#### 4.redis集群环境
```shell 
cd docker/redis
docker build -t redis5 .
docker-compose up -d
docker exec -it cluster-1 /bin/sh
redis-cli --cluster create 192.168.1.2:6420 192.168.1.3:6421 192.168.1.4:6422 192.168.1.5:6423 192.168.1.6:6424 192.168.1.7:6425 --cluster-replicas 1
```

redis  集群测试
```shell  
redis-cli  -h 192.168.1.2 -p 6420 -c
```


### 文档

[01-openresty使用动态负载均衡](01-openresty使用动态负载均衡.md)

[02-lua连接redis集群](02-lua连接redis集群.md)

[03缓存.md](03-缓存击穿.md)

[04布隆过滤器.md](04-缓存穿透.md)