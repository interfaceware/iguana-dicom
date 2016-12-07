-- This module will reset entire example.
-- It will kill all running Orthanc processes.
-- It will delete all files related to this example.

wado_utils = require 'wado-utils'

function wado_reset_example()
   local cmd = "taskkill /f /im Orthanc-1.0.0-Release.exe && rmdir /s /q %USERPROFILE%\\wadointegration"
   pcall(wado_utils.execute, cmd)
   local cmd = "rmdir /s /q %USERPROFILE%\\wadointegration"
   pcall(wado_utils.execute, cmd)
   for k,v in pairs(STATUS) do STATUS[k]=nil end
   return { ["status"]="ok" }
end