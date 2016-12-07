-- This module will create URL to load Translator IDE with Filter script open in the editor

local function transUrl(X) 
   local Editor = '#Page=OpenEditor&ChannelGuid='..
   X.channel.message_filter.translator_guid:nodeValue()..
   '&ChannelName='..X.channel.name:nodeValue()..
   '&ComponentType=Filter&ComponentName=Filter&User='..iguana.project.root():split('\\')[2]..
   '&delay_sync=true&Module=main.lua'
   local cmdArg =  'http://localhost:'..iguana.webInfo().web_config.port..'/mapper/'
   return cmdArg..Editor  
end

function wado_launch_editor()
   local X = xml.parse{data=iguana.channelConfig{guid=iguana.channelGuid()}}
   t = { 
      ["status"]="ok",
      ["transUrl"]=  transUrl(X)
   }
   return t  
end   
