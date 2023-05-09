

function acl()
  freeswitch.consoleLog("notice", "Gerando ACL\n")
  -- Busca IPs no banco
  acl_list={}
  assert (dbh:query("select address from system_components where type <> 'WEB_SOCKET'", function(row)
    table.insert(acl_list,row.address)
  end))
  assert (dbh:query("select substring_index(external_server,':',1) as external_server from domain where external_server is not null and external_server <> '' group by external_server", function(row)
    table.insert(acl_list,row.external_server)
  end))
  XML_STRING =[[
  <document type="freeswitch/xml">
   <section name="configuration">
    <configuration name="acl.conf" description="Network Lists">
     <network-lists>
      <list name="wan.auto" default="allow">
      </list>

      <list name="esl" default="allow">
       <node type="allow" cidr="192.168.0.0/16"/>
       <node type="allow" cidr="10.0.0.0/8"/>
       <node type="allow" cidr="172.16.0.0/16"/>
       <node type="allow" cidr="127.0.0.1/24"/>
       ]]
  for idx, ip_addr in pairs(acl_list) do
    XML_STRING=XML_STRING..[[
    <node type="allow" cidr="]]..ip_addr..[[/32"/>
    ]]
  end
  XML_STRING=XML_STRING..[[
      </list>

      <list name="domains" default="deny">
        <node type="allow" domain="$${domain}"/>
  ]]
  for idx, ip_addr in pairs(acl_list) do
    XML_STRING=XML_STRING..[[
    <node type="allow" cidr="]]..ip_addr..[[/32"/>
    ]]
  end
  XML_STRING=XML_STRING..[[
      </list>
    </network-lists>
   </configuration>
  </section>
 </document>
  ]]
end
