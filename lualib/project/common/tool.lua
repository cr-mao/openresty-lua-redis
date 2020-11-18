tool= {default_ip="127.0.0.1",default_port=6379}
local redis=require "resty.redis"
tool.default_ip="127.0.0.1"
tool.default_port=6379

-- :跟.最大的区别是使用冒号调用或者定义会自动传递self
--判断ip是否存在
function tool:allowIP(key)
   local cache=redis.new()
   local ok,err = cache:connect(self.default_ip,self.default_port)
   if not ok then
     ngx.log(ngx.ERR,'连接失败')
     return
   end
   return cache:get(key)
end
function tool.getIP()
  --从请求头当中获取
  local_ip = ngx.var.remote_addr
  return local_ip
end

return tool