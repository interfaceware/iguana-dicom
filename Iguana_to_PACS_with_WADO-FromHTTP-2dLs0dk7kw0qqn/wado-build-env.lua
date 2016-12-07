-- This module will build initial Orthanc configuration and customize it.

local wado_utils = require 'wado-utils'
local icm_utils = require 'icm-utils'
local instance = {'ORTHANC1', 'ORTHANC2'}

local function createCfg(m)
   -- let Orthanc to generate initial confguration file
   local cmdArg = 'c: && cd '..wado_utils.application()..
   ' && Orthanc-1.0.0-Release.exe --config=.\\'..m..'\\Configuration.json'
   wado_utils.execute(cmdArg)
end

local function readCfg(p)
   local F = io.open(p..'Configuration.json','r')
   local S = F:read('*a')
   F:close()
   return S
end

local function writeCfg(...) 
   local F = io.open(arg[1]..'\\'..'Configuration.json','w')
   F:write(arg[2])
   F:close()
end

local function editOrthancCfg(m)
   local old = {[["Name" : "MyOrthanc",]],
      [["HttpPort" : 8042,]],
      [["DicomAet" : "ORTHANC",]],
      [["DicomPort" : 4242]],
      [["UnknownSopClassAccepted"            : false,]],
      '"OrthancPeers" : {',
      '"DicomModalities" : {'
   }
   local new = {   
      ['ORTHANC1']={[["Name" : "MyOrthanc1",]],
         [["HttpPort" : 8043,]],
         [["DicomAet" : "ORTHANC1",]],
         [["DicomPort" : 4243]],
         [["UnknownSopClassAccepted"            : true,]],
         '"OrthancPeers" : {\n  "peer2" : [ "http://'..iguana.webInfo().ip..':8044/" ]',
         '"DicomModalities" : {\n    "ORTHANC2" : ["ORTHANC2", "'..iguana.webInfo().ip..'", 4244]'
      },
      ['ORTHANC2']={[["Name" : "MyOrthanc2",]],
         [["HttpPort" : 8044,]],
         [["DicomAet" : "ORTHANC2",]],
         [["DicomPort" : 4244]],
         [["UnknownSopClassAccepted"            : true,]],
         '"OrthancPeers" : {\n  "peer1" : [ "http://'..iguana.webInfo().ip..':8043/" ]',
         '"DicomModalities" : {\n    "ORTHANC1" : ["ORTHANC1", "'..iguana.webInfo().ip..'", 4243]'
      }
   }
   local s = readCfg(wado_utils.application()..m..'\\')
   for k,v in ipairs(old) do
      s = s:gsub(v, new[m][k])
   end 
   writeCfg(wado_utils.application()..m, s)
end

function wado_build_env()
   if icm_utils.isWindows() then
      for n,m in ipairs(instance) do
         createCfg(m)
         -- customize each instance configuration
         editOrthancCfg(m)
         -- launch every instance as Application
         local cmdArg = 'c: && cd '..wado_utils.application()..m..
         ' && start "" Orthanc-1.0.0-Release.exe ./Configuration.json'
         wado_utils.execute(cmdArg)
      end
   end
   STATUS["enviro"]=true
   return { ["status"]="ok" }
end


