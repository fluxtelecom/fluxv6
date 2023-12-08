

function blacklist(username,domain,number,db_table)
    -- Consulta por expressao regular
    local my_query = "select prefix from "..db_table.." where username='"..username.."' and domain='"..domain.."' and prefix like '^%$' and '"..number.."' regexp prefix limit 1"
    dbh:query(my_query, function(r)
        regex=r
    end)
    if regex then
        freeswitch.consoleLog("debug", string.format("Blacklist -> Regex %s encontrado na tabela de blacklists\n",regex.prefix))
        return true
    end

	--Consulta por prefixos: Loop infinito para consulta do numero no banco de dados
    search=number
	while string.len(search) > 0 do
        freeswitch.consoleLog("debug", "Blacklist query prefix "..search.."\n")
		local my_query = string.format("select id from %s where username='%s' and domain='%s' and prefix='%s' limit 1", db_table,username,domain,search)
    	dbh:query(my_query, function(p)
        	prefix=p
    	end)
    	-- Se encontrar o numero no banco, está em blacklist
    	if prefix then
            freeswitch.consoleLog("debug", "Blacklist -> Prefixo "..search.." encontrado na tabela de blacklists\n")
    		return true
        end
    	-- Se nao encontrar, remove um digito e tenta novamente
    	search=search:sub(1,-2)
    end

    -- Nao encontrou expressao regular nem prefixo
    return false
end