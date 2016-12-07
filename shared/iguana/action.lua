-- Web Service utilities

-- For some examples see the iguana-webservices and iguana-excel repos

-- http://help.interfaceware.com/category/building-interfaces/repositories/builtin-iguana-webservices
-- http://help.interfaceware.com/category/building-interfaces/repositories/builtin-iguana-excel

local user = require "iguana.user"

local iguana_action = {}

local method = {}

local MT = {__index=method}

local function BaseUrl()
   local C = iguana.channelConfig{guid=iguana.channelGuid()}
   local X = xml.parse{data=C}
   return X.channel.from_http.mapper_url_path:S()
end

function iguana_action.create()
   local AT = {_actions={}, _priority={}}
   AT._baseurllength = #BaseUrl() +2
   setmetatable(AT, MT)
   return AT
end

local CreateHelp=[[{
   "Returns": [{"Desc": "Empty Actions table <u>table</u>."}],
   "Title": "actionTable.create",
   "Parameters": [],
   "ParameterTable": false,
   "Usage": "actionTable.create()",
   "Examples": [
      "local Dispatcher = actionTable.create()"
   ],
   "SeeAlso":[
      {
         "Title":"Source code for the iguana.action.lua module on github",
         "Link":"https://github.com/interfaceware/iguana-excel/blob/master/shared/iguana/action.lua"
      },
   ],
   "Desc": "Creates an empty Actions table."
}]]

help.set{input_function=iguana_action.create, help_data=json.parse{data=CreateHelp}}



function method:actions(T)
   if not T.group then 
      error("Need group", 2)
   end
   if not self._actions[T.group] then
      self._actions[T.group] = {}
   end
   self._priority[T.priority] = T.group
   return self._actions[T.group]
end

local ActionHelp=[[{
   "Returns": [{"Desc": "Action table for a particular group  <u>table</u>."}],
   "Title": "RequestInfo:actions",
   "Parameters": [
      { "group": {"Desc": "Group to return action table for <u>string</u>."}},
      { "priority" : { "Desc" : "The priority for this permission <u>integer</u>."}}],
   "ParameterTable": true,
   "Usage": "RequestInfo:actions{group=&lt;value&gt;, priority=&lt;value&gt;}",
   "Examples": [
      "local RequestInfo = iguana_action.create()
local ActionTable = RequestInfo:actions{group='Administrators'}"
   ],
   "SeeAlso":[
      {
         "Title":"Source code for the iguana.action.lua module on github",
         "Link":"https://github.com/interfaceware/iguana-excel/blob/master/shared/iguana/action.lua"
      },
   ],
   "Desc": "This method returns a table of actions for a given Group permission."
}]]

help.set{input_function=method.actions, help_data=json.parse{data=ActionHelp}}

function method:dispatch(T)
   local Request = T.path:sub(self._baseurllength)
   local User = user.open()
   for K,Group in ipairs(self._priority) do
      trace(K,Group)
      trace(self._actions[Group])
      if User:userInGroup{user=T.user, group=Group} then
       
         local Action = self._actions[Group][Request] 
         trace(Action)
         if Action then
            return Action
         end
      end
   end
   return nil
end

local DispatchHelp=[[{
   "Returns": [{"Desc": "Returns function action depending on the user and their permissions <u>table</u>."}],
   "Title": "RequestInfo:dispatch",
   "Parameters": [
      { "user" : { "Desc" : "User requesting path <u>string</u>."}},
      { "path": {"Desc": "Path for action <u>string</u>."}}],
   "ParameterTable": true,
   "Usage": "RequestInfo:actions{user=&lt;value&gt;, path=&lt;value&gt;}",
   "Examples": [
      "local UserInfo = user.open()
local ActionTable = RequestInfo:actions{group='Administrators'}"
   ],
   "SeeAlso":[
      {
         "Title":"Source code for the iguana.action.lua module on github",
         "Link":"https://github.com/interfaceware/iguana-excel/blob/master/shared/iguana/action.lua"
      },
   ],
   "Desc": "This method returns a table of actions for a given permission."
}]]

help.set{input_function=method.dispatch, help_data=json.parse{data=DispatchHelp}}

return iguana_action