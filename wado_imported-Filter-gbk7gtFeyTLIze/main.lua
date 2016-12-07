local EXECUTE = true
-- Change 'EXECUTE' into 'true', to allow execution of this script.
--
-- Sample WADO implementation for CRUD operations 
-- Before proceeding, please refer to README.lua on the left side
--
-- Developed and tested with Windows 7, 10, and Server 2012
-- Lev Blum, July 2016
-- Inspired by article "REST API of Orthanc" <https://orthanc.chu.ulg.ac.be/book/users/rest.html>
--
-- Includes example how to edit DICOM raw file tags in Translator script itself using Iguana's dicom.dll. 
-- Function call and 'require' lines are commented out, and it has to wait until DLL for Iguana 6.x becomes available. 

-- In order to focus on clarity of examples, error handlers not included in sample code.

-- Loading iNTERFACEWARE's dicom_raw.dll may require to have mscvrt120.dll installed on your Windows OS. 
-- "Visual C++ Redistributable Packages for Visual Studio 2013" can be 
-- downloaded from https://www.microsoft.com/en-ca/download/details.aspx?id=40784


local w, RESOURCE = require 'WADOhelpers'
local resources = {'patients','studies','series','instances'}

-- next line shows usage of iNTERFACEWARE DICOM DLL file
local dicomedit = require 'dicomedit'

function main()
   if EXECUTE then
      mainWADOexample()
   end
end


function mainWADOexample()
   -- list all of the PACS resources
   local R = w.listPACSresource(resources)

   -- list Nth (1st) single resource from Patients
   local patient = w.listSingleResource(resources[1], R.patients[1])

   -- list Nth (1st) resource from Studies for given Patient
   local studies = w.listSingleResource(resources[2],patient.Studies[1])

   -- list Nth (1st) resource from Series for given Study
   local series = w.listSingleResource(resources[3],studies.Series[1])

   -- list Nth (1st) resource from Instances for given Series
   local instance =  w.listSingleResource(resources[4],series.Instances[1])

   -- acquire DICOM file from PACS   
   local file2modifyLocally = w.retrieveFile(resources[4], instance.ID, 'file')
   if not file2modifyLocally then 
      reportRetrieveFileFailure(instance.ID) 
   else
      -- modify DICOM file Tags using Iguana's DLL
      file2modifyLocally = dicomedit.edit(iguana.workingDir()..file2modifyLocally)
   end

   -- push modified file back to Orthanc
   local RData,RCode,RHeaders=w.pushResource2Orthanc('instances',file2modifyLocally)

   -- acquire preview PNG image from PACS
   -- free version Orthanc doesn't support 'preview' images
   -- retrieved image will contain a place holder
   if not w.retrieveFile(resources[4], instance.ID, 'preview') then 
      reportRetrieveFileFailure(instance.ID) 
   end

   -- retrieve the hierarchy of all the DICOM tags for Instance identified by ID
   local tags = w.listSingleResource(resources[4],instance.ID,'simplified-tags')

   -- retrieve hexadecimal indexes of DICOM tags for Instance identified by ID
   local hextags = w.listSingleResource(resources[4], instance.ID, 'tags')

   -- access the raw value of DICOM tag '0010-0010', AKA 'PatientName' 
   local PatientName = w.acquireSingleResource(resources[4], instance.ID, 'content', '0010-0010')

   -- retrieve list of DICOM hexadecimal tags, available with given Instance
   local ListOfHexTags = w.listSingleResource(resources[4],instance.ID,'content')

   -- recursively drill down through sequences of tags to find 'ImageType' 'Value'
   local ImgTypeValue = w.acquireSingleResource(resources[4], instance.ID,'content',ListOfHexTags[2])

   -- Alternative method, if 'hextags' List is already known. 
   -- Use Autocompletion "." operator.  
   -- We use trace() function only for to visualize content of a varible
   ImgTypeValue = hextags["0008,0008"].Value
   trace(ImgTypeValue) 

   -- Query list of known to WADO server Modalities
   local modalities = w.listSingleResource('modalities')

   -- Send specific Study/s (resource/s) to remote AETitle; with Error reporting.
   local JSONarray2store = json.serialize{data={instance.ID}} -- 'data' allows List of ID values.
   -- When resources listed in JSON array, then single DICOM connection is used (Orthanc specific.)
   local RData,RCode,RHeaders=w.pushCSTOREResources('modalities',modalities[1],'store',JSONarray2store)
   if RData == nil then 
      reportCStoreFailure(JSONarray2store, RCode, RHeaders)
   end

   -- Track changes
   local Changes = json.parse{data = w.changes()}
end

-- Utility functions to report failures --
function reportCStoreFailure(...)
   iguana.logError(
      "Failed to push resource: "..tostring(arg[1])..
      '\nResponce Code: '..arg[2]..
      '\nRequestOrStatusLine: '..arg[3]['RequestOrStatusLine']..
      '\nResponse: '..arg[3]['Response'])
end

function reportRetrieveFileFailure(s)
   iguana.logError(
      "Failed to retrieve image or preview PNG image\n 'Instance': "..s) 
end
