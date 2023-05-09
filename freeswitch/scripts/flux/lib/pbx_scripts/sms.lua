
 
 freeswitch.consoleLog("notice", "Mensagem de texto\n")


-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/lib/pbx_scripts'

dofile(script_dir..'/db.lua')
dbh=db_read()

msg=message:getBody()
domain_name=message:getHeader("from_host")
username=message:getHeader("from_user")
dst=message:getHeader("to_user")
-- Verifica se o ramal existe
dbh:query(string.format("select id from subscriber where domain='%s' and username='%s'", domain_name, digits), function(row)
	user_id=row
end)
if user_id then
	message:chat_execute("send")
else
	reply=string.format("Destino %s não é um ramal",msg,dst)
	message:chat_execute("reply",reply)
end
