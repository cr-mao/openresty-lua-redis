---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by mac.
--- DateTime: 2020/11/22 下午8:40
---

local key = ngx.re.match(ngx.var.request_uri, "/([0-9]+).html")
local mlcache = require "resty.mlcache"
local common = require "resty.common"

-- l3的回调


-- 6秒 会被请求一次，
local function fetch_shop(key)
    --ngx.say("into l3 ")
    --ngx.log(ngx.ERR, "请求到l3 了", key)
    -- 布隆过滤器
    --return "id=10"
    -- http://127.0.0.1:8001/111.html
    --  bf.add shop_list 111
    if (common.filter('shop_list', key) == 1) then
        local content = common.send('/index.php')
        if content == nil then
            return
        end
        return content
    end
    return ""
end

if type(key) == "table" then
    local cache, err = mlcache.new("cache_name", "my_cache", {
        lru_size = 500, -- 设置缓存的个数
        ttl = 5, -- 1级缓存过期时间
        neg_ttl = 6, -- 30s ttl for misses     l3 返回nil 的保存时间
        ipc_shm = "ipc_cache"  -- 用于将l2的缓存设置到l1
    })

    if not cache then
        ngx.log(ngx.ERR, "缓存创建失败", err)
    end
    local shop_detail, err, level = cache:get(key[1], nil, fetch_shop, key[1])

    if err then
        ngx.log(ngx.ERR, "could not retrieve shop: ", err)
        return
    end

    if level == 3 then
        ngx.say(shop_detail)
        cache:set(key[1], nil, shop_detail)
    end
    ngx.say(shop_detail)
end