
https://github.com/steve0511/resty-redis-cluster

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