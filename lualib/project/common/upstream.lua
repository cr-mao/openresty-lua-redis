local uri_args=ngx.req.get_uri_args()
local id=uri_args["id"]
if id == nil then
ngx.say("error")
return
end
--动态获取
local server={"127.0.0.1:9501","127.0.0.1:9502"}
local hash=ngx.crc32_long(id)
ngx.header.content_type="text/plain"
local index=(hash % table.getn(server))+1

--引用了http 包 https://github.com/ledgetech/lua-resty-http
local http = require "resty.http"
local httpc = http.new()
local res, err = httpc:request_uri("http://"..server[index], {
method = "GET"
})
if not res then
ngx.say("failed to request: ", err)
return
end
ngx.status = res.status

