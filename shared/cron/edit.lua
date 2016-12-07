-- This module allows one to programmatically read a cron tab and (gulp!) write to it.
-- Be cautious with writing to crontabs :-)

-- This code has only been tested under Linux

-- http://help.interfaceware.com/v6/cron-edit-crontab

local cron = {}

function cron.read()
   local P = io.popen("crontab -l")
   local C = P:read("*a")
   P:close()
   return C  
end

function cron.write(NewContent)
   if not iguana.isTest() then
      -- Write to standard output.
      local P = io.popen("crontab -", "w")
      P:write(NewContent)
      P:close()
   end   
end

local CronReadHelp=[[{
   "Returns": [{"Desc": "Returns contents of the current user crontab in string format <u>string</u>."}],
   "Title": "cron.read()",
   "Parameters": [],
   "ParameterTable": false,
   "Usage": "cron.read()",
   "Examples": ["-- Read, update and save changes to crontab
local Contents = cron.read()
-- Change contents
cron.write(Contents)
"
   ],
   "Desc": "This function loads the contents of the crontab file for the Iguana current user. It only works under operating systems like linux which support cron."
}]]

help.set{input_function=cron.read, help_data=json.parse{data=CronReadHelp}}

local CronWriteHelp=[[{
   "Returns": [],
   "Title": "cron.write()",
   "Parameters": [{"newContent":{"Desc": "New data to replace the current crontab contents  <u>string</u>."}}],
   "ParameterTable": false,
   "Usage": "cron.write(newContent)",
   "Examples": ["-- Read, update and save changes to crontab 
local Contents = cron.read()
-- Change crontab contents
cron.write(Contents)
"
   ],
   "Desc": "This function replaces the contents of the crontab file for the Iguana current user. It only works under operating systems like linux which support cron."
}]]

help.set{input_function=cron.write, help_data=json.parse{data=CronWriteHelp}}

return cron