

function timepatterncheck(timepattern)
	local temp=os.date("*t")
	local cminutes=temp.hour*60+temp.min
	local cweek=temp.wday -1
	local cday=temp.day -1
	local cmonth=temp.month -1

	freeswitch.consoleLog("notice", "Current time, Mês="..cmonth.." Dia da Semana="..cweek.." Dia do mês="..cday.." Minutos do dia="..cminutes.."\n")

	local result=0
	-- decodificar timepattern
	local t={}
    local i=1
	tr=row
    for token in string.gmatch(timepattern, "[^,]+") do
        t[i]=token
        i=i+1
    end
    local qminutes=t[1]
    local qweekday=t[2]
    local qday=t[3]
    local qmonth=t[4]
	freeswitch.consoleLog("notice", "Pattern, Mês="..qmonth.." Dia da Semana="..qweekday.." Dia do mês="..qday.." Minutos do dia="..qminutes.."\n")

	-- Todas as operações tem de ser verdadeiras para o resultado ser 1 and apenas uma falsa gera um resultado 0
	-- Nas operações lógicas em LUA se verdadeiro ele traz o primeiro resultado, ** CUIDADO **
	-- Nas operações dentro do padrão é usado MATCH ALL, operação E lógica , todas as regras tem de bater senão é considerado falso.

	-- Verifica se o horário está dentro da faixa
	if (qminutes~="*") then
		local qminutes1=tonumber(string.sub(qminutes,1,2))*60+tonumber(string.sub(qminutes,4,5))
		local qminutes2=tonumber(string.sub(qminutes,7,8))*60+tonumber(string.sub(qminutes,10,11))
		if (cminutes>=qminutes1 and cminutes<=qminutes2) then
			result=1
		else 
			result=0
		end
	else 
		result=1
	end
	
	freeswitch.consoleLog("notice", "Resultado da avaliacao do horario="..result.."\n")

	-- Verifica o dia da semana contra o padrão
    	if (qweekday~="*") then
			-- É uma faixa ou um único dia?
			if(string.len(qweekday)>2) then
				qweekday1=tonumber(string.sub(qweekday,1,1))
				qweekday2=tonumber(string.sub(qweekday,3,3))
				-- Dentro da faixa?
				if(cweek>=qweekday1 and cweek<=qweekday2) then
					result=1 and result
				else 
					result=0
				end
			else
				if(qweekday==cweek) then
					result=1 and result
				else 
					result=0
				end
			end 
	else 
		result=1 and result
	end		

	freeswitch.consoleLog("notice", "Resultado da avaliacao do dia da semana="..result.."\n")

	-- Verifica o dia do mês contra o padrão
	if (qday~="*") then
		-- É uma faixa ou um único dia
		if(string.len(qday)>2) then
			-- pos_sep=posicao do separador
			local pos_sep=string.find(qday,"-")
			qday1=tonumber(string.sub(qday,1,pos_sep-1))
			qday2=tonumber(string.sub(qday,pos_sep+1))
			if(cday>=qday1 and cday<=qday2) then
				result =1 and result
			else 
				result =0
			end
		else 
			if(cday==qday) then
				result=1 and result
			else 
				result=0
			end
		end
	else 
		result=1 and result
	end
	
	freeswitch.consoleLog("notice", "Resultado da avaliacao do dia do mes="..result.."\n")

	-- Verifica se o mês está dentro da faixa
	if(qmonth~="*") then
		-- É uma faixa ou um único mês
		if(string.len(qmonth)>2) then
			-- pos_sep=posicao do separador
			local pos_sep=string.find(qmonth,"-")
			qmonth1=tonumber(string.sub(qmonth,1,pos_sep-1))
			qmonth2=tonumber(string.sub(qmonth,pos_sep+1))
			if(cmonth>=qmonth1 and cmonth<=qmonth2) then
				result =1 and result
			else 
				result =0
			end
		else 
			if(cmonth==qmonth) then
                result=1 and result
            else
                result=0
            end
		end
	else 
		result=1 and result
	end
	freeswitch.consoleLog("notice", "Resultado da avaliacao do dia do mes do ano"..result.."\n")
	freeswitch.consoleLog("notice", "Resultado da final timepatterns "..result.."\n")
	return result
end