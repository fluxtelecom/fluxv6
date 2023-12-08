
 
freeswitch.consoleLog("notice", "Chamadas entre dominios\n")

-- Conexão com o banco de dados
script_dir=freeswitch.getGlobalVariable("script_dir")
dofile(script_dir..'/db.lua')
dbh=db_read()

s_domain=session:getVariable("domain_name")
--local my_query = string.format("select d_domain,prefix from interdomain where s_domain ='%s'", s_domain)
local my_query = string.format("SELECT i.name, i.destination_domain, i.prefix FROM interdomain i INNER JOIN interdomain_sources isr ON i.id = isr.interdomain_id WHERE isr.source_domain = '%s'", s_domain)
interdomain_list={}
dbh:query(my_query, function(row)
	destination_number = string.sub(session:getVariable("destination_number"),4)
	prefix=row.prefix
	prefix_size=string.len(prefix)
	freeswitch.consoleLog("notice", "Interdominio: Testando Prefixo "..prefix.." - Tamanho: "..prefix_size.." - Prefixo do destino: "..string.sub(destination_number,1,prefix_size).."\n")
	if string.sub(destination_number,1,prefix_size) == prefix then
		prefix_found=prefix
		d_domain=row.destination_domain
	end
end)

if prefix_found then
	destination_number=string.sub(destination_number,prefix_size+1)
	freeswitch.consoleLog("notice", "Interdominio: Prefixo "..prefix_found.." Encontrado - Novo Destino: "..destination_number.."@"..d_domain.."\n")
	session:execute("export","domain_name="..d_domain)
	session:transfer(destination_number,"XML","default")
end
