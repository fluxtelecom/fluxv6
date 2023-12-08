

freeswitch.consoleLog("notice", "Programacao\n")

-- Verifica estado da sessao
if not session:ready() then
	return
end
destination_number = session:getVariable("destination_number")

freeswitch.consoleLog("notice", "Programacao de facilidades: "..destination_number.."\n")

-- Conexão com o banco de dados
dofile("/var/lib/flux/flux.lua")
script_dir='/usr/share/freeswitch/scripts/flux/lib/pbx_scripts'
dofile(script_dir..'/db.lua')
dbh=db_write()
if not dbh then
	return
end

-- Variaveis da chamada
req_user=session:getVariable("caller_id_number")
req_domain=session:getVariable("domain_name")
senha_facilidade=session:getVariable("facility_pin")
--call_fwd="011956812949"

-- Proramação de facilidades nao gera CDR
session:setVariable("process_cdr","false")

if string.find(destination_number,"^%*72") then
session:answer()
session:execute("sleep","1000")
session:execute("info","")
session:execute("Playback","howtoSigame.wav")
digits = session:playAndGetDigits(8, 15, 3, 12000, "#", "tone_stream://%(1000,5000,400);loops=-1", "ivr/8000/ivr-phone_not_configured.wav", "\\d+")
session:consoleLog("info", "Got DTMF digits: ".. digits .."\n")

	--local my_query = string.format("update sip_devices set call_fwd='%s',call_fwd_status='0' where username='%s'",digits,req_user)
	local my_query = string.format("update dids set extensions='%s',call_type='4' where number='%s'",digits,req_user)
	freeswitch.consoleLog("notice", "query="..my_query.."\n")
	dbh:query(my_query)
	if(dbh:affected_rows()>0) then
		freeswitch.consoleLog("notice", "Callforward programado\n")
		session:answer()
		session:execute("sleep","1000")
		session:execute("Playback","facilidade-programada.wav")
	else
		freeswitch.consoleLog("notice", "Callforward não programado\n")
		session:answer()
		session:execute("sleep","1000")
		session:execute("Playback","facilidade-nao-alterada.wav")
	end
end

if string.find(destination_number,"^%*73") then
	--local my_query = string.format("update sip_devices set call_fwd='',call_fwd_status='1' where username='%s'",req_user)
	local my_query = string.format("update dids set extensions='%s',call_type='0' where number='%s'",req_user,req_user)
	freeswitch.consoleLog("notice", "query="..my_query.."\n")
	dbh:query(my_query)
	if(dbh:affected_rows()>0) then
		freeswitch.consoleLog("notice", "Callforward desprogramado\n")
		session:answer()
		session:execute("sleep","1000")
		session:execute("Playback","sigameDesativado.wav")
	else
		freeswitch.consoleLog("notice", "Sem alteração\n")
		session:answer()
		session:execute("sleep","1000")
		session:execute("Playback","facilidade-nao-alterada.wav")
	end
end

if string.find(destination_number,"^%*90") then
digits = session:playAndGetDigits(8, 15, 3, 9000, "#", "phrase:getnum", "ivr/8000/ivr-phone_not_configured.wav", "\\d+")
session:consoleLog("info", "Got DTMF digits: ".. digits .."\n")

	local my_query = string.format("update sip_devices set fwd_busy='%s' where username='%s'",digits,req_user)
	freeswitch.consoleLog("notice", "query="..my_query.."\n")
	dbh:query(my_query)
	if(dbh:affected_rows()>0) then
		freeswitch.consoleLog("notice", "Callforward programado\n")
		session:answer()
		session:execute("Playback","facilidade-programada.wav")
	else
		freeswitch.consoleLog("notice", "Callforward não programado\n")
		session:answer()
		session:execute("Playback","facilidade-nao-alterada.wav")
	end
end

if string.find(destination_number,"^%*91") then
	local my_query = string.format("update sip_devices set fwd_busy='' where username='%s'",req_user)
	freeswitch.consoleLog("notice", "query="..my_query.."\n")
	dbh:query(my_query)
	if(dbh:affected_rows()>0) then
		freeswitch.consoleLog("notice", "Callforward desprogramado\n")
		session:answer()
		session:execute("Playback","facilidade-desprogramada.wav")
	else
		freeswitch.consoleLog("notice", "Sem alteração\n")
		session:answer()
		session:execute("Playback","facilidade-nao-alterada.wav")
	end
end


if string.find(destination_number,"^%*92") then
digits = session:playAndGetDigits(8, 15, 3, 9000, "#", "phrase:getnum", "ivr/8000/ivr-phone_not_configured.wav", "\\d+")
session:consoleLog("info", "Got DTMF digits: ".. digits .."\n")
	local my_query = string.format("update sip_devices set no_answer='%s' where username='%s'",digits,req_user)
	freeswitch.consoleLog("notice", "query="..my_query.."\n")
	dbh:query(my_query)
	if(dbh:affected_rows()>0) then
		freeswitch.consoleLog("notice", "Callforward programado\n")
		session:answer()
		session:execute("Playback","facilidade-programada.wav")
	else
		freeswitch.consoleLog("notice", "Callforward não programado\n")
		session:answer()
		session:execute("Playback","facilidade-nao-alterada.wav")
	end
end

if string.find(destination_number,"^%*93") then
	local my_query = string.format("update sip_devices set no_answer='' where username='%s'",req_user)
	freeswitch.consoleLog("notice", "query="..my_query.."\n")
	dbh:query(my_query)
	if(dbh:affected_rows()>0) then
		freeswitch.consoleLog("notice", "Callforward desprogramado\n")
		session:answer()
		session:execute("Playback","facilidade-desprogramada.wav")
	else
		freeswitch.consoleLog("notice", "Sem alteração\n")
		session:answer()
		session:execute("Playback","facilidade-nao-alterada.wav")
	end
end

if string.find(destination_number,"^%*24") then
	-- Verifica se a senha bate
	senha_digitada=string.sub(destination_number,4)
	if(senha_digitada==senha_facilidade) then
		local my_query = string.format("update subscriber set locker=1 where username='%s' and domain='%s'",req_user,req_domain)
		freeswitch.consoleLog("notice", "query="..my_query.."\n")
		dbh:query(my_query)
		if(dbh:affected_rows()>0) then
			freeswitch.consoleLog("notice", "Cadeado programado\n")
			session:answer()
			session:execute("Playback","facilidade-programada.wav")
		else
			freeswitch.consoleLog("notice", "Cadeado não programado\n")
			session:answer()
			session:execute("Playback","facilidade-nao-alterada.wav")
		end
	else
		freeswitch.consoleLog("notice", "Cadeado, senha invalida\n")
		session:answer()
		session:execute("Playback","senha-invalida")
	end
end

if string.find(destination_number,"^%*25") then
	-- Verifica se a senha bate
	senha_digitada=string.sub(destination_number,4)
	if(senha_digitada==senha_facilidade) then
		local my_query = string.format("update subscriber set locker=0 where username='%s' and domain='%s'",req_user,req_domain)
		freeswitch.consoleLog("notice", "query="..my_query.."\n")
		dbh:query(my_query)
		if(dbh:affected_rows()>0) then
			freeswitch.consoleLog("notice", "Cadeado desprogramado\n")
			session:answer()
			session:execute("Playback","facilidade-desprogramada.wav")
		else
			freeswitch.consoleLog("notice", "Cadeado não programado\n")
			session:answer()
			session:execute("Playback","facilidade-nao-alterada.wav")
		end
	else
		freeswitch.consoleLog("notice", "Cadeado, senha invalida\n")
		session:answer()
		session:execute("Playback","senha-invalida")
	end
end

-- Programação da mobilidade de extensão
if string.find(destination_number,"^%*94") then
	-- Atende a chamada e pede os dígitos
	session:answer()
	--ramal_digitado=string.sub(destination_number,4)

	ramal_digitado=session:playAndGetDigits (4, 8, 3, 3000, "#", "tone_stream://%(10000,0,350,440)","facilidade-nao-alterada.wav","\\d+")
	local my_query = string.format("select facility_pin,account_code from subscriber where username='%s' and domain='%s'",ramal_digitado,req_domain)
	assert(dbh:query(my_query, function(mob)
		senha_facilidade=mob.facility_pin
		account_code=mob.account_code
	end))

	-- Verifica se a senha bate
	senha_digitada=session:playAndGetDigits (4, 8, 3, 3000, "#", "digite-a-sua-senha.wav","senha-invalida.wav","\\d+")
	if(senha_digitada==senha_facilidade) then
		-- Atualiza o call forward
		local my_query = string.format("insert into mobility (call_fwd,accountcode,username,domain) values('%s','%s','%s','%s')",req_user,account_code,ramal_digitado,req_domain)
		freeswitch.consoleLog("notice", "query="..my_query.."\n")
		dbh:query(my_query)
		if(dbh:affected_rows()==0) then
			freeswitch.consoleLog("notice", "Mobilidade, falha ao criar call forward\n")
			session:execute("Playback","facilidade-nao-alterada.wav")
			session:hangup(16)
		end

		-- Atualiza o bit de mobilidade
		local my_query = string.format("update subscriber set mobility='1' where username='%s' and domain='%s'",ramal_digitado,req_domain)
		freeswitch.consoleLog("notice", "query="..my_query.."\n")
		dbh:query(my_query)
		if(dbh:affected_rows()==0) then
			freeswitch.consoleLog("notice", "Problema ao setar mobilidade\n")
			session:execute("Playback","facilidade-nao-alterada.wav")
			session:hangup(16)
		end
		session:execute("Playback","facilidade-programada.wav")
		session:hangup(16)

	else
		freeswitch.consoleLog("notice", "Mobilidade cadastrar, senha invalida\n")
		session:execute("Playback","senha-invalida.wav")
		session:hangup(16)
	end
end

-- Desprogramação da mobilidade de extensão
if string.find(destination_number,"^%*95") then
	-- Atende a chamada e pede os dígitos
	session:answer()

	ramal_digitado=session:playAndGetDigits (4, 8, 3, 3000, "#", "tone_stream://%(10000,0,350,440)","facilidade-nao-alterada.wav","\\d+")
	-- Atualiza o call forward
	local my_query = string.format("delete from mobility where username='%s' and domain='%s'",ramal_digitado,req_domain)
	freeswitch.consoleLog("notice", "query="..my_query.."\n")
	dbh:query(my_query)
	if(dbh:affected_rows()==0) then
		freeswitch.consoleLog("notice", "Mobilidade, falha ao criar call forward\n")
		session:execute("Playback","facilidade-nao-alterada.wav")
		session:hangup(16)
	end

	-- Atualiza o bit de mobilidade
	local my_query = string.format("update subscriber set mobility='0' where username='%s' and domain='%s'",ramal_digitado,req_domain)
	freeswitch.consoleLog("notice", "query="..my_query.."\n")
	dbh:query(my_query)
	if(dbh:affected_rows()==0) then
		freeswitch.consoleLog("notice", "Problema ao configurar mobilidade\n")
		session:execute("Playback","facilidade-nao-alterada.wav")
		session:hangup(16)
	end
	session:execute("Playback","facilidade-desprogramada.wav")
	session:hangup(16)
end

-- Comandos de agentes na fila de atendimento
-- *11 Login
-- *12 Logout
-- *13 Pausa
-- *14 Retorno
-- Login de agente
if string.find(destination_number,"^%*11") then
	session:answer()
	session:execute("sleep","1000")
	userid=req_user..'@'..req_domain
	api = freeswitch.API()
	reply = api:execute("callcenter_config", "agent set status "..userid.." Available")
	session:execute("Playback","ivr/ivr-you_are_now_logged_in.wav")
	session:hangup("NORMAL_CLEARING")
end
-- Logout de agente
if string.find(destination_number,"^%*12") then
	session:answer()
	session:execute("sleep","1000")
	userid=req_user..'@'..req_domain
	api = freeswitch.API()
	reply = api:execute("callcenter_config", "agent set status "..userid.." 'Logged Out'")
	session:execute("Playback","ivr/ivr-you_are_now_logged_out.wav")
	session:hangup("NORMAL_CLEARING")
end
-- Pausa
if string.find(destination_number,"^%*13") then
	session:answer()
	session:execute("sleep","1000")
	userid=req_user..'@'..req_domain
	api = freeswitch.API()
	reply = api:execute("callcenter_config", "agent set status "..userid.." 'On Break'")
	session:execute("Playback","ivr/ivr-thank_you.wav")
	session:hangup("NORMAL_CLEARING")
end
-- Retorno de pausa
if string.find(destination_number,"^%*14") then
	session:answer()
	session:execute("sleep","1000")
	userid=req_user..'@'..req_domain
	api = freeswitch.API()
	reply = api:execute("callcenter_config", "agent set status "..userid.." Available")
	session:execute("Playback","ivr/ivr-thank_you.wav")
	session:hangup("NORMAL_CLEARING")
end
