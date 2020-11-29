--进程启动触发
--
local delay = 50
local handler
handler = function (premature)
    local resty_consul = require('resty.consul')
    local consul = resty_consul:new({
        host            = "192.168.1.20",
        port            = 8500,
        connect_timeout = (60*1000), -- 60s
        read_timeout    = (60*1000), -- 60s
    })
    local res, err = consul:list_keys("redis-cluster") -- Get all keys
    if not res then
        ngx.log(ngx.ERR, err)
        return
    end

    local keys = {}
    if res.status == 200 then
        keys = res.body
    end

    local ip_addr='';
    --分隔函数
    --local ngx_re_split=require("ngx.re").split
    for key, value in ipairs(keys) do
        local res, err = consul:get_key(value) --获取value值
        if not res then
            ngx.log(ngx.ERR, err)
            return
        end
        -- 如果时最后一个就不拼接,号分隔
        if table.getn(keys) == key then
            ip_addr=ip_addr..res.body[1].Value
        else
            ip_addr=ip_addr..res.body[1].Value..','
        end
    end
    ngx.log(ngx.ERR, "redis cluster ip addr: ", ip_addr)
    -- 将redis集群节点地址 放到共享内存中
    ngx.shared.redis_cluster_addr:set('redis-addr',ip_addr)
end

if  0 == ngx.worker.id() then
    --第一次立即执行
    local ok, err = ngx.timer.at(0, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return
    end

    --第二次定时执行
    local ok, err = ngx.timer.every(delay, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return
    end
    ngx.log(ngx.ERR,"-----进程启动")
end

