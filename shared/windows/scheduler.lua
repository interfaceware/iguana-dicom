local XmlTemplate=[[
<?xml version="1.0" encoding="UTF-8"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>#TIMESTAMP#</Date>
    <Author>#USER#</Author>
    <Description>Change Iguana service</Description>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <StartBoundary>#TIMESTAMP#</StartBoundary>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>#USER#</UserId>
      <LogonType>Password</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>"#COMMAND#"</Command>
      <WorkingDirectory>#WORKING_DIR#</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
]]

local function RunCommand(Command)
   local P = io.popen(Command, "r")
   local C = P:read("*a")
   P:close()
   return C
end

local function ScheduleTask(T)
   local WorkingDir = T.working_dir
   local Command    = T.command   
   local TimeDelay  = T.delay or 2
   local TaskName   = T.taskname or "iguana_task"
   local Username   = T.user
   local Password   = T.password
   
   local Config = xml.parse{data=XmlTemplate}
   
   Config.Task.Actions.Exec.Command[1] = '"'..Command..'"'
   Config.Task.Actions.Exec.WorkingDirectory[1] = WorkingDir
   Config.Task.Principals.Principal.UserId[1] = Username
   Config.Task.RegistrationInfo.Author[1] = Username
   
   -- We schedule the restart after the time delay
   local TimeStamp = os.ts.date('%Y-%m-%dT%H:%M:%S', os.ts.time() + TimeDelay)  
   Config.Task.RegistrationInfo.Date[1]= TimeStamp..".0000000"
   Config.Task.Triggers.TimeTrigger.StartBoundary[1] = TimeStamp
   trace(Config)
   local Flatwire = Config:S():gsub("&quot;", '"')
   trace(Flatwire)
   local TempName = os.tmpname()
   local F = io.open(TempName, "w")
   F:write(Flatwire)
   F:close()
   local Command = "schtasks /create /tn "..TaskName.." /XML "..TempName
     ..' /RU "'..Username..'"'
   if Password then 
      Command = Command..' /RP "'..Password..'"'
   end
   Command = Command.. " /F 2>&1"
   trace(Command)
   local Result
   if not iguana.isTest() then
      Result = RunCommand(Command)
   else
      Result = "Not running scheduled task in editor"
   end
   os.remove(TempName)
   return Result
end

local HelpText=[[{
   "Returns": [{"Desc": "Output that came from the invoking the scheduler 'string'"}],
   "Title": "ScheduleTask",
   "Parameters": [
      {"command"    : {"Desc": "Command to run."}},
      {"working_dir": {"Desc": "Directory in which to run the command."}},
      {"time_delay" : {"Opt" : true, "Desc": "Seconds to wait (default 2) before running the command."}},
      {"task_name"  : {"Opt" : true, "Desc": "Name of the task.  Default is 'iguana_task'."}},
      {"user"       : {"Desc": "Windows user name to run command under."}},
      {"password"   : {"Desc": "Password of windows user to run command under."}} 
   ],
   "ParameterTable": true,
   "Usage": "ScheduleTask{command='run.bat', working_dir='C:\\temp\\', user='admin', password='secret'}",
   "Examples": [
      "local ResultOut = ScheduleTask{commmand='run.bat', working_dir='C:\\temp', time_delay=10, 
                           task_name='run_task', user='admin', password='secret'}"
   ],
   "Desc": "Sets up a scheduled task with the windows task scheduler."
}
]]

help.set{input_function=ScheduleTask, help_data=json.parse{data=HelpText}}

return ScheduleTask