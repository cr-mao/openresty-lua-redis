--写业务逻辑
local flag=ngx.shared.load:get("load")
local load_blance=''

--ngx.say("1111")

if tonumber(flag) == 1 then
    load_blance="upstream_server_hash"
elseif tonumber(flag) == 2 then
    load_blance="upstream_server_hash1"
else
    load_blance="upstream_server_hash1"
end

return load_blance

