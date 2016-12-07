-- This module contains various Helper utilites relevant to this WADO example

local icm_utils = require 'icm-utils'

local utils = {}
local baseDir = 'wadointegration'

function utils.application()
   if icm_utils.isWindows() then
      return os.getenv('HOMEDRIVE')..os.getenv('HOMEPATH')..'\\'..baseDir..'\\'      
   else 
      return os.getenv('HOME')..'/'..baseDir..'/'
   end
end

function utils.root()
   if icm_utils.isWindows() then
      return os.getenv('HOMEPATH')..'\\'     
   else 
      return os.getenv('HOME')..'\\'
   end
end

function utils.create(Dir)
   local Stats = os.fs.stat(Dir)
   if Stats == nil then
      os.fs.mkdir(Dir, 700)
   end
   Stats = os.fs.stat(Dir)
   if not Stats.isdir then
      error(utils.. ' is not a directory')
   end
end

function utils.execute(cmd)
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

return utils