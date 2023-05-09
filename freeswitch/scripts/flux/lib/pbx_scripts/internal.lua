

-- Este módulo é responsável pelos serviços de recebimento de chamadas, gravação de chamadas, siga-me e chefe secretária.

freeswitch.consoleLog("notice", "Modulo de Ramais Internos\n")

-- Verifica estado da sessao
if not session:ready() then
	return
end

-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/scripts/pbx_scripts'
dofile(script_dir..'/db.lua')
dbh=db_read()

-- Tratamento de transferencia assistida
if session:getVariable("att_xfer_dst") then
	req_username = session:getVariable("att_xfer_dst")
  xfer=true
else
	req_username = session:getVariable("destination_number")
  xfer=false
end
req_domain = session:getVariable("domain_name")
-- Verifica a base de aliases
local my_query = string.format("select username,domain from dbaliases where alias_username='%s' and alias_domain='%s' limit 1", req_username,req_domain)
assert(dbh:query(my_query, function(alias)
  freeswitch.consoleLog("notice", string.format("Alias enconrado: %s@%s -> %s@%s \n", req_username,req_domain,alias.username,alias.domain))
  req_username=alias.username
  req_domain=alias.domain
  end))

session:execute("export","dialed_extension="..req_username)

-- Recupera as preferência de B
local my_query = string.format("select * from domain where domain = '%s'", req_domain)
assert (dbh:query(my_query, function(d)
  hold_music=d.music_on_hold
  external_extension=d.external_extension
  external_server=d.external_server
end))
local my_query = string.format("select mobility,voicemail,active_incoming_calls,rec,callgroup,call_fwd,fwd_busy,no_answer,secretary,rings,daterange_id from sip_devices where username = '%s' limit 1", req_username)
freeswitch.consoleLog("notice", "sql  "..my_query.." \n")
found=false
assert(dbh:query(my_query, function(pref)
    freeswitch.consoleLog("notice", "internal  "..req_username.." encontrado\n")
    extension_found=true
  	if not pref.active_incoming_calls then
    		aic=""
  	else
    		aic=pref.active_incoming_calls
  	end
  	if not pref.rec then
    		recb=""
  	else
    		recb=pref.rec
  	end
  	if not pref.callgroup then
    		cgr=""
  	else
    		cgr=pref.callgroup
  	end
  	if not pref.call_fwd then
    		cfd=""
  	else
    		cfd=pref.call_fwd
  	end
  	if not pref.fwd_busy then
    		fwb=""
  	else
    		fwb=pref.fwd_busy
  	end
  	if not pref.no_answer then
    		naw=""
  	else
    		naw=pref.no_answer
  	end
  	if not pref.secretary then
    		sec=""
  	else
    		sec=pref.secretary
  	end
  	if not pref.rings then
    		rings=47
  	else
      if pref.rings=="0" then
        rings=47
      else
    	 rings=pref.rings
      end
	end
  if not pref.voicemail then
   		voicemail=0
  else
   		voicemail=pref.voicemail
	end
  if not pref.mobility then
   		mobility=0
  else
   		mobility=pref.mobility
	end
  if not pref.daterange_id then
      daterange_id=""
  else
      daterange_id=pref.daterange_id
  end
 -- if  hold_music == "default" then
  --  hold_music='local_stream://moh'
  --else
    --hold_music='/usr/share/freeswitch/sound/'..req_domain..'/'..hold_music
  --end
end))

-- Se nao tiver tipo de chamada, é uma chamada entre ramais
if not session:getVariable("service") then
        session:setVariable("service","net")
end

-- Se o ramal nao existir, encaminha a chamada para o SSW, caso permitido no domínio
if not extension_found then
  freeswitch.consoleLog("notice", "Ramal "..req_username.." nao cadastrado\n")
  if external_extension==1 and string.len(req_username) <8 then
    session:setVariable("sip_h_X-PBX-Domain",req_domain)
    if external_server then
    	session:execute("bridge","sofia/outgoing/"..req_username.."@"..external_server)
    else
    	session:execute("transfer",req_username.." XML outgoing")
    end
  else
    session:hangup("1")
  end
	return
end
hold_music="/usr/share/freeswitch/sounds/music/8000/upbeat-acoustic-happiness.wav"
session:setVariable("continue_on_fail","true")
session:setVariable("called_party_callgroup",cgr)
session:setVariable("record_b_leg",recb)
session:setVariable("secretary",sec)
--session:setVariable("rings",ring)
session:setVariable("mobility",mobility)
session:setVariable("call_username",req_username)
session:execute("export","nolocal:hold_music="..hold_music)
session:execute("export","forward_on_busy="..fwb)
session:execute("export","forward_on_no_answer="..naw)
session:execute("export","voicemail="..voicemail)
session:execute("export","caller_domain="..req_domain)
uniqueid=session:getVariable("uuid")
rec=session:getVariable("rec")


-- So define o timeout da chamada se ele nao tiver definido (Huntgroup)
if not session:getVariable("call_timeout") then
        session:setVariable("call_timeout",rings)
        session:execute("export","call_timeout="..rings)
end
if session:getVariable("call_timeout") == "" then
	session:setVariable("call_timeout",rings)
	session:execute("export","call_timeout="..rings)
end

freeswitch.consoleLog("notice", "aic="..aic.." rec="..recb.." cgr="..cgr.." cfd="..cfd.." fwb="..fwb.." naw="..naw.." sec="..sec.." rings="..rings.." dr_id="..daterange_id.."\n")

-- Captura de chamadas
session:execute("hash", "insert/${domain_name}-last_dial_ext/global/${uuid}") -- Captura global
session:execute("hash", "insert/${domain_name}-last_dial_ext/"..req_username.."/${uuid}") --Captura de ramal
session:setVariable("execute_on_answer_1","set pck=${hash(delete/${domain_name}-last_dial_ext/global/${uuid})}")
session:setVariable("execute_on_answer_2","set pck=${hash(delete/${domain_name}-last_dial_ext/"..req_username.."/${uuid})}")
execute_count=3
for group in string.gmatch(cgr, "[^,]+") do
	session:execute("hash", "insert/${domain_name}-last_dial_grp/"..group.."/${uuid}") --Captura de grupo
	session:setVariable("execute_on_answer_"..execute_count,"set pck=${hash(delete/${domain_name}-last_dial_grp/"..group.."/${uuid}}")
	execute_count=execute_count+1
end

-- Grava se A ou B estiverem setados para gravar
local rec_dir = freeswitch.getGlobalVariable("recordings_dir")
rec_accountcode=req_username..'@'..req_domain
if(rec=="1" or recb=="1") then
  if rec=="1" then
    rec_accountcode=session:getVariable("accountcode")
  end
  session:setVariable("rec_accountcode",rec_accountcode)
  session:execute("export","execute_on_answer=record_session "..rec_dir.."/"..req_domain.."/"..rec_accountcode.."/"..uniqueid..".mp3")
else
  -- Gravação sob demanda, digirando *1
  session:execute("bind_meta_app","1 b s record_session:::"..rec_dir.."/"..req_domain.."/"..rec_accountcode.."/"..uniqueid..".mp3")
end

-- Transferencia assisitida, digitando *2
session:execute("bind_meta_app","2 b s execute_extension::att_xfer XML features")
-- Transferencia cega, digitando *3
session:execute("bind_meta_app","3 b s execute_extension::dx XML features")

-- Não desliga quando encaminha
session:setAutoHangup(false)

-- Desliga e gera mensagem se ramal bloqueado
if(aic~="1") then
  session:execute("playback","flux/ramal-bloquado-para-receber-chamadas.wav")
  session:hangup(16)
end

-- Blacklist de entrada
local cid=session:getVariable("caller_id_number")
dofile(script_dir..'/blacklist.lua')
if blacklist(req_username,req_domain,cid,"userblacklist_in") then
  session:execute("playback","flux/ramal-bloquado-para-receber-chamadas.wav")
  session:hangup(16)
end

-- Condicao de horario para funcionamento do ramal
if daterange_id ~= "" then
  dofile(script_dir..'/timepatterncheck.lua')
  local my_query=string.format("select daterange_items.timepattern from daterange, daterange_items where daterange.id=%s and daterange.id=daterange_items.daterange_id",daterange_id)
  final=0
  dbh:query(my_query, function(row)
    tp_result=timepatterncheck(row.timepattern)
    if (tp_result==1 or final==1) then
      final=1
    end
  end)
  -- Se estiver fora do horario, finaliza a chamada
  if final==0 then
    freeswitch.consoleLog("notice", "Ramal "..req_username.." nao liberado para receber chamadas neste horario\n")
    session:hangup(16)
  end
end

-- transferir para secretaria exceto quando o número de A é da secretária
if(sec~="" and cid~=sec and sec~=req_username) then
	session:transfer(sec,"XML","default")
end

-- Seta o numero de destino para o forward incondicional
if(cfd~="" and cfd~=req_username) then
  session:transfer(cfd,"XML","default")
end

if(mobility=="1") then
	local my_query = string.format("select call_fwd,accountcode from mobility where username = '%s' and domain='%s' limit 1", req_username,req_domain)
        freeswitch.consoleLog("notice", "Mobility  "..my_query.." encontrado\n")
	assert(dbh:query(my_query, function(mob)
        	freeswitch.consoleLog("notice", "Mobility  "..my_query.." encontrado\n")
  		if not mob.call_fwd then
    			mob_call_fwd=""
  		else
    			mob_call_fwd=mob.call_fwd
  		end
  		if not mob.accountcode then
    			mob_accountcode=""
  		else
    			mob_accountcode=mob.accountcode
  		end
		if(mob_call_fwd~="") then
			session:setVariable("accountcode",mob_accountcode)
			session:setVariable("mob_call_fwd",mob_call_fwd)
			session:transfer(mob_call_fwd,"XML","default")
		end
	end))
end

api = freeswitch.API();
registered = api:execute("sofia_contact",req_username.."@"..req_domain)
if registered=="error/user_not_registered" then
        -- Conexão com o banco de dados
        script_dir='/usr/share/freeswitch/scripts/flux/scripts/pbx_scripts'

        --script_dir=freeswitch.getGlobalVariable("script_dir")
        dofile(script_dir..'/db.lua')
        -- Busca no banco de dados se o usuario esta registrado em outro lugar
        i=1
        --local my_query = string.format("select server from registration where username='%s' and domain='%s'", req_username,req_domain)
        local my_query = string.format("select network_ip from registrations where reg_user='%s' and realm='%s'", req_username,req_domain)
        dbh:query(my_query, function(row)
                server=row.server
                freeswitch.consoleLog("notice", "Usuario "..req_username.."@"..req_domain.." encontrado em "..server.."\n")
                session:setVariable("sip_h_X-PBX-Domain",req_domain)
                if i==1 then
                        dialstring="sofia/internal/"..req_username.."@"..server..":5099"
                else
                        dialstring=dialstring..",sofia/internal/"..req_username.."@"..server..":5099"
                end
                i=i+1
        end)
        if dialstring then
                session:execute("bridge",dialstring)
                return
        end
end
