

-- Gera o XML das filas
function callcenter()
  freeswitch.consoleLog("notice", "Buscando configuracao de filas no banco de dados\n")
  agent_extension_data = freeswitch.getGlobalVariable("agent_extension_data")

  queue_list={}
  dbh:query("select * from ms_queue", function(row)
    table.insert(queue_list,row)
  end)
  member_list={}
  dbh:query("select extension, max_no_answer, wrap_up_time, reject_delay_time, busy_delay_time, no_answer_delay_time, domain from ms_queue_members", function(row)
    table.insert(member_list,row)
  end)
  tier_list={}
--dbh:qdbh:query("select m.extension,m.priority,q.name, q.domain from ms_queue_members m, ms_queue q where m.queue_id=q.id order by q.domain,m.id", function(row)uery("select m.extension,m.priority,q.name, q.domain from ms_queue_members m, ms_queue q where m.queue_id=q.id order by q.domain,m.id", function(row)
dbh:query("select concat(m.extension,'@',m.domain) as agent, concat(q.name,'@',q.domain) as queue,mqg.priority from ms_queue_members m, ms_queue q, ms_queue_group mqg, ms_group_agents mqa where mqa.agent_id=m.id and mqg.group_id=mqa.group_id and mqg.queue_id=q.id;", function(row)
  table.insert(tier_list,row)
  end)

  XML_STRING=[[<document type="freeswitch/xml">
   <section name="configuration">
    <configuration name="callcenter.conf" description="CallCenter">
     <settings>
       <param name="truncate-agents-on-load" value="true"/>
       <param name="truncate-tiers-on-load" value="true"/>
     </settings>
     <queues>
     ]]
  -- Gera a configuração em XML de cada fila
  for idx, queue in pairs(queue_list) do
    sounds_dir="/usr/share/freeswitch/sounds"
    if queue.musiconhold ~= "default" then musiconhold=sounds_dir..queue.musiconhold else musiconhold="local_stream://moh" end
    if queue.discard_abandoned_after and queue.discard_abandoned_after ~= "" then discard_abandoned_after=queue.discard_abandoned_after else discard_abandoned_after="1" end
    if queue.max_wait_time_with_no_agent then max_wait_time_with_no_agent=queue.max_wait_time_with_no_agent else max_wait_time_with_no_agent="" end
    if (discard_abandoned_after) ~= "1" then
      abandoned_resume_allowed="true"
    else 
      abandoned_resume_allowed="false" 
    end
    queue_name=queue.name..'@'..queue.domain
    XML_STRING=XML_STRING ..[[
    <queue name="]].. queue_name ..[[">
      <param name="strategy" value="]].. queue.strategy ..[["/>
      <param name="moh-sound" value="]].. musiconhold ..[["/>
      <param name="time-base-score" value="system"/>
      <param name="max-wait-time" value="]]..max_wait_time_with_no_agent..[["/>
      <param name="max-wait-time-with-no-agent" value="]]..max_wait_time_with_no_agent..[["/>
      <param name="max-wait-time-with-no-agent-time-reached" value="5"/>
      <param name="tier-rules-apply" value="false"/>
      <param name="tier-rule-wait-second" value="300"/>
      <param name="tier-rule-wait-multiply-level" value="true"/>
      <param name="tier-rule-no-agent-no-wait" value="false"/>
      <param name="discard-abandoned-after" value="]]..discard_abandoned_after..[["/>
      <param name="abandoned-resume-allowed" value="]]..abandoned_resume_allowed..[["/>
    </queue>
    ]]
  end
  XML_STRING=XML_STRING.. [[
   </queues>
   <agents> 
   ]]
  -- Gera a lista de agentes
  for idx, member in pairs(member_list) do
    if member.max_no_answer then max_no_answer=member.max_no_answer else max_no_answer="" end
    if member.wrap_up_time then wrap_up_time=member.wrap_up_time else wrap_up_time="" end
    if member.reject_delay_time then reject_delay_time=member.reject_delay_time else reject_delay_time="" end
    if member.busy_delay_time then busy_delay_time=member.busy_delay_time else busy_delay_time="" end
    if member.no_answer_delay_time then no_answer_delay_time=member.no_answer_delay_time else no_answer_delay_time="" end
    -- Em alguns casos resta algum lixo na query de agentes, onde o nome do agente vem duplicado, porém com os demais campos nulos
    if member.max_no_answer then
    	agent_name=member.extension..'@'..member.domain
        -- Verifica se os dados de ramal do agente deve ser verificado ou nao
	if agent_extension_data == "true" then
             agent_contact="loopback/"..member.extension
        else
             agent_contact="user/"..agent_name
        end

    	--XML_STRING=XML_STRING.. [[<agent name="]]..agent_name..[[" type="callback" contact="[domain_name=]]..member.domain..[[,process_cdr=false,leg_timeout=]]..member.ring_timeout..[[]loopback/]]..member.extension..[[" status="Available" max-no-answer="]]..max_no_answer..[[" wrap-up-time="]]..wrap_up_time..[[" reject-delay-time="]]..reject_delay_time..[[" busy-delay-time="]]..busy_delay_time..[[" no-answer-delay-time="]]..no_answer_delay_time..[[" />
      XML_STRING=XML_STRING.. [[<agent name="]]..agent_name..[[" type="callback" contact="[domain_name=]]..member.domain..[[,process_cdr=false,intercept_unanswered_only=false] ]]..agent_contact..[[" status="Available" max-no-answer="]]..max_no_answer..[[" wrap-up-time="]]..wrap_up_time..[[" reject-delay-time="]]..reject_delay_time..[[" busy-delay-time="]]..busy_delay_time..[[" no-answer-delay-time="]]..no_answer_delay_time..[[" />

    	]]
    end
  end

  XML_STRING=XML_STRING..[[</agents>
   <tiers>
   ]]
   -- Gera os tiers baseado na lista de agentes
  for idx, tier in pairs(tier_list) do
    agent_name=tier.agent
    queue_name=tier.queue
    priority=10-tier.priority
    XML_STRING=XML_STRING..[[<tier agent="]]..agent_name..[[" queue="]]..queue_name..[[" level="]]..priority..[[" position="]]..idx..[["/>
    ]]
  end
  XML_STRING=XML_STRING..[[</tiers>
  </configuration>
  </section>
</document>]]
end
