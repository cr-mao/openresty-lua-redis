---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by mac.
--- DateTime: 2020/11/22 下午7:50
---



local rety_lock = require "resty.lock"
local cache = ngx.shared.my_cache
local key = ngx.re.match(ngx.var.request_uri, "/([0-9]+).html")
if type(key) == "table" then

    ---- 1 先从本地内存获取
    --    --ngx.say(key[1])
    ngx.log(ngx.ERR, key[1])
    local res, err = cache:get(key[1])
    if res then
        ngx.say("val", res)
    end
    -- 2 去后端源服务器获取，只允许一个请求到后端获取，并且更新缓存，加锁
    local lock, err = rety_lock:new("my_locks", { exptime = 10, timeout = 3 })
    if not lock then
        ngx.log(ngx.ERR, "创建锁失败")
    end

    local flag_lock, err = lock:lock(key[1])
    if err then
        ngx.log(ngx.ERR, "获取锁失败占用")
    end

    if not flag_lock then
        local res = cache:get_stale(key[1])
        return res
    end

    -- 锁成功获取,可能已经有人将值放入缓存中了
    local res, err = cache:get(key[1])
    if res then
        lock:unlock()
        return res
    end

    local req_data
    local method = ngx.var.request.method

    if method == "POST" then
        req_data = { method = ngx.HTTP_POST, body = ngx.req.read_body() }
    elseif method == "PUT" then
        req_data = { method = ngx.HTTP_PUT, body = ngx.req.read_body() }
    else
        req_data = { method = ngx.GET }
    end
    --local uri
    --if not ngx.var.request.uri then
    --    uri = ""
    --end

    -- 再去请求源服务器
    local res, err = ngx.location.capture(
            '/index.php' ,
            req_data
    )
    if res.status == 200 then
        ngx.say(res.body)
    end
    lock:unlock()
end


