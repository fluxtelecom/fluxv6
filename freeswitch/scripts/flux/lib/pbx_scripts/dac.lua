
 
freeswitch.consoleLog("notice", "Modulo Distribuicao Automatica de Chamadas\n")

-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/lib/pbx_scripts'

dofile(script_dir..'/db.lua')
dbh=db_read()

destination_number = string.sub(session:getVariable("destination_number"),4)
domain=session:getVariable("domain_name")
uuid=session:getVariable("uuid")
queue_name=destination_number..'@'..domain

-- Busca dados da Fila no banco de dados   
local my_query = string.format("select ring_timeout, destiny , destiny_action from ms_queue where name='%s' and domain='%s'", destination_number, domain)
dbh:query(my_query, function(row)
	queue=row
end)

if not queue then
	return
end

-- Habilita transferencia de chamadas pelo agente
session:execute("bind_meta_app","2 b s execute_extension::att_xfer XML features")
session:execute("bind_meta_app","3 b s execute_extension::dx XML features")
api = freeswitch.API();
--luarun = api:execute("luarun", "queue_position.lua $2 ${domain_name} ${uuid}")
luarun = api:execute("luarun", "queue_position.lua "..destination_number.." "..domain.." "..uuid)
session:setVariable("leg_timeout",queue.ring_timeout)
session:setVariable("cc_export_vars","leg_timeout")
session:setVariable("continue_on_fail","yes")

session:execute("callcenter",queue_name)
cc_status=api:execute("uuid_getvar", uuid.." cc_cancel_reason")
freeswitch.consoleLog("notice", "Queue Call Ended "..cc_status.."\n")

if queue.destiny_action ~= nil and  queue.destiny_action ~= "" and queue.destiny_action ~= "HANGUP" and cc_status == "TIMEOUT" then
	if queue.destiny_action=="USER" then
		dst_data=queue.destiny
	elseif queue.destiny_action=="HUNTGROUP" then
		dst_data="*65"..queue.destiny
	elseif queue.destiny_action=="TIMEROUTING" then
		dst_data="*64"..queue.destiny
	elseif queue.destiny_action=="CONFERENCE" then
		dst_data="*63"..queue.destiny
	elseif queue.destiny_action=="QUEUE" then
		dst_data="*61"..queue.destiny
	end
	session:transfer(dst_data, "XML", "default")
end
