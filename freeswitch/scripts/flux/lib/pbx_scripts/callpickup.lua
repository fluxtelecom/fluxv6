
 
-- Verifica estado da sessao
if not session:ready() then
	return
end

freeswitch.consoleLog("notice", "Modulo de captura de chamadas \n")

-- Variaveis da chamada
api = freeswitch.API();
destination_number = session:getVariable("destination_number")
pickup_groups = session:getVariable("pickupgroup")
domain_name = session:getVariable("domain_name")

-- Possibilita transferencia de chamada capturada
session:execute("bind_meta_app","2 a s execute_extension::att_xfer XML features")
session:execute("bind_meta_app","3 a s execute_extension::dx XML features")

-- Captura de chamadas por domínio
if destination_number=="*7" then
	intercept_uuid=api:execute("hash","select/"..domain_name.."-last_dial_ext/global")
-- Captura de chamadas por grupo
elseif destination_number=="*8" then
	for pickupgroup in string.gmatch(pickup_groups, "[^,]+") do
		intercept_uuid=api:execute("hash","select/"..domain_name.."-last_dial_grp/"..pickupgroup)
		if intercept_uuid and intercept_uuid ~= "" then
			-- Verfiica se a chamada ainda existe no PBX
			if api:execute("uuid_exists",intercept_uuid) == "true" then
				break
			else
				-- Remove o registro do cache caso a chamada nao exista mais
				api:execute("hash","delete/"..domain_name.."-last_dial_grp/"..pickupgroup)
			end
		end
	end
-- Captura de chamadas por ramal
else
	pickup_destination=string.sub(destination_number,3)
	intercept_uuid=api:execute("hash","select/"..domain_name.."-last_dial_ext/"..pickup_destination)
end
session:setVariable('intercept_uuid',intercept_uuid)
if not intercept_uuid or intercept_uuid == "" then
	freeswitch.consoleLog("notice", "Nenhuma chamada disponivel para capturar \n")
	session:hangup()
end

-- Tratamento de captura de chamadas atendidas (URA e Fila)
intercept_anyway = api:execute("hash", "select/"..intercept_uuid.."/intercept_anyway")
if intercept_anyway == "true" then
	session:setVariable("intercept_unanswered_only","false")
end

