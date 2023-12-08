

-- Conexão com o banco de dados
script_dir='/usr/share/freeswitch/scripts/flux/pbx_scripts'
dofile(script_dir..'/db.lua')
dbh=db_read()

queue=argv[1]
domain_name=argv[2]
caller_uuid=argv[3]
queue_name=queue..'@'..domain_name

local my_query = string.format("select announce_interval from ms_queue where name='%s' and domain='%s' and announce_interval is not null", queue, domain_name)
dbh:query(my_query, function(row)
	seconds=tonumber(row.announce_interval)
	if  seconds > 0 then
		exists = true
		freeswitch.consoleLog("notice", "Iniciando anuncio periodico na fila\n")
	end
end)

api = freeswitch.API()
while (exists) do
    -- Pausa entre os anuncios
    freeswitch.msleep(seconds*1000)
    pos = 1
    exists = false
    -- Lista os membros da fila
    members = api:executeString("callcenter_config queue list members "..queue_name)  
    for line in members:gmatch("[^\r\n]+") do
    	-- Membros ativos tem uma posicao quando o estado é Waiting ou Trying
        if (string.find(line, "Trying") ~= nil or string.find(line, "Waiting") ~= nil) then
            -- Membro encontrado na fila, reproduz o anuncio
            if string.find(line, caller_uuid, 1, true) ~= nil then
                exists = true
                api:executeString("uuid_broadcast "..caller_uuid.." ivr/ivr-you_are_number.wav aleg")
                api:executeString("uuid_broadcast "..caller_uuid.." digits/"..pos..".wav aleg")
            end
            pos = pos+1
        end
    end
end