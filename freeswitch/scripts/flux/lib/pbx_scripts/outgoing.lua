
 
freeswitch.consoleLog("notice", "Encaminhamento para PSTN\n")

-- Verifica estado da sessao
if not session:ready() then
	return
end

-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/pbx_scripts'
dofile(script_dir..'/db.lua')
dbh=db_read()

dst = session:getVariable("destination_number")
domain_name = session:getVariable("domain_name")
area_code = session:getVariable("area_code")
country_code = session:getVariable("country_code")
number_format = session:getVariable("number_format")

local my_query = string.format("select tech_prefix, use_alternative_softswitch, alternative_softswitch from domain where domain='%s' ", domain_name)
outgoing_list={}
assert(dbh:query(my_query, function(row)
  domain_result=row
end))

-- Encaminhamento para softswitch alternativo
if domain_result.use_alternative_softswitch == "1" then
  freeswitch.consoleLog("notice", "Encaminhamento para Softswitch Alternativo\n")
  outgoing_string='sofia/outgoing/'..domain_result.tech_prefix..dst..'@'..domain_result.alternative_softswitch
else
  -- Encaminhamento para softswitch padrão
  freeswitch.consoleLog("notice", "Encaminhamento para Softswitch Padrao\n")
  local my_query = "select address, port from system_components where type='SIP_PROXY'"
  outgoing_list={}
  assert(dbh:query(my_query, function(row)
  	table.insert(outgoing_list,row)
  end))

  -- Chamada local 8 digitos
  if string.find(dst,"^[2-9]%d%d%d%d%d%d%d$") and number_format == "e164" then
    dst=country_code..area_code..dst
  end

  -- Chamada local 9 digitos
  if string.find(dst,"^[2-9]%d%d%d%d%d%d%d%d$") and number_format == "e164" then
    dst=country_code..area_code..dst
  end

  -- Chamada LDN Fixo
  if string.find(dst,"^[1-9]%d[2-9]%d%d%d%d%d%d%d$") then
    if number_format == "e164" then
      dst=country_code..dst
    else
      dst='0'..dst
    end
  end

  -- Chamada LDN Movel
  if string.find(dst,"^[1-9]%d[2-9]%d%d%d%d%d%d%d%d$") then
    if number_format == "e164" then
      dst=country_code..dst
    else
      dst='0'..dst
    end
  end

  i=0
  for idx, outgoing in pairs(outgoing_list) do
  	if i==0 then
  		outgoing_string='sofia/outgoing/'..domain_result.tech_prefix..dst..'@'..outgoing.address..':'..outgoing.port
  	else
  		outgoing_string=outgoing_string..'|'..'sofia/outgoing/'..domain_result.tech_prefix..dst..'@'..outgoing.address..':'..outgoing.port
  	end
  	i=i+1
  end
end
session:setVariable("outgoing_string",outgoing_string)
freeswitch.consoleLog("notice", "PSTN dial string: "..outgoing_string.."\n")
