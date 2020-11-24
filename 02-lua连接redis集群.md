
## lua连接redis集群

### 使用resty-redis-cluster  操作redis集群
https://github.com/steve0511/resty-redis-cluster 
老版本 

使用见 ./project/code/nginx/application/common/resty-redis-cluster-master
README.md

so文件需要手动make 


### 应用层 nginx 相应配置
```nginx 
worker_processes  1;
daemon off; # 避免nginx在后台运行
events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    lua_code_cache off; #关闭代码缓存
    sendfile        on;
    keepalive_timeout  65;
    lua_shared_dict redis_cluster_slot_locks 100k;
    lua_package_path "/usr/local/openresty/lualib/project/common/lualib/?.lua;;/usr/local/openresty/lualib/project/common/resty-redis-cluster/lib/?.lua;;";
    # 加载c动态库
    lua_package_cpath "/usr/local/openresty/lualib/project/common/resty-redis-cluster/src/?.so;;";

    server {
        listen       80;
        location /{
           content_by_lua_file /usr/local/openresty/lualib/project//application.lua;
           #index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

         location  ~ \.php/?.*  {
            root           /var/www;  #php-fpm容器当中的路径，不是nginx路径
            fastcgi_index  index.php;
            fastcgi_pass    192.168.1.11:9000; #php容器端口
            #为php-fpm指定的根目录
            fastcgi_param  SCRIPT_FILENAME  $DOCUMENT_ROOT$fastcgi_script_name;
            #定义变量 $path_info ，用于存放pathinfo信息
            set $path_info "";
            if ($fastcgi_script_name ~ "^(.+?\.php)(/.+)$") {
                    #将文件地址赋值给变量 $real_script_name
                    set $real_script_name $1;
                        #将文件地址后的参数赋值给变量 $path_info
                    set $path_info $2;
                }
                 #配置fastcgi的一些参数
                fastcgi_param SCRIPT_NAME $real_script_name;
                fastcgi_param PATH_INFO $path_info;
                include       /usr/local/openresty/nginx/conf/fastcgi_params;
        }
    }

```


### lua 连接redis 集群
```lua 
local config = {
    name = "testCluster",                   --rediscluster name
    serv_list = {                           --redis cluster node list(host and port),
        { ip = "192.168.1.2 ",port = 6420 },
        { ip = "192.168.1.3", port = 6421 },
        { ip = "192.168.1.4", port = 6422 },
        { ip = "192.168.1.5", port = 6423 },
        { ip = "192.168.1.6", port = 6424 },
        { ip = "192.168.1.7", port = 6425 }
    },
    keepalive_timeout = 60000,              --redis connection pool idle timeout
    keepalive_cons = 1000,                  --redis connection pool size
    connect_timeout = 1000,              --timeout while connecting
    max_redirection = 5,                    --maximum retry attempts for redirection
    max_connection_attempts = 1,            --maximum retry attempts for connection
                                            -- auth="password"
}

local redis_cluster = require "rediscluster"
local red_c = redis_cluster:new(config)

local v, err = red_c:get("name")
if err then
    ngx.log(ngx.ERR, "err: ", err)
else
    ngx.say(v)
end

```




####   opm 下载 操作consul的组件

OpenResty 维护一个官方组件库（opm.openresty.org）,opm就是库的客户端，可以把组件库里的组件下载到本地，并管理本地的组件列表。


opm 默认的操作目录是 “/usr/local/openresty/site”，但是也可以在命令行参数 “--install-dir=PATH” 安装到其他目录，或者用参数 “–cwd” 安装到当前目录的
"./resty_module/" 目录里。

注意：要使用opm 可能还缺少一个依赖 

```shell
 # ln -s `pwd`/opm  /usr/local/bin/opm

yum install perl-Digest-MD5 -y
opm search consul 
# 安装操作consul组件
opm --install-dir=/usr/local/openresty/lualib/project/common get  hamishforbes/lua-resty-consul

```



####  redis 节点注册到consul

```shell
curl -X PUT -d '192.168.1.2:6420' http://127.0.0.1:8700/v1/kv/redis-cluster-1/
curl -X PUT -d '192.168.1.3:6421' http://127.0.0.1:8700/v1/kv/redis-cluster-2/
curl -X PUT -d '192.168.1.4:6422' http://127.0.0.1:8700/v1/kv/redis-cluster-3/
curl -X PUT -d '192.168.1.5:6423' http://127.0.0.1:8700/v1/kv/redis-cluster-4/
curl -X PUT -d '192.168.1.6:6424' http://127.0.0.1:8700/v1/kv/redis-cluster-5/
curl -X PUT -d '192.168.1.7:6425' http://127.0.0.1:8700/v1/kv/redis-cluster-6/
```





 
 #### 从consul中获得redis节点地址，放到共享lua_shared_dict.redis_cluster_addr中


**lua-nginx-module 核心的api地址**
 [https://github.com/openresty/lua-nginx-module](https://github.com/openresty/lua-nginx-module)


 `syntax：lua_shared_dict <name> <size>`
 
 声明一个共享内存区域 name，以充当基于 Lua 字典 ngx.shared. 的共享存储。 
 共享内存总是被当前 Nginx 服务器实例中所有的 Nginx worker 进程所共享。
 
 
nginx增加

```nginx 
    # 集群地址 内存共享
    lua_shared_dict  redis_cluster_addr 20k;
    # work进程启动， 从consul中获得redis 节点地址，放到 共享 lua_shared_dict redis_cluster_addr中
    init_worker_by_lua_file /usr/local/openresty/lualib/project/init.lua;
```
代码见
```shell 
./project/code/nginx/application/init.lua
./project/code/nginx/application/application.lua
```
