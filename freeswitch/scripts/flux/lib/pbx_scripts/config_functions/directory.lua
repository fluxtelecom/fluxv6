function directory()
  req_domain=params:getHeader("domain")
  req_user=params:getHeader("user")
  freeswitch.consoleLog("notice", "Directory: Buscando dados do usuário "..req_user.."@"..req_domain.."\n")
  -- Busca dados do usuário no banco de dados   
  local my_query = string.format("select * from sip_devices where domain = '%s' and username='%s' limit 1", req_domain, req_user)
  assert (dbh:query(my_query, function(u)
  	local my_query = string.format("select * from domain where domain = '%s'", req_domain)
  	assert (dbh:query(my_query, function(d)
  		hold_music=d.music_on_hold
  	end))
   -- Verifica os valores
  if not u.email_address then email_address="" else email_address=u.email_address end
  if not u.facility_pin then facility_pin="" else facility_pin=u.facility_pin end
  if not u.callgroup then callgroup="" else callgroup=u.callgroup end
  if not u.pickupgroup then pickupgroup="" else pickupgroup=u.pickupgroup end
  if not u.call_fwd then call_fwd="" else call_fwd=u.call_fwd end
  if not u.fwd_busy then fwd_busy="" else fwd_busy=u.fwd_busy end
  if not u.no_answer then no_answer="" else no_answer=u.no_answer end 
  if not u.secretary then secretary="" else secretary=u.secretary end
  if not u.pincode then pincode="" else pincode=u.pincode end
  if not u.string_acl then string_acl="" else string_acl=u.string_acl end
  if not u.string_acl_lock then string_acl_lock="" else string_acl_lock=u.string_acl_lock end
  if not u.rec then rec="" else rec=u.rec end
  if not u.acocunt_code then account_code=u.username.."@"..u.domain else account_code=u.account_code end
  if not u.callerid then callerid=u.username else callerid=u.callerid end
  if not u.daterange_id then daterange_id="" else daterange_id=u.daterange_id end
  if u.vm_send_email==0 then vm_send_email="false" else vm_send_email="true" end
  if u.rings=="0" then rings=47 else rings=u.rings end
  if hold_music=="default" then 
  	hold_music='local_stream://moh'
  else
  	hold_music='/usr/share/freeswitch/sounds/music/dev.flux.net.br/Global/8000/technology-park.wav'
  	
  end

    XML_STRING =
  '<?xml version="1.0" encoding="UTF-8" standalone="no"?>\
  <document type="freeswitch/xml">\
    <section name="directory">\
      <domain name="' .. u.domain .. '">\
        <user id="' .. u.username .. '" cacheable="7200000000">\
          <params>\
            <param name="password" value="' .. u.password .. '"/>\
            <param name="vm-password" value="' .. facility_pin .. '"/>\
            <param name="vm-mailto" value="' .. email_address .. '"/>\
            <param name="vm-email-all-messages" value="' .. vm_send_email .. '"/>\
            <param name="vm-attach-file" value="true"/>\
	    <param name="dial-string" value="{presence_id=${dialed_user}@${dialed_domain},transfer_fallback_extension=${dialed_user}}${sofia_contact(${dialed_user}@'..u.domain..')}"/>\
          </params>\
          <variables>\
            <variable name="user_context" value="default"/>\
            <variable name="direction" value="outbound"/>\
            <variable name="email_address" value="'.. email_address ..'"/>\
            <variable name="country_code" value="'.. u.country_code ..'"/>\
            <variable name="area_code" value="'.. u.area_code ..'"/>\
            <variable name="call_group" value="'.. callgroup ..'"/>\
            <variable name="pickupgroup" value="'.. pickupgroup ..'"/>\
            <variable name="call_fwd" value="'.. call_fwd ..'"/>\
            <variable name="fwd_busy" value="'.. fwd_busy ..'"/>\
            <variable name="no_answer" value="'.. no_answer ..'"/>\
            <variable name="secretary" value="'.. secretary ..'"/>\
            <variable name="pincode" value="'.. pincode ..'"/>\
            <variable name="active_outgoing_calls" value="'.. u.active_outgoing_calls ..'"/>\
            <variable name="active_incoming_calls" value="'.. u.active_incoming_calls ..'"/>\
            <variable name="blk_anon_calls" value="'.. u.blk_anon_calls ..'"/>\
            <variable name="active_voicemail" value="'.. u.voicemail ..'"/>\
            <variable name="rec" value="'.. u.rec ..'"/>\
            <variable name="mobility" value="'.. u.mobility ..'"/>\
            <variable name="rings" value="'.. u.rings ..'"/>\
            <variable name="string_acl" value="'.. string_acl ..'"/>\
            <variable name="string_acl_lock" value="'.. string_acl_lock ..'"/>\
            <variable name="locker" value="'.. u.locker ..'"/>\
            <variable name="rec" value="'.. u.rec ..'"/>\
            <variable name="facility_pin" value="'.. facility_pin ..'"/>\
            <variable name="accountcode" value="'.. u.account_code ..'"/>\
            <variable name="user_callerid" value="'.. callerid ..'"/>\
            <variable name="rings" value="'.. rings ..'"/>\
            <variable name="hold_music" value="'..hold_music..'"/>\
            <variable name="daterange_id" value="'..daterange_id..'"/>\
          </variables>\
        </user>\
      </domain>\
    </section>\
  </document>'
  end))
end