
-- Conexão com o banco de dados de leitura
function db_read()


	local dbh = freeswitch.Dbh("odbc://"..ODBC_DSN..":"..DB_USERNAME..":"..DB_PASSWD.."");
	if not dbh:connected() then
		freeswitch.consoleLog("notice", "Falha ao conectar ao banco de dados de leitura\n")
		return false
	end
	return dbh
end


function db_write()
	local dbh_write = freeswitch.Dbh("odbc://"..ODBC_DSN..":"..DB_USERNAME..":"..DB_PASSWD.."");
	if not dbh_write:connected() then
  		freeswitch.consoleLog("notice", "Falha ao conectar ao banco de dados de escrita\n")
  		return false
	end
	return dbh_write
end