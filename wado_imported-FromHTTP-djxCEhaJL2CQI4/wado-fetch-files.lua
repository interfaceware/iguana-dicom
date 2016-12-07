-- This module will download installation files, unpak zip, and place all files into respective paths.

require 'net.http.getCached'

local icm_utils = require 'icm-utils'
local wado_utils = require 'wado-utils'
local display = require 'wado-installation-status'
local instance = {'ORTHANC1', 'ORTHANC2'}
local filenames = {
   [1] = 'Orthanc-1.0.0-Release.exe',
   [2] = 'orthancCmd.cmd',
   [3] = 'pacsdata.zip'}
local files =  {
   [filenames[1]]='http://static.interfaceware.com/WADOdemo/Orthanc-1.0.0-Release.exe',
   [filenames[2]]='http://static.interfaceware.com/WADOdemo/orthancCmd.cmd',
   [filenames[3]]='http://static.interfaceware.com/WADOdemo/pacsdata.zip'}

function os.executeAndCapture(cmd)
   local F = assert(io.popen(cmd, 'r'))
   local S = assert(F:read('*a'))
   F:close()
   return S
end

local function downloadInstallationFiles(...) 
   local F = io.open(arg[2],'wb') -- expect binary data
   F:write(arg[1])
   F:close()
end

local function dwnldFile(v)
   return net.http.getCached{
      url=v,
      timeout=400,
      debug=true,
      live=true}
end

local function createFolders()
   for k,v in pairs(instance) do
      icm_utils.create(wado_utils.application()..v)
   end
end

local function duplicateExe(...)
   if icm_utils.isWindows then
      for k,v in pairs (instance) do
         local cmd = 'copy /y /v /b '..
         wado_utils.application()..filenames[1]..' '..
         wado_utils.application()..v..'\\'..filenames[1] 
         os.executeAndCapture(cmd)
      end
   end
end   

function wado_fetch_files(R,A)
   wado_utils.create(wado_utils.application())
   createFolders()
   for k,v in pairs(files) do
      downloadInstallationFiles(
         dwnldFile(v), 
         wado_utils.application()..k)
   end
   duplicateExe()
   STATUS["download"]=true
   return { ["status"]="ok"}
end
