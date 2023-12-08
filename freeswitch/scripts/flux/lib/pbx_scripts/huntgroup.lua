

freeswitch.consoleLog("notice", "Modulo de HuntGroup\n")

-- Verifica estado da sessao
if not session:ready() then
	return
end

-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/pbx_scripts'
dofile(script_dir..'/db.lua')
dbh=db_read()

destination_number = session:getVariable("destination_number")
local req_name=string.sub(destination_number,4)
local req_domain=session:getVariable("domain_name")
freeswitch.consoleLog("notice", "Modulo de HuntGroup name="..req_name.." domain="..req_domain.."\n")

local my_query = string.format("select grouplist,method,timeout from huntgroup where name='%s' and domain='%s' limit 1", req_name,req_domain)
dbh:query(my_query, function(row)
        hg=row
        freeswitch.consoleLog("notice", "HG  "..hg.grouplist.." encontrado\n")
end)

session:setAutoHangup(false)
if (hg.method)=="paralell"  then 
	separator=","
else 
	separator="|" 
end

local t={}
local i=1
for token in string.gmatch(hg.grouplist, "[^;]+") do
	t[i]=token
	if (i==1) then
		--dialstring="${sofia_contact("..t[i].."@"..req_domain..")}"
		dialstring="<domain_name="..req_domain..">[call_timeout="..hg.timeout.."]Loopback/"..t[i].."/default"
	else 
		--dialstring=dialstring..separator.."${sofia_contact("..t[i].."@"..req_domain..")}"
		dialstring=dialstring..separator.."[call_timeout="..hg.timeout.."]Loopback/"..t[i].."/default"
	end
	i=i+1
end
--session:execute("export","nolocal:ringback=$${us-ring}")

session:setVariable("dialstring",dialstring)
freeswitch.consoleLog("notice", "DialString="..dialstring.."\n")

