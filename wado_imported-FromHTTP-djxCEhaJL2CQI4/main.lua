-- Developed and tested with Windows 7, 2012, and 10
-- Inspired by article "REST API of Orthanc" <https://orthanc.chu.ulg.ac.be/book/users/rest.html>
--
-- This Source Component script creates web GUI to set up example for CRUD operations implemented with WADO
-- The FIlter Component Script is actual example for WADO implementation

require 'wado-api'
require 'icm-webserver'


local WebServer = web.webserver.create{
   default = 'www/index.html',
   auth = false,
   actions = { 
      ["wado-api"] = api
   }
}

function main(Data)
   WebServer:serveRequest{data=Data} 
end



