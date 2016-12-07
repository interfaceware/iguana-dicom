-- This module will load sample data into first ORTHANC instance

local wado_utils = require 'wado-utils'

local function readZip() -- expect binary file
   local f = io.open(wado_utils.application()..'pacsdata.zip','rb')
   local b = f:read('*a')
   f:close()
   return b
end

local function postExamples(v)
   local a,b,c,d = net.http.post{
      url='http://localhost:8043/instances ', 
      headers={['Content-Type']='application/dicom', ['Accept']='*/*'},
      body=v,
      timeout=1800, 
      debug = true, 
      live=true}
   return
end

local function postExamples2ORTHANC1()  
   -- unzip sample data, to be imported to PACS
   local unzip = filter.zip.inflate(readZip())
   for k,v in pairs(unzip) do
      postExamples(v)
      util.sleep(3000) -- allow Orthanc to complete last import
   end
end

function wado_cstore_samples()
   postExamples2ORTHANC1()
   STATUS["cstore"]=true
   return { ["status"]="ok" }
end
