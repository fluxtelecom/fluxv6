-- FLUXUPDATE-1170  start
local ringgroup = "/usr/local/freeswitch/scripts/flux/lib/addons/flux.ringgroup.lua"
local f=io.open(ringgroup,"r")
if f~=nil then
    dofile("/usr/local/freeswitch/scripts/flux/lib/addons/flux.ringgroup.lua")
    return true 
else
    return false
end

local siprouting = "/usr/local/freeswitch/scripts/flux/lib/addons/sip_routing.lua"
local f=io.open(siprouting,"r")
if f~=nil then
    dofile("/usr/local/freeswitch/scripts/flux/lib/addons/sip_routing.lua")
    return true 
else
    return false
end
-- FLUXUPDATE-1170  End