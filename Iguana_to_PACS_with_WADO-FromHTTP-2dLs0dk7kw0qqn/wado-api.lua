require 'iguana.info'
require 'wado-build-env'
require 'wado-cstore-samples'
require 'wado-fetch-files'
require 'wado-launch-editor'
require 'wado-reset-example'
require 'net.http.cache'

local display = require 'wado-installation-status'
local wado_utils = require 'wado-utils'

function api(R,A)   
   if R.params.action == "wado-installation-status" then      
      return display.api_status(R,A)    
   elseif R.params.action == "wado-fetch-files" then 
      return wado_fetch_files(R,A)        
   elseif R.params.action == "wado-build-env" then 
      return wado_build_env(R,A)
   elseif R.params.action == "wado-cstore-samples" then 
      return wado_cstore_samples(R,A)  
   elseif R.params.action == "wado-launch-editor" then 
      return wado_launch_editor(R,A)  
   elseif R.params.action == "wado-reset-example" then 
      return wado_reset_example(R,A)  
   end
   return display.api_status(R,A) 
end
