-- Developed and tested with Windows 7
local environmentBuilder = {}
local baseDir = "c:\\\\temp\\pacs\\"
local instance = {'ORTHANC1', 'ORTHANC2'}
local files =  {
   ['Orthanc-1.0.0-Release.exe']='http://static.interfaceware.com/WADOdemo/Orthanc-1.0.0-Release.exe',
   ['orthancCmd.cmd']='http://static.interfaceware.com/WADOdemo/orthancCmd.cmd',
   ['pacsdata.zip']='http://static.interfaceware.com/WADOdemo/pacsdata.zip'}

function environmentBuilder.main()  
   -- create base location if none exist yet
   assert(os.execute('mkdir '..baseDir)) 
  
   for k,v in pairs(files) do
       downloadInstallationFiles(dwnldFile(v), baseDir..k)
   end
   -- let Orthanc to generate initial confguration file
   local cmdArg = 'c: && cd '..baseDir..
   ' && Orthanc-1.0.0-Release.exe --config=Configuration.json'
   executeCmd(cmdArg)
   -- with each newly created Orthanc instance ...
   for n,m in ipairs(instance) do
      -- create individual locations for each of Orthanc instances
      assert(os.execute('mkdir '..baseDir..m..'\\')) 
      -- duplicate files to each of instances location
      duplicateFile(baseDir, baseDir..m..'\\', 'Orthanc-1.0.0-Release.exe')
      -- duplicate Orthanc configuration file
      duplicateFile(baseDir, baseDir..m..'\\', 'Configuration.json')
      -- customize each instance configuration
      editOrthancCfg(m)
      -- launch every instance as Application
      cmdArg = 'c: && cd '..baseDir..m..
      ' && start "" Orthanc-1.0.0-Release.exe ./Configuration.json'
      executeCmd(cmdArg)
   end
   -- push Sample DICOM images to ORTHANC1 instance
   postExamples2ORTHANC1()
end

function downloadInstallationFiles(...) 
   local f = io.open(arg[2],'wb') -- expect binary data
   f:write(arg[1])
   f:close()
end

function dwnldFile(v)
   return net.http.get{
      url=v, 
      timeout=300, 
      debug = true, 
      live=true}
end

function postExamples2ORTHANC1()  
   -- unzip sample data, to be imported to PACS
   local unzip = filter.zip.inflate(readZip())
  
   for k,v in pairs(unzip) do
     postExamples(v)
    end
end

function postExamples(v)
   return net.http.post{
      url='http://localhost:8043/instances ', 
      headers={['Content-Type']='application/dicom', ['Accept']='*/*'},
      body=v,
      timeout=300, 
      debug = true, 
      live=true}
end

function readZip() -- expect binary file
   local f = io.open(baseDir..'pacsdata.zip','rb')
   local b = f:read('*a')
   f:close()
   return b
end

function editOrthancCfg(i)
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
         '"OrthancPeers" : {\n  "peer2" : [ "http://localhost:8044/" ]',
         '"DicomModalities" : {\n    "ORTHANC2" : ["ORTHANC2", "localhost", 4244]'
      },
      ['ORTHANC2']={[["Name" : "MyOrthanc2",]],
         [["HttpPort" : 8044,]],
         [["DicomAet" : "ORTHANC2",]],
         [["DicomPort" : 4244]],
         [["UnknownSopClassAccepted"            : true,]],
         '"OrthancPeers" : {\n  "peer1" : [ "http://localhost:8043/" ]',
         '"DicomModalities" : {\n    "ORTHANC1" : ["ORTHANC1", "localhost", 4243]'
      }
   }
   local s = readCfg()
   
   for k,v in ipairs(old) do
      s = s:gsub(v, new[i][k])
   end
   
   writeCfg(baseDir..i, s)
end

function readCfg() -- accept bin stream, path+fName
   local f = io.open(baseDir..'Configuration.json','r')
   local s = f:read('*a')
   f:close()
   return s
end

function writeCfg(...) -- accept bin stream, path+fName
   local f = io.open(arg[1]..'\\'..'Configuration.json','w')
   f:write(arg[2])
   f:close()
end

function executeCmd(cmdArg)
   local cmd = baseDir..'\\'..'orthancCmd.cmd '..cmdArg     
   execute(cmd)
end

function duplicateFile(...)
   assert(os.execute('copy /y /v /b '..arg[1]..'\\'..arg[3]..' '..arg[2]..'\\'..arg[3]))
end

function execute(cmd)
   local exitCodes = {
      [0]  = "Ran successfully: \r\n" .. cmd,
      [1]  = "Ran with error(s): \r\n" .. cmd,
      [12] = "Command is too long: \r\n" .. cmd,
      [99] = "etc."
   }
   local exitCode = os.execute(cmd)
   if exitCode ~= 0 then
      return false, exitCodes[exitCode]
      or "Failed with exit code "..exitCode..":\r\n"..cmd
   else
      return true, exitCodes[exitCode]
   end
end

return environmentBuilder
