-- 引入redis的客户端
local redis=require "resty.redis"

-- 获取客户端的ip地址
--ngx.req.get_headers()
local_ip = ngx.var.remote_addr
ngx.log(ngx.ERR,'IP-----',local_ip)

--记录日志
if local_ip == nil then
    ngx.log(ngx.ERR,'IP-----',local_ip)
end

ngx.log(ngx.ERR,'IP-----',local_ip)
--连接redis,查询当前ip,是否再redis当中
local cache=redis.new()
local ok,err = cache.connect(cache,'127.0.0.1',6379)
if not ok then
  --ngx.log(ngx.ERR,'连接失败',local_ip)
  return
end

local allow_ip=cache:get(local_ip)

if allow_ip == local_ip then
  ngx.exec("@client2")
  return
end

ngx.exec("@client1")
cache:close()

--ngx.header.content_type="text/plain"
--ngx.say(local_ip);


--[[


]]