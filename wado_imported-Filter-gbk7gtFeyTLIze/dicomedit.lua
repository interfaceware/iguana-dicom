dicomedit = {}

-------------------------------------------------
-- For a verbose description of the following, --
-- see http://wiki.interfaceware.com/640.html  --
-------------------------------------------------
-- We use trace() function only for to visualize content of varibles

-- Some lines commented out because we don't add in this example error handlers to check
-- for existense of initially nil values. Without error handlers, various missing data 
-- elements may trigger an error. If you will use will test ths example with 
-- file 'sample.dcm' <http://help.interfaceware.com/files/1647/sample.dcm> from our Wiki, 
-- then all lines will have data to compute, and will be no need to comment out some.

require 'dicom'

function dicomedit.edit(path)
   local user = 'admin'  -- *** USE YOUR USERNAME HERE ***
   path = path or 'edit/'..user..'/other/sample.dcm'
   -- file 'sample.dcm'is available from our Wiki
   -- <http://help.interfaceware.com/files/1647/sample.dcm>
   
   -- Loading DICOM Files  
   local d = dicom.load(path)
   trace(type(d.AccessionNumber))
   
   -- Modify Existing Values without Changing VRs
   --trace(d.AcquisitionNumber.value)
   --d.AcquisitionNumber.value = 10
   --trace(d.AcquisitionNumber.value)
   
   -- Modify or Create Elements with Default VR
   d.AcquisitionNumber = 20  -- Omit .value part.
   trace(d.AcquisitionNumber.value)
   
   -- Modify or Create Elements with Specific VR
   trace(d.AcquisitionNumber.vr)
   d.AcquisitionNumber = { value=2, vr='SS' }
   trace(d.AcquisitionNumber.value)
   trace(d.AcquisitionNumber.vr)
   
   -- Modify VR without Changing Value
   d.AcquisitionNumber.vr = 'IS'
   trace(d.AcquisitionNumber.value)
   
   -- Examining Multiple Values (when VM > 1)
   local function values(dcm)
      return dcm.value:gmatch('[^\\]+')
   end 
   --trace(d.ImageOrientationPatient.value)
   --trace(d.ImageOrientationPatient.vm)
   --for x in values(d.ImageOrientationPatient) do
   --   trace(x)
   --end
   
   -- Iterate over Sequences  
   --for i,v in d.SourceImageSequence:ipairs() do
   --   trace(i,v.ReferencedSOPClassUID.value)
   --end
   
   -- Insert Items into Sequences   
   --local n = d.SourceImageSequence:length()
   --local old = d.SourceImageSequence[1]
   --local new = d.SourceImageSequence:insert(n+1)
   --new.ReferencedSOPClassUID = old.ReferencedSOPClassUID
   --trace(old.ReferencedSOPClassUID.value, old)
   --trace(new.ReferencedSOPClassUID.value, new)
   
   -- Remove Items from Sequences
   --d.SourceImageSequence:remove(n+1)
   local _, err = pcall(function()
         trace(new.ReferencedSOPClassUID)
      end)
   trace(err)
   
   -- Accessing DICOM Meta-data
   local m = d.meta()
   trace(m.TransferSyntaxUID.value)
   
   -- Saving modified DICOM Files to local folder
   local live = true
   if live then
      d:save(path)
   end
   
   -- return modified DICOM file
   return path
end

return dicomedit