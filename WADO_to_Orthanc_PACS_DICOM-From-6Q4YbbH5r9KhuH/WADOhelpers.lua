require 'urlcode'

local WADO = {}
local RESOURCE = 'http://localhost:8043/'
local MAXCHANGESTOLIST = 50

function readBinary(fName)
   local f=io.open(fName,'rb')
   local content = f:read('*a')
   f:close()
   return content
end


function writeBinary(d,fName)
   local f=io.open(fName,'wb')
   f:write(d)
   return f:close()
end


function concatArg(...)
   local uri = arg[1]
   for n = 2, arg.n do
      uri = uri..'/'..arg[n]   
   end
   return uri 
end

-- Public functions --

function WADO.listPACSresource(t)
   local R = {}
   for k,v in ipairs (t) do
      R[v] = WADO.listSingleResource(v)
   end
   return R 
end

function WADO.changes(count)
  count = count or MAXCHANGESTOLIST 
   return net.http.get{
      url=RESOURCE..'/changes',
      parameters={limit = count},
      live=true}
end


function WADO.acquireSingleResource(...)     
   local URL = RESOURCE..concatArg(...)
   urlcode.escape(URL)
   return net.http.get{url=URL, live=true}  
end


function WADO.retrieveFile(...)
   local a,b,c = WADO.acquireSingleResource(...)    
   if b == 200 then

      if c["Content-Type"] == 'application/dicom' then
         return 
         writeBinary(a,c["Content-Disposition"]:sub(11,-2)) and 
         c["Content-Disposition"]:sub(11,-2)

      elseif c["Content-Type"] == 'image/png' then
         -- preview image is 'unsupported' in Orthanc free version
         -- downloaded image file will contain picture placeholder
         return writeBinary(a,'Preview.png') and 'Preview.png'
      end
   end 
end

function WADO.pushCSTOREResources(...)
   local URL = RESOURCE..arg[1]..'/'..arg[2]..'/'..arg[3]
   local Body = arg[4]
   return net.http.post{url=URL, 
      body = Body,
      headers={['Content-Type']='application/dicom',
         ['Accept']='*/*'}, 
      live= true }
end

function WADO.pushResource2Orthanc(...)
   local URL = RESOURCE..arg[1]
   local Body = readBinary(arg[2])
   return net.http.post{url=URL, 
      body = Body,
      headers={['Content-Type']='application/dicom'}, 
      live= true }
end


function WADO.listSingleResource(...)
   return json.parse{data = WADO.acquireSingleResource(concatArg(...))} 
end

-- HELP definitions --

local HELP_DEF=[[{
"Desc": "List requested resources, to check if any are available in WADO enabled PACS, and return list of existing resources.",
"Returns": [{"Desc": "Returns table of available in WADO enabled PACS resources <u>table</u>."}],
"SummaryLine": "List resources available in WADO enabled PACS.",
"SeeAlso": [],
"Title": "listPACSresource",
"Usage": "WADO.listPACSresource(t)",
"Parameters": [
{"t": {"Desc": "List of resources to probe <u>table</u>."}}
],
"Examples": [
"<pre>WADO.listPACSresource(t)</pre>"
],
"ParameterTable": false
}]]

help.set{input_function=WADO.listPACSresource, help_data=json.parse{data=HELP_DEF}}

local HELP_DEF=[[{
"Desc": "List recent changes applied to WADO enabled PACS content.",
"Returns": [{"Desc": "Returns list of changes <u>JSON object</u>."}],
"SummaryLine": "List changes applied to WADO enabled PACS.",
"SeeAlso": [],
"Title": "WADO.changes",
"Usage": "WADO.changes(count)",
"Parameters": [
{"count": {"Opt":true, "Desc": "Default value is equal to MAXCHANGESTOLIST. It is maximum number of Changes to list <u>integer</u>."}}
],
"Examples": [
"<pre>WADO.changes(count)</pre>"
],
"ParameterTable": false
}]]

help.set{input_function=WADO.changes, help_data=json.parse{data=HELP_DEF}}

local HELP_DEF=[[{
"Desc": "Acquire raw DICOM file (or a standard graylevel PNG image) from WADO enabled PACS.",
"Returns": [{"Desc": "Successfully retrievied file name <u>string</u> or False <u>boolean</u>."}],
"SummaryLine": "Retrieve file from WADO enabled PACS.",
"SeeAlso": [],
"Title": "WADO.retrieveFile",
"Usage": "WADO.retrieveFile(resource, ID, 'file')",
"Parameters": [
{"resource": {"Desc": "Reserved uri extension, PACS resource name keyword 'instances' <u>string</u>."}},
{"ID": {"Desc": "PACS resource ID, specific 'instance' ID value <u>string</u>."}},
{"file": {"Desc": "Reserved uri extension. Use keyword 'file' to retrieve a raw DICOM file. Use keyword 'preview' to retrieve a standard graylevel PNG image <u>string</u>."}}
],
"Examples": [
"<pre>WADO.retrieveFile(resources[4], instance.ID, 'file')</pre>"
],
"ParameterTable": false
}]]

help.set{input_function=WADO.retrieveFile, help_data=json.parse{data=HELP_DEF}}

local HELP_DEF=[[{
"Desc": "Request WADO enabled PACS to do C-STORE. Send specific Resource/s) to remote AETitle.",
"Returns": [{"Desc": "Returns Request Data <u>string</u>, Request Code <u>string</u>, and Request Headers <u>table</u>."}],
"SummaryLine": "Request C-STORE.",
"SeeAlso": [],
"Title": "WADO.pushCSTOREResources",
"Usage": "WADO.pushCSTOREResources(resource, AETitle, action, JSONarray2store)",
"Parameters": [
{"resource": {"Desc": "Reserved uri extension, PACS resource name keyword 'modalities' <u>string</u>."}},
{"AETitle": {"Desc": "Destination AETitle, to send the resource to <u>string</u>."}},
{"action": {"Desc": "Reserved uri extension keyword 'store' <u>string</u>."}},
{"JSONarray2store": {"Desc": "JSON array of resource ID values <u>JSON array</u>."}}
],
"Examples": [
"<pre>WADO.pushCSTOREResources('modalities', modalities[1], 'store', JSONlist2store)</pre>"
],
"ParameterTable": false
}]]

help.set{input_function=WADO.pushCSTOREResources, help_data=json.parse{data=HELP_DEF}}

local HELP_DEF=[[{
"Desc": "Sequentially concatenate provided arguments to create RFC 2396 compliant URL, and do HTTP GET call. URL need to compy with WADO enabled PACS documentation.",
"Returns": [{"Desc": "Returns Request Data <u>string</u>, Request Code <u>string</u>, and Request Headers <u>table</u>."}],
"SummaryLine": "Acquire single resource from WADO enabled PACS.",
"SeeAlso": [],
"Title": "WADO.acquireSingleResource",
"Usage": "WADO.acquireSingleResource(arg1, arg2, arg3, ... argN)",
"Parameters": [
{"arg1": {"Desc": "First argument to start URL with <u>string</u>."}},
{"argN": {"Opt":true, "Desc": "Last argumnet ro conclude URL <u>string</u>."}}
],
"Examples": [
"<pre>WADO.acquireSingleResource(resources[4], instance.ID, 'content', '0010-0010')</pre>"
],
"ParameterTable": false
}]]

help.set{input_function=WADO.acquireSingleResource, help_data=json.parse{data=HELP_DEF}}

local HELP_DEF=[[{
"Desc": "Parse JSON array of property values returned for single specified resource by WADO enabled PACS.",
"Returns": [{"Desc": "List of values <u>list</u>."}],
"SummaryLine": "Parse JSON array returned for single resource from WADO enabled PACS.",
"SeeAlso": [],
"Title": "WADO.listSingleResource",
"Usage": "WADO.listSingleResource(resource, <ID>, <keyword>, ...)",
"Parameters": [
{"resource": {"Desc": "Reserved uri extension, PACS resource name keyword 'patients','studies','series','instances <u>string</u>."}},
{"ID": {"Opt":true, "Desc": "PACS resource specific ID, e.g. specific 'instance' ID value <u>string</u>."}},
{"keyword": {"Opt":true, "Desc": "Reserved uri extension. Example of some keywords 'simplified-tags', 'tags', 'content'. Refer to WADO enabled PACS documentation <u>string</u>."}}
],
"Examples": [
"<pre>WADO.listSingleResource(resources[4],instance.ID,'content')</pre>"
],
"ParameterTable": false
}]]

help.set{input_function=WADO.listSingleResource, help_data=json.parse{data=HELP_DEF}}

local HELP_DEF=[[{
"Desc": "Store DICOM file to Orthanc.",
"Returns": [{"Desc": "Returns Request Data <u>string</u>, Request Code <u>string</u>, and Request Headers <u>table</u>."}],
"SummaryLine": "Store DICOM file to Orthanc.",
"SeeAlso": [],
"Title": "WADO.pushResource2Orthanc",
"Usage": "WADO.pushResource2Orthanc(resource, file)",
"Parameters": [
{"resource": {"Desc": "Reserved uri extension, PACS resource name keyword 'instances' <u>string</u>."}},
{"file": {"Desc": "Filename with path <u>string</u>."}}
],
"Examples": [
"<pre>w.pushResource2Orthanc('instances',file2modifyLocally)</pre>"
],
"ParameterTable": false
}]]

help.set{input_function=WADO.pushResource2Orthanc, help_data=json.parse{data=HELP_DEF}}

return WADO, RESOURCE