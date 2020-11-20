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