

freeswitch.consoleLog("notice", "Modulo de Timerouting\n")

-- Verifica estado da sessao
if not session:ready() then
	return
end

-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/pbx_scripts'
dofile(script_dir..'/db.lua')
dbh=db_read()
dofile(script_dir..'/timepatterncheck.lua')

local timerouting=string.sub(session:getVariable("destination_number"),4)
local domain_name=session:getVariable("domain_name")

freeswitch.consoleLog("notice", "Time Routing Buscando "..timerouting.."\n")
local my_query=string.format("select daterange_items.id, daterange_items.timepattern, daterange.include_holidays, timerouting.intime_type, timerouting.offtime_type, timerouting.intime,timerouting.offtime from timerouting, daterange, daterange_items where (timerouting.name='%s' and timerouting.domain='%s' and timerouting.daterange_id=daterange.id and daterange.id=daterange_items.daterange_id)",timerouting,domain_name)

final=0
dbh:query(my_query, function(row)
	if row.include_holidays==1 and final~=1 then
		local my_query=string.format("select tipo, nome from holidays where data = curdate()")
		dbh:query(my_query, function(row1)
			freeswitch.consoleLog("notice", "Feriado "..row1.nome..". TR Final=1 \n")
			final=1
		end)

	end
	tp_result=timepatterncheck(row.timepattern)
	tr=row
	if (tp_result==1 or final==1) then
		final=1
	end
end)

freeswitch.consoleLog("notice", "Resultado da final timerouting "..final.."\n")
-- Retorna hangup com 404 numero não encontrado nao encontrei um timerouting
if not tr then
	freeswitch.consoleLog("notice", "Time Routing  "..timerouting.." nao encontrado\n")
	session:hangup(1)
	return
end

session:setAutoHangup(false)
-- Se final for 1, a chamada está dentro do horário
if final==1 then
	dst_type=tr.intime_type
	dst=tr.intime
else
	dst_type=tr.offtime_type
	dst=tr.offtime
end
-- Encaminha a chamada para o plano de discagens com o prefixo correto para cada tipo de chamada
-- Se o destino for USER, não há adição de prefixo
if dst_type == "HUNTGROUP" then
	dst="*65"..dst
elseif dst_type == "TIMEROUTING" then
	dst="*64"..dst
elseif dst_type == "CONFERENCE" then
	dst="*63"..dst
elseif dst_type == "IVR" then
	dst="*62"..dst
elseif dst_type == "QUEUE" then
	dst="*61"..dst
end
session:transfer(dst, "XML", "default")
