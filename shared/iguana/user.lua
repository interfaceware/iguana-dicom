local user = {}

local method = {}

local MT = {__index=method}

-- Load and parse the IguanaConfiguration file for group information
local function LoadUserPermissions()
   local Reg = {}
   Reg._user = {}
   local Path = iguana.workingDir()..'IguanaConfigurationRepo/IguanaConfiguration.xml'
   local F = io.open(Path, "r")
   local C = F:read("*a")
   F:close()
   local X = xml.parse{data=C}

   for g=1, X.iguana_config.auth_config:childCount("group") do
      Reg[X.iguana_config.auth_config:child("group",g).name:S()] = {}
   end
   trace(Reg)
   
   for i=1, X.iguana_config.auth_config:childCount("user") do
      local U = X.iguana_config.auth_config:child("user", i)
      Reg._user[U.name:S()] = {email=U.email_address:S()}
      for g=1, U:childCount("group") do
         Reg[U:child("group", g).name:S()][U.name:S()] = true
      end
   end
   trace(Reg) 
   return Reg
end


function user.open()
   local R = {}
   setmetatable(R, MT)
   MT.info = LoadUserPermissions()   
   return R
end

local OpenHelp=[[{
   "Returns": [{"Desc": "Returns a table of functions to query user permissions <u>table</u>."}],
   "Title": "user.open",
   "Parameters": [],
   "ParameterTable": false,
   "Usage": "user.open()",
   "Examples": [
      "local UserInfo = user.open()
if UserInfo:userInGroup{user='fred', group='Users'} then
   trace('Yes - he is a user!')
end"
   ],
   "SeeAlso":[
      {
         "Title":"Source code for the iguana.action.lua module on github",
         "Link":"https://github.com/interfaceware/iguana-excel/blob/master/shared/iguana/action.lua"
      },
   ],
   "Desc": "This function loads the Iguana user database and allows one to query roles."
}]]

help.set{input_function=user.open, help_data=json.parse{data=OpenHelp}}


function method:userInGroup(T)
   local User = T.user
   local Group = T.group
   local Info = getmetatable(self).info
   if not Info[Group] then
      return false
   end
      
   return Info[Group][User] or false
end

local UserInGroupHelp=[[{
   "Returns": [{"Desc": "Returns true if the User is a member of the specified Group <u>boolean</u>."}],
   "Title": "UserInfo:userInGroup",
   "Parameters": [
      { "user": {"Desc": "Name of the Iguana User to check <u>string</u>."}},
      { "group": { "Desc": "Name of the Iguana Group to check for membership of <u>string</u>."}}],
   "ParameterTable": true,
   "Usage": "UserInfo:userInGroup{user=&lt;value&gt;, group=&lt;value&gt}",
   "Examples": [
      "local UserInfo = user.open()
if UserInfo:userInGroup{user='fred', group='Users'} then
   trace('Yes - he is a user!')
end"
   ],
   "SeeAlso":[
      {
         "Title":"Source code for the iguana.user.lua module on github",
         "Link":"https://github.com/interfaceware/iguana-excel/blob/master/shared/iguana/user.lua"
      },
   ],
   "Desc": "Confirms if an Iguana User belongs to a Group."
}]]

help.set{input_function=method.userInGroup, help_data=json.parse{data=UserInGroupHelp}}

function method:user(T)
   local User = T.user
   local Info = getmetatable(self).info
   return Info._user[User]
end

local UserHelp=[[{
   "Returns": [{"Desc": "A table of user information (currently only email is included)  <u>table</u>."}],
   "Title": "UserInfo:user",
   "Parameters": [
      { "user": {"Desc": "Name of user to check <u>string</u>."}}],
   "ParameterTable": true,
   "Usage": "UserInfo:user{user=&lt;value&gt;}",
   "Examples": [
      "local UserInfo = user.open()
local Info = UserInfo:user{user='fred'}
if (Info) then
   trace('Email is Info.email')
end"
   ],
   "SeeAlso":[
      {
         "Title":"Source code for the iguana.user.lua module on github",
         "Link":"https://github.com/interfaceware/iguana-excel/blob/master/shared/iguana/user.lua"
      },
   ],
   "Desc": "This method returns a table of information on a specified Iguana User. <br><br>
<b>Note:</b> Currently the returned table only contains a single field for the email address."
}]]

help.set{input_function=method.user, help_data=json.parse{data=UserHelp}}

return user