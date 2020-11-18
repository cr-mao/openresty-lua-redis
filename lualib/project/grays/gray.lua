-- 引入redis的客户端
local tool=require "tool"

local_ip =tool.getIP()
local allow_ip=tool:allowIP("test")
if allow_ip == local_ip then
  ngx.exec("@client2")
  return
end
ngx.exec("@client1")
