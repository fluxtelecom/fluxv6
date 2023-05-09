

-- Conexão com o banco de dados
--script_dir=freeswitch.getGlobalVariable("script_dir")
script_dir='/usr/share/freeswitch/scripts/flux/lib/pbx_scripts'
dofile(script_dir..'/db.lua')
dbh=db_read()

-- Retorna XML de sessao nao encontrada
function genNotFound()
  return '<?xml version="1.0" encoding="UTF-8" standalone="no"?>\
  <document type="freeswitch/xml">\
    <!-- Section:'.. XML_REQUEST["section"] ..' Key_Value:'.. XML_REQUEST["key_value"] ..'-->\
    <section name="configuration">\
      <result status="not found" />\
    </section>\
  </document>'
end

-- Busca usuários no banco de dados
if XML_REQUEST["section"] == "directory" then
	if XML_REQUEST["key_value"] ~= "$${domain}" then
		dofile(script_dir..'/config_functions/directory.lua')
		directory()
	end

elseif XML_REQUEST["section"] == "configuration" then
	-- Configuracoes de fila
	if XML_REQUEST["key_value"] == "callcenter.conf" then
		dofile(script_dir..'/config_functions/callcenter.lua')
 		callcenter()
	end

	-- Configuracoes de sala de conferencia
	if XML_REQUEST["key_value"] == "conference.conf" then
		dofile(script_dir..'/config_functions/conference.lua')
		conference()
	end

	-- Configuracoes de ACL
	if XML_REQUEST["key_value"] == "acl.conf" then
		dofile(script_dir..'/config_functions/acl.lua')
		acl()
	end
end

-- Sessao nao encontrada
if not XML_STRING then
	XML_STRING=genNotFound()
end
freeswitch.consoleLog("notice", "XML STRING: \n"..XML_STRING.."\n")
