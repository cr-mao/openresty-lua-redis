--ngx.say()
--分隔函数
local ngx_re_split=require("ngx.re").split

-- 从共享内存中获得
local ip_addr=ngx.shared.redis_cluster_addr:get('redis-addr')
local ip_addr_table=ngx_re_split(ip_addr,",")
local redis_addr={}
for key, value in ipairs(ip_addr_table) do
    local ip_addr=ngx_re_split(value,":")
    redis_addr[key]={ip=ip_addr[1],port=ip_addr[2]}
    --ngx.print(value) -- Key value after base64 decoding
end

local config = {
    name = "testCluster",                   --rediscluster name
    --[[serv_list = {                           --redis cluster node list(host and port),
        { ip = "192.168.1.2 ",port = 6420 },
        { ip = "192.168.1.3", port = 6421 },
        { ip = "192.168.1.4", port = 6422 },
        { ip = "192.168.1.5", port = 6423 },
        { ip = "192.168.1.6", port = 6424 },
        { ip = "192.168.1.7", port = 6425 }
    },
    ]]
    serv_list=redis_addr,
    keepalive_timeout = 60000,              --redis connection pool idle timeout
    keepalive_cons = 1000,                  --redis connection pool size
    connection_timout = 1000,               --timeout while connecting
    max_redirection = 5,                    --maximum retry attempts for redirection
                                             -- auth="password"

}

local redis_cluster = require "rediscluster"
local red_c = redis_cluster:new(config)
local v, err = red_c:get("cr-mao")
if err then
    ngx.log(ngx.ERR, "err: ", err)
else
    ngx.say(v)
end






