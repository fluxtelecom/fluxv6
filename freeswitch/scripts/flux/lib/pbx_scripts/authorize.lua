
 
if ( session:ready() ) then
   api = freeswitch.API();
   -- Variaveis da chamada
   destination_number = session:getVariable("destination_number")
   sounds_dir = session:getVariable("sounds_dir")
   username=session:getVariable("call_username")
   if not username then
       username=session:getVariable("caller_id_number")
   end
   domain=session:getVariable("domain_name")
   session:execute("export","domainname="..domain)
   -- Variaveis de usuario
   string_acl = session:getVariable("string_acl")
   string_acl_lock = session:getVariable("string_acl_lock")
   locker = session:getVariable("locker")
   aoc = session:getVariable("active_outgoing_calls")
   area_code = session:getVariable("area_code")
   country_code = session:getVariable("country_code")
   callerid = session:getVariable("user_callerid")
   rings=api:execute("user_data", username.."@"..domain.." var rings")
   rec = session:getVariable("rec")
   pincode = session:getVariable("pincode")
   daterange_id = session:getVariable("daterange_id")

   -- Se a chamada vier por webcallback, as variaves serao nulas. Busca os dados do usuario via API
   if not string_acl then
      string_acl=api:execute("user_data", username.."@"..domain.." var string_acl")
      string_acl_lock=api:execute("user_data", username.."@"..domain.." var string_acl_lock")
      locker=api:execute("user_data", username.."@"..domain.." var locker")
      aoc=api:execute("user_data", username.."@"..domain.." var active_outgoing_calls")
      area_code=api:execute("user_data", username.."@"..domain.." var area_code")
      country_code=api:execute("user_data", username.."@"..domain.." var country_code")
      callerid=api:execute("user_data", username.."@"..domain.." var user_callerid")
      rec=api:execute("user_data", username.."@"..domain.." var rec")
      pincode=api:execute("user_data", username.."@"..domain.." var pincode")
      daterange_id=api:execute("user_data", username.."@"..domain.." var daterange_id")
      session:setVariable("country_code",country_code)
      session:setVariable("area_code",area_code)
   end

   -- Verifica o valor das variaveis
   if not string_acl then
      string_acl="V"
   end
   if not string_acl_lock then
      string_acl_lock="V"
   end

   logline=string.format("dn=%s, sa=%s, sl=%s, lo=%s, aoc=%s, ac=%s",destination_number,string_acl,string_acl_lock,locker,aoc,area_code)

   freeswitch.consoleLog("notice", "Authorize "..logline.."\n")
 
   if(aoc=="0") then 
   	freeswitch.consoleLog("notice", "User not authorized to make calls\n")
   	string_acl=""
    string_acl_lock=""
   end

   -- Pede senha de chamda sainte em caso de pincode cadastrado
   if pincode ~= nil and pincode ~="" then
      logline=string.format("Ramal %s@%s protegido por pincode %s",username,domain,pincode)
      freeswitch.consoleLog("notice", "Authorize "..logline.."\n")
      senha_digitada=session:playAndGetDigits (4, 8, 3, 3000, "#", "flux/digite-a-sua-senha.wav","flux/senha-invalida.wav","\\d+") 
      freeswitch.consoleLog("notice", "Authorize pincode digitado "..senha_digitada.."\n")
      if senha_digitada ~= pincode then
         string_acl=""
         string_acl_lock=""
      end
   end

   -- Condicao de horario para funcionamento do ramal
   if daterange_id ~= nil and daterange_id ~= "" then
      script_dir='/usr/share/freeswitch/scripts/flux/pbx_scripts'
      
      dofile(script_dir..'/db.lua')
      dbh=db_read()
      dofile(script_dir..'/timepatterncheck.lua')
      local my_query=string.format("select daterange.include_dolidays, daterange_items.timepattern from daterange, daterange_items where daterange.id=%s and daterange.id=daterange_items.daterange_id",daterange_id)
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
         if (tp_result==1 or final==1) then
            final=1
         end
      end)
      -- Se estiver fora do horario, a chamada sera rejeitada
      if final==0 then
         freeswitch.consoleLog("notice", "Ramal "..username.." nao liberado para realizar chamadas neste horario\n")
         string_acl=""
         string_acl_lock=""
      end
   end

   -- Tempo maximo de chamada sem atendimento
   if tonumber(rings) >0 then
   	session:setVariable("call_timeout",rings)
   end

   -- Definindo callerid da chamada
   if callerid ~= "" then
   	session:setVariable("effective_caller_id_number",callerid)
   end

   acl=0
   -- Chamadas locais e para 0300
   if(string.find(destination_number,"^0[2-4]%d%d%d%d%d%d%d") or string.find(destination_number,"^00300")) then
   	freeswitch.consoleLog("notice", "Padrão de chamada local e 0300 \n")
      session:setVariable("service","local")
	-- Chamada local
	if(locker=="0") then
   		freeswitch.consoleLog("notice", "Sem cadeado eletrônico\n")
		if(string.find(string_acl,"L")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL sem cadeado\n")
		end 		
	else 
   		freeswitch.consoleLog("notice", "Com cadeado eletrônico\n")
		if(string.find(string_acl_lock,"L")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL com cadeado\n")
		end 		
	end
   end 

   -- Chamadas VC1 para móvel 1
   if(string.find(destination_number,"^0[5-9]%d%d%d%d%d%d%d") or string.find(destination_number,"^0[5-9]%d%d%d%d%d%d%d%d")) then
   	freeswitch.consoleLog("notice", "Padrão de chamada VC1 \n")
      session:setVariable("service","vc1")
	-- Chamada VC1
	if(locker=="0") then
   		freeswitch.consoleLog("notice", "Sem cadeado eletrônico\n")
		if(string.find(string_acl,"1")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL sem cadeado\n")
		end 		
	else 
   		freeswitch.consoleLog("notice", "Com cadeado eletrônico\n")
		if(string.find(string_acl_lock,"1")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL com cadeado\n")
		end 		
	end
   end 

   -- Chamadas LD sem CSP
   if(string.find(destination_number,"^00[1-9][1-9][2-4]%d%d%d%d%d%d%d") and string.len(destination_number)<13) then
   	freeswitch.consoleLog("notice", "Padrão de chamada LD \n")
      session:setVariable("service","ldn")
	-- Chamada VC1
	if(locker=="0") then
   		freeswitch.consoleLog("notice", "Sem cadeado eletrônico\n")
		if(string.find(string_acl,"D")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL sem cadeado\n")
		end 		
	else 
   		freeswitch.consoleLog("notice", "Com cadeado eletrônico\n")
		if(string.find(string_acl_lock,"D")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL com cadeado\n")
		end 		
	end
   end
  
   -- Chamadas VC2 sem CSP 
   if(string.find(destination_number,"^00[1-9][1-9][5-9]%d%d%d%d%d%d%d")) then
	-- Chamada VC2

	-- Verifica se VC2 ou VC3
	if(string.sub(destination_number,3,3)==string.sub(area_code,1,1)) then
   		freeswitch.consoleLog("notice", "Padrão de chamada VC2 \n")
         session:setVariable("service","vc2")
		tipo="2"
	else 
   		freeswitch.consoleLog("notice", "Padrão de chamada VC3 \n")
         session:setVariable("service","vc3")
		tipo="3"
	end
	
	if(locker=="0") then
   		freeswitch.consoleLog("notice", "Sem cadeado eletrônico\n")
		if(string.find(string_acl,tipo)) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL sem cadeado\n")
		end 		
	else 
   		freeswitch.consoleLog("notice", "Com cadeado eletrônico\n")
		if(string.find(string_acl_lock,tipo)) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL com cadeado\n")
		end 		
	end
	
   end

   -- Chamadas 0800 (8)
   if(string.find(destination_number,"^00800")) then
   	freeswitch.consoleLog("notice", "Padrão de chamada 0800 \n")
      session:setVariable("service","0800")
	if(locker=="0") then
   		freeswitch.consoleLog("notice", "Sem cadeado eletrônico\n")
		if(string.find(string_acl,"8")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL sem cadeado\n")
		end 		
	else 
   		freeswitch.consoleLog("notice", "Com cadeado eletrônico\n")
		if(string.find(string_acl_lock,"8")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL com cadeado\n")
		end 		
	end
   end

   -- Chamadas 0500 (5)
   if(string.find(destination_number,"^00500")) then
   	freeswitch.consoleLog("notice", "Padrão de chamada 0500 \n")
      session:setVariable("service","0500")
	if(locker=="0") then
   		freeswitch.consoleLog("notice", "Sem cadeado eletrônico\n")
		if(string.find(string_acl,"5")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL sem cadeado\n")
		end 		
	else 
   		freeswitch.consoleLog("notice", "Com cadeado eletrônico\n")
		if(string.find(string_acl_lock,"5")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL com cadeado\n")
		end 		
	end
   end
   
   -- Chamadas trígito gratuítas (E)
   if(string.find(destination_number,"^01[89]") or string.find(destination_number,"^0100") or string.find(destination_number,"^0128")) then
   	freeswitch.consoleLog("notice", "Padrão de chamada tridigito emergência \n")
      session:setVariable("service","emg")
   	freeswitch.consoleLog("notice", "ACL ok\n")
   	acl=1
   end

   -- Chamadas de três a cinco dígitos começando com 1, utilidade pública (T)
   if(string.find(destination_number,"^01[0-7][0-9]")) then
   	freeswitch.consoleLog("notice", "Padrão de chamada serviço de utilidade pública \n")
      session:setVariable("service","utp")
	if(locker=="0") then
   		freeswitch.consoleLog("notice", "Sem cadeado eletrônico\n")
		if(string.find(string_acl,"T")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL sem cadeado\n")
		end 		
	else 
   		freeswitch.consoleLog("notice", "Com cadeado eletrônico\n")
		if(string.find(string_acl_lock,"T")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL com cadeado\n")
		end 		
	end
   end

   -- Chamadas Internacionais (I)
   if(string.find(destination_number,"^000")) then
   	freeswitch.consoleLog("notice", "Padrão de chamada LDI \n")
      session:setVariable("service","ldi")
	if(locker=="0") then
   		freeswitch.consoleLog("notice", "Sem cadeado eletrônico\n")
		if(string.find(string_acl,"I")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL sem cadeado\n")
		end 		
	else 
   		freeswitch.consoleLog("notice", "Com cadeado eletrônico\n")
		if(string.find(string_acl_lock,"I")) then
   			freeswitch.consoleLog("notice", "ACL ok\n")
   			acl=1
		else 
   			freeswitch.consoleLog("notice", "Rejeitado pela ACL com cadeado\n")
		end 		
	end
   end

   -- Remove o 0 da discagem
   destination_number=string.sub(destination_number,2)

   -- Blacklist de saída
   if acl==1 then
   	script_dir=freeswitch.getGlobalVariable("script_dir")
   	dofile(script_dir..'/db.lua')
      dbh=db_read()
   	dofile(script_dir..'/blacklist.lua')
   	if blacklist(username,domain,destination_number,"userblacklist") then
   		freeswitch.consoleLog("notice", "Rejeitado pela User Blacklist\n")
		acl=0
	end
   end

   -- Rejeita a chamada se nao for autorizada
   if acl==0 then
   	session:execute("playback","flux/chamada-nao-autorizada.wav")
   	session:hangup("CALL_REJECTED")
   end

   -- Grava se estiver configurado para gravar
   local rec_dir = freeswitch.getGlobalVariable("recordings_dir")
   uniqueid=session:getVariable("uuid")
   rec_accountcode=username..'@'..domain
   if(rec=="1") then
      session:setVariable("rec_accountcode",rec_accountcode)
      session:execute("export","execute_on_answer=record_session "..rec_dir.."/"..domain.."/"..rec_accountcode.."/"..uniqueid..".mp3")
   else
   -- Gravação sob demanda, digirando *1
      session:execute("bind_meta_app","1 a s record_session:::"..rec_dir.."/"..domain.."/"..rec_accountcode.."/"..uniqueid..".mp3")
   end

   -- Transferencia assisitida, digitando *2
   session:execute("bind_meta_app","2 a s execute_extension::att_xfer XML features")
   -- -- Transferencia cega, digitando *3
   session:execute("bind_meta_app","3 a s execute_extension::dx XML features")


   if acl==1 then
   	session:execute("transfer",destination_number.." XML outgoing")
   end
end
