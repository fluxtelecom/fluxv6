

freeswitch.consoleLog("notice", "Modulo de URA\n")

-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/pbx_scripts'
dofile(script_dir..'/db.lua')
dbh=db_read()
dbh_write=db_write()

function execIvr(ivr_name)
	-- Verifica estado da sessao
	if not session:ready() then
		return
	end

	freeswitch.consoleLog("notice", "Buscando URA ".. ivr_name .." no banco de dados\n")
	-- Busca dados da URA no banco de dados   
	local my_query = string.format("select * from ms_ivr where name = '%s' limit 1", ivr_name)
	dbh:query(my_query, function(row)
		ivr=row
		freeswitch.consoleLog("notice", "URA  ".. ivr_name .." encontrada\n")
	end)
	-- Sai da funcao caso nao encontre a URA
	if not ivr then
		freeswitch.consoleLog("notice", "URA  ".. ivr_name .." nao encontrada\n")
		return
	end
	-- Gera um variavel local com os dados da URA
	local ivr=ivr

	local domain_name=ivr.domain
	session:setVariable("domain_name",domain_name)
	sounds_dir="/usr/share/freeswitch/sounds/en/us/callie"

	local repeat_times=0
	while repeat_times <= tonumber(ivr.repeat_times) do
		repeat_times = repeat_times +1
		-- Verifica estado da sessao
		if not session:ready() then
			return
		end
		wait_timeout=ivr.wait*1000
		local menu_msg=sounds_dir.."/"..ivr.menu
		digits = session:playAndGetDigits (1,ivr.max_digits,1,wait_timeout,'#',menu_msg,"silence_stream://1000,1400",'^.*','digits',2000)

		if digits == "" then
			freeswitch.consoleLog("notice", "URA  ".. ivr_name .." - Nenhuma opcao selecionada, reproduzindo mensagem de tempo de espera\n")
			if ivr.timeout_msg ~="" then
				local timeout_msg=sounds_dir.."/"..ivr.timeout_msg
				session:execute("playback",timeout_msg)
			end
			digits="t"
		end

		freeswitch.consoleLog("notice", "URA  ".. ivr_name .." - Opcao selecionada:  ".. digits .."\n")

		ivr_commands=false
		-- Busca acao para a opção selecionada
		local my_query = string.format("select app,app_data from ms_ivr_commands where id_ura = '%s' and id_command= '%s' limit 1", ivr.id, digits)
		dbh:query(my_query, function(row)
			freeswitch.consoleLog("notice", "URA  ".. ivr_name .." - Opcao:  ".. digits .." Acao: "..row.app.. "-"..row.app_data.."\n")
			ivr_commands=row
		end)

		-- Se não houver ação cadastrada
		if not ivr_commands then
			-- Se configurado, busca se foi solicitado um ramal (ou alias)
			if ivr.dial_extension == "1" and digit ~="t" then
				-- Verifica se o ramal ou alias existe
				local user_query=string.format("select id from subscriber where domain='%s' and username='%s'", domain_name, digits)
				dbh:query(user_query, function(row)
					freeswitch.consoleLog("notice", "URA  ".. ivr_name .." - Opcao:  ".. digits .." - Usuario encontrado\n")
					user_id=row
				end)
				local alias_query = string.format("select id from dbaliases where alias_username='%s' and alias_domain='%s' limit 1", digits, domain_name)
				dbh:query(alias_query, function(row)
					freeswitch.consoleLog("notice", "URA  ".. ivr_name .." - Opcao:  ".. digits .." - Alias encontrado\n")
					alias_id=row
				end)
				if user_id or alias_id then
					session:execute("set","transfer_ringback=$${us-ring}")
					-- Se o ramal existir, transfere a chamada para o dialplan
					session:transfer(digits, "XML", "default")
					user_id=false
					-- Para o loop de tentativas se encontrar o ramal
					break
				end
			end
			-- Se nao encontrar um ramal, a opcao foi invalida
			freeswitch.consoleLog("notice", "URA  ".. ivr_name .." - Opcao:  ".. digits .." nao encontrada\n")
			if digits ~= "t" then
				digits="i"
			end

			local my_query = string.format("select app,app_data from ms_ivr_commands where id_ura = '%s' and id_command= '%s' limit 1", ivr.id, digits)
			dbh:query(my_query, function(row)
				freeswitch.consoleLog("notice", "URA  ".. ivr_name .." - Opcao:  ".. digits .." Acao: "..row.app.. "-"..row.app_data.."\n")
				ivr_commands=row
			end)
		end

		-- Registra a opcao digitada no banco de dados
		if dbh_write then
			local uuid=session:getVariable("uuid")
			local callerid=session:getVariable("caller_id_number")
			local my_query = string.format("insert into ivr_log (uuid,ivr_name,domain,caller,digit,time) values ('%s','%s','%s','%s','%s', NOW())", uuid, ivr_name, domain_name, callerid, digits)
			dbh:query(my_query)
		else
			freeswitch.consoleLog("err", "URA falha na conexao com o banco de dados de escrita\n")
		end

		--Verifica se há ação para o comando
		if ivr_commands then
			-- Reproduzir um áudio
			if ivr_commands.app=="PLAYBACK" then
				local playback_msg=sounds_dir.."/"..ivr_commands.app_data
				session:execute("playback",playback_msg)
			-- Chamda uma outra URA
			elseif ivr_commands.app=="IVR" then
				execIvr(ivr_commands.app_data)
			-- Desliga a chamada
			elseif ivr_commands.app=="HANGUP" then
				if ivr_commands.app_data ~= "" then
					local playback_msg=sounds_dir.."/"..ivr_commands.app_data
					session:execute("playback",playback_msg)
				end
				session:hangup()
			-- Transfere a chamada de volta para o dialplan caso for chamar alguma extensão
			else
                                session:execute("set","transfer_ringback=$${us-ring}")
                                -- Transferencia assisitida, digitando *2
                                session:execute("bind_meta_app","2 b s execute_extension::att_xfer XML features")
                                -- Transferencia cega, digitando *3
                                session:execute("bind_meta_app","3 b s execute_extension::dx XML features")

				if ivr_commands.app=="USER" then
					dst_data=ivr_commands.app_data
				elseif ivr_commands.app=="HUNTGROUP" then
					dst_data="*65"..ivr_commands.app_data
				elseif ivr_commands.app=="TIMEROUTING" then
					dst_data="*64"..ivr_commands.app_data
				elseif ivr_commands.app=="CONFERENCE" then
					dst_data="*63"..ivr_commands.app_data
				elseif ivr_commands.app=="QUEUE" then
					dst_data="*61"..ivr_commands.app_data
				end
				session:transfer(dst_data, "XML", "default")
			end
			-- Para o loop de tentativas quando o comando for valido
			break
		else
			-- Se não houver ação e nao for timeout, reproduz mensagem de comando inválido
			if digits ~= "t" then
				freeswitch.consoleLog("notice", "URA  ".. ivr_name .." - Opcao:  ".. digits .." Nao encontrada - reproduzindo audio de opcao invalida\n")
				local invalid_msg=sounds_dir.."/"..ivr.invalid_cmd_msg
				session:execute("playback",invalid_msg)
			end
		end
	end
end

-- Possibilitar captura de chamadas quando vir da URA
session:execute("hash", "insert/${uuid}/intercept_anyway/true")
-- Atende a chamada da URA
session:answer()
-- Espera 1 segundo antes de prosseguir com a URA
session:execute("sleep","1000")
-- Executa a URA
--execIvr(string.sub(session:getVariable("destination_number"),4))
execIvr(session:getVariable("destination_number"))