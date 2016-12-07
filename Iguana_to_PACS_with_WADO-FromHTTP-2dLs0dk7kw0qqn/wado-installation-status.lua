-- This module will check and report status of installation

local display = {}
STATUS = {}
require 'net.http.cache'
require 'iguana.info'

local icm_utils = require 'icm-utils'
local PlatformInfo = iguana.info()

local ErrorMessage=[[
<h3>OS Not Supported</h3>
<p>
This utility requires the Windows versions of Iguana.
</p>
]]

local NoInternetMessage=[[
<h3>No Internet Connection Detected</h3>
<p>
This utility requires external Internet connection in order to work
</p>
<p> 
Please verify your connection and try again.
</p>
]]

local function transUrl(X) 
   local Editor = '#Page=OpenEditor&ChannelGuid='..
   X.channel.message_filter.translator_guid:nodeValue()..
   '&ChannelName='..X.channel.name:nodeValue()..
   '&ComponentType=Filter&ComponentName=Filter&User='..iguana.project.root():split('\\')[2]..
   '&delay_sync=true&Module=main.lua'
   local cmdArg =  'http://localhost:'..iguana.webInfo().web_config.port..'/mapper/'
   return cmdArg..Editor  
end

function display.status(R, A)
   local Url
   if iguana.webInfo().https_channel_server.use_https == true then   
      Url = "https://" ..R.headers.Host .. "/"
   else 
      Url = "http://" ..R.headers.Host .. "/"
   end
   Url = Url
   local X = xml.parse{data=iguana.channelConfig{guid=iguana.channelGuid()}}
   Url = Url..X.channel.from_http.mapper_url_path
   trace(Url)
   net.http.respond{body="See status", code=301,  headers={Location=Url}}
end

function display.api_status(R,A)
   local X = xml.parse{data=iguana.channelConfig{guid=iguana.channelGuid()}}

   -- Check for valid platform
   if (not ((PlatformInfo.os == 'windows' and PlatformInfo.cpu == '64bit') or
            (PlatformInfo.os == 'windows' and PlatformInfo.cpu == '32bit') or
            (PlatformInfo.os == 'linux' and PlatformInfo.cpu == '64bit') or
            (PlatformInfo.os == 'linux' and PlatformInfo.cpu == '32bit'))) then
      t = { 
         ["status"]="error",
         ["windows"]="yes",
         ["dashboard_url"]= icm_utils.dashboardUrl(R),
         ["message"] = ErrorMessage   
      }
      return t           
   end

   if PlatformInfo.os == 'windows' then 
      t = { 
         ["status"]="ok",
         ["windows"]="yes",
         ["dashboard_url"]= icm_utils.dashboardUrl(R), 
         ["transUrl"]=  transUrl(X),
      }
      for k,v in pairs(STATUS) do
         if v==true then t[k]=true end
      end
      if t["cstore"] then t["enviro"]=true end
      if t["enviro"] and t["cstore"] then t["download"]=true end
      if t["download"] and t["enviro"] and t["cstore"] then t["current"]=true end
   else 
      t = { 
         ["status"]="ok",
         ["dashboard_url"]= icm_utils.dashboardUrl(R)
      }
   end   
   -- Check for internet access...
   local Success, ErrorMessage = pcall(net.http.get, {url="http://static.interfaceware.com", cache_time=0, live=true})
   if not Success then
      t = { 
         ["status"]="error",
         ["windows"]="yes",
         ["dashboard_url"]= icm_utils.dashboardUrl(R),
         ["message"] = NoInternetMessage
      }
      return t                       
   end           
   return t
end

return display
