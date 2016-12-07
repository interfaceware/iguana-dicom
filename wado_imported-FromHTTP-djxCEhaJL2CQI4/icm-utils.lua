-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-install-linux-cron.lua
--
--   description:
--      - Common  routines that say where things are located, OS type etc.
--        We should be running under the  home directory of the Iguana user
--        we are using in Linux.
-- 
--   author:
--     Eliot Muir
--
-- **********************************************************************

local utils = {}

require 'iguana.info'

local Info = iguana.info()

-- Common  routines that say where things are located, OS type etc.  We should be running under the
-- home directory of the Iguana user we are using in Linux.

function utils.isWindows()
   return Info.os == "windows"
end

function utils.isLinux()
   return Info.os == "linux"
end

function utils.is64Bit()
   return Info.cpu == '64bit'
end

function utils.is32Bit()
   return Info.cpu == '32bit'
end

function utils.root()
   if utils.isWindows() then
      return os.getenv('ProgramFiles')..'/iNTERFACEWARE/'      
   else 
      return os.getenv('HOME')..'/'
   end
end

function utils.application()
   if utils.isWindows() then
      return os.getenv('ProgramFiles')..'/iNTERFACEWARE/Iguana-6/'      
   else 
      return os.getenv('HOME')..'/Iguana-6/'
   end
end

function utils.releases()
   if utils.isWindows() then
      return os.getenv('ProgramFiles')..'/iNTERFACEWARE/Iguana-6/Releases/'      
   else 
      return os.getenv('HOME')..'/Iguana-6/Releases/'
   end
end

function utils.applicationVersion(Version)
   return utils.releases() .. Version..'/'
end

function utils.currentVersion()
   local T = iguana.version()
   return T.major .. "." .. T.minor.."."..T.build
end

function utils.versionString(Version)
   if not Version then
      error("Need version")
   end
   return Version:gsub("%.", "_")
end

function utils.versionDotString(Version)
   if not Version then
      error("Need version")
   end
   return Version:gsub("%_", ".")
end

function utils.create(Dir)
   local Stats = os.fs.stat(Dir)
   if Stats == nil then
      trace("Create tar ball dir")
      os.fs.mkdir(Dir, 700)
   end
   Stats = os.fs.stat(Dir)
   if not Stats.isdir then
      error(utils.. ' is not a directory')
   end
end

function utils.dashboardUrl(R)
   if iguana.webInfo().web_config.use_https == true then
      return "https://"..
      R.headers.Host:gsub(iguana.webInfo().https_channel_server.port, 
         iguana.webInfo().web_config.port)..'/'   
   else
      return "http://"..
      R.headers.Host:gsub(iguana.webInfo().https_channel_server.port, 
         iguana.webInfo().web_config.port)..'/'
   end
end

return utils