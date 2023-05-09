
 
freeswitch.consoleLog("notice", "Modulo de Chamada Entrante\n")

-- Verifica estado da sessao
if not session:ready() then
	return
end

-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/lib/pbx_scripts'

dofile(script_dir..'/db.lua')
dbh=db_read()

destination_number = session:getVariable("destination_number")

-- Chamada entrante via Integração de PBX ou Cluster
if session:getVariable("sip_h_X-PBX-Domain") then
	domain_name=session:getVariable("sip_h_X-PBX-Domain")
	session:execute("unset","sip_h_X-PBX-Domain")
else
	domain_name=session:getVariable("sip_from_host")
end
local domain_query=string.format("select id from domain where domain = '%s' limit 1", domain_name)
dbh:query(domain_query, function(row)
	local_domain=true
end)
if local_domain then 
        freeswitch.consoleLog("notice", "Integracao de PBX -> Chamada para "..destination_number.."@"..domain_name.."\n")
        session:setVariable("domain_name",domain_name)
        session:setVariable("direction","inbound")
        session:setVariable("process_cdr","false")
        session:setVariable("dialed_number",destination_number)
        session:transfer(destination_number, "XML", "default")
        return
end

freeswitch.consoleLog("notice", "Buscando DID "..destination_number.." no banco de dados\n")
-- Busca dados da URA no banco de dados   
local my_query = string.format("select * from did where alias_username = '%s' limit 1", destination_number)
dbh:query(my_query, function(row)
	did=row
	freeswitch.consoleLog("notice", "DID  "..destination_number.." encontrado\n")
end)

-- Desliga a chamada caso nao encontre um DID
if not did then
    session:hangup(1)
    return
end
session:setVariable("service","did")
dst_type=did.dst_type
local lusername=did.username
local ldomain=did.domain

-- Tratamento de musica em espera por domínio
local my_query = string.format("select * from domain where domain = '%s'", ldomain)
assert (dbh:query(my_query, function(d)
    
    hold_music="/usr/share/freeswitch/sounds/music/dev.flux.net.br/Global/8000/technology-park.wav"
    session:execute('export','hold_music='..hold_music)
end))

session:setAutoHangup(false)
session:setVariable("domain_name",ldomain)
session:setVariable("accountcode",did.account_code)
session:setVariable("direction","inbound")
session:setVariable("dialed_number",destination_number)

api = freeswitch.API();
recb = api:execute("user_data", did.account_code.." var rec")
freeswitch.consoleLog("notice", "REC="..recb.."\n")
session:execute("export", string.format("rec=%s",recb));

if(recb=="1") then
	rec_dir = freeswitch.getGlobalVariable("recordings_dir")
    uniqueid=session:getVariable("uuid")
    session:setVariable("rec_accountcode",did.account_code)
    session:execute("export","execute_on_answer=record_session "..rec_dir.."/"..ldomain.."/"..did.account_code.."/"..uniqueid..".mp3")
end

freeswitch.consoleLog("notice", "DID "..destination_number.." Destino "..dst_type.." "..lusername.."\n")
if dst_type == "HUNTGROUP" then
	lusername="*65"..lusername
elseif dst_type == "TIMEROUTING" then
	lusername="*64"..lusername
elseif dst_type == "CONFERENCE" then
	lusername="*63"..lusername
elseif dst_type == "IVR" then
	lusername="*62"..lusername
elseif dst_type == "QUEUE" then
	lusername="*61"..lusername
end

session:transfer(lusername, "XML", "default")
return