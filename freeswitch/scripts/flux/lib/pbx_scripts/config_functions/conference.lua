

-- Gera o XML das salas de conferencia
function conference()
  conf_list={}
  dbh:query("select * from ms_conference", function(row)
    table.insert(conf_list,row)
  end)

  XML_STRING=[[<?xml version="1.0" encoding="UTF-8" standalone="no"?>
  <document type="freeswitch/xml">
  <section name="configuration">
  <configuration name="conference.conf" description="Conference">
    <caller-controls> 
    <group name="default"> 
      <control action="mute" digits="0"/> 
      <control action="deaf mute" digits="*"/> 
      <control action="energy up" digits="9"/> 
      <control action="energy equ" digits="8"/> 
      <control action="energy dn" digits="7"/> 
      <control action="vol talk up" digits="3"/> 
      <control action="vol talk zero" digits="2"/> 
      <control action="vol talk dn" digits="1"/> 
      <control action="vol listen up" digits="6"/>
      <control action="vol listen zero" digits="5"/>
      <control action="vol listen dn" digits="4"/>
      <control action="hangup" digits="#"/>
    </group>
  </caller-controls> 
    <profiles>
    ]]

  -- Gera a configuração em XML de cada sala de conferencia
  for idx, conf in pairs(conf_list) do
    if not conf.pin then conf_pin="" else conf_pin=conf.pin end
    if not conf.maxusers then conf_maxusers="30" else conf_maxusers=conf.maxusers end
    if conf.enable_video==1 then
        conf_flags="video-floor-only|rfc-4579|livearray-sync|minimize-video-encoding"
      else
        conf_flags=""
      end

    XML_STRING=XML_STRING..[[
    <profile name="]].. conf.name..'-'..conf.domain..[[">
      <param name="pin" value="]]..conf_pin..[["/>
      <param name="max-members" value="]]..conf_maxusers..[["/>
      <param name="rate" value="48000"/>
      <param name="channels" value="auto"/>
      <param name="interval" value="20"/>
      <param name="energy-level" value="200"/>
      <param name="muted-sound" value="conference/conf-muted.wav"/>
      <param name="unmuted-sound" value="conference/conf-unmuted.wav"/>
      <param name="alone-sound" value="conference/conf-alone.wav"/>
      <param name="moh-sound" value="local_stream://moh"/>
      <param name="enter-sound" value="tone_stream://%(200,0,500,600,700)"/>
      <param name="exit-sound" value="tone_stream://%(500,0,300,200,100,50,25)"/>
      <param name="kicked-sound" value="conference/conf-kicked.wav"/>
      <param name="locked-sound" value="conference/conf-locked.wav"/>
      <param name="is-locked-sound" value="conference/conf-is-locked.wav"/>
      <param name="is-unlocked-sound" value="conference/conf-is-unlocked.wav"/>
      <param name="pin-sound" value="conference/conf-pin.wav"/>
      <param name="bad-pin-sound" value="conference/conf-bad-pin.wav"/>
      <param name="caller-id-name" value="$${outbound_caller_name}"/>
      <param name="caller-id-number" value="$${outbound_caller_id}"/>
      <param name="caller-controls" value="default"/>
      <param name="comfort-noise" value="true"/>
      <param name="conference-flags" value="]].. conf_flags ..[["/>
      <param name="video-mode" value="mux"/>
      <param name="video-layout-name" value="3x3"/>
      <param name="video-layout-name" value="group:grid"/>
      <param name="video-canvas-size" value="1920x1080"/>
      <param name="video-canvas-bgcolor" value="#333333"/>
      <param name="video-layout-bgcolor" value="#000000"/>
      <param name="video-codec-bandwidth" value="1mb"/>
      <param name="video-fps" value="15"/>
    </profile>
    ]]
  end
  XML_STRING=XML_STRING .. [[</profiles>
</configuration>
</section>
</document>]]
end