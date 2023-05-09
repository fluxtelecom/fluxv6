
 
freeswitch.consoleLog("notice", "Modulo de Manipulacao de Discagens\n")

-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/lib/pbx_scripts'
dofile(script_dir..'/db.lua')
dbh=db_read()

destination_number = session:getVariable("destination_number")
domain=session:getVariable("domain_name")

freeswitch.consoleLog("notice", "Buscando alias "..destination_number.." no banco de dados\n")
-- Busca dados da URA no banco de dados   
local my_query = string.format("select * from call_manipulation where domain ='%s' and  '%s' regexp match_exp order by priority limit 1", domain, destination_number)
dbh:query(my_query, function(row)
	alias=row
	freeswitch.consoleLog("notice", "alias  "..destination_number.." encontrado\n")
end)

-- Verifica se existe um usuario (ou alias) com o numero discado, caso nao encontre DID
if alias then
	freeswitch.consoleLog("notice", "Alias  "..destination_number.." encontrado \n")
	lusername=alias.destination
	match_exp=alias.match_exp
    api = freeswitch.API();
    freeswitch.consoleLog("notice", "Alias "..destination_number.." Exp: "..match_exp.." Repl Exp "..lusername.."\n")
	lusername = api:execute("regex", destination_number.."|"..match_exp.."|"..lusername)
	lusername=lusername:gsub("%s", "")
	freeswitch.consoleLog("notice", "Alias "..destination_number.." "..lusername.."\n")
	session:transfer(lusername,"XML", "default")
end

return
