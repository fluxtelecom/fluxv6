
 
-- Verifica estado da sessao
if not session:ready() then
	return
end

-- Variaveis da chamada
destination_number = session:getVariable("destination_number")
voicemail=session:getVariable("voicemail")
originate_disposition=session:getVariable("originate_disposition")
fwd_busy=session:getVariable("forward_on_busy")
fwd_noanswer=session:getVariable("forward_on_no_answer")
queue_name=session:getVariable("cc_queue")

-- Se vier de uma fila, nao deve ser usado voicemail nem siga-me
if session:getVariable("cc_queue") then
	return
end

if not fwd_busy then fwd_busy="" end
if not fwd_noanswer then fwd_noanswer="" end

freeswitch.consoleLog("notice", "Modulo de Voicemail e Siga-me -> "..originate_disposition.." no_answer="..fwd_noanswer.." busy="..fwd_busy.."\n")

-- Siga-me tem prioridade sobre o voicemail

if (originate_disposition=="NO_ANSWER" or originate_disposition=="NO_USER_RESPONSE" or originate_disposition=="USER_NOT_REGISTERED") and fwd_noanswer~="" and fwd_noanswer~=destination_number then
	session:transfer(fwd_noanswer, "XML", "default")

elseif originate_disposition=="USER_BUSY" and fwd_busy~="" and fwd_busy~=destination_number then
	session:transfer(fwd_busy, "XML", "default")

elseif voicemail=="1" and originate_disposition=="NO_ANSWER" or originate_disposition=="NO_USER_RESPONSE" or originate_disposition=="USER_NOT_REGISTERED" or originate_disposition=="USER_BUSY" then
	session:answer()
	session:execute("bridge","{default_language=pt}loopback/app=voicemail:default ${domain_name} ${destination_number}")
else
	session:hangup("")
end
