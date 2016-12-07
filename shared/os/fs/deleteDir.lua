-- This recurisive routine will go through and delete a directory in production at least.
-- It's main advantage is the code should be portable across Windows/Linux and OS X.
-- In test it does nothing.

local function DeleteDir(T)
   local Dir = T.dir
   trace(Dir)
   for Name, Info in os.fs.glob(Dir..'/*') do
      trace(Name)
      if Info.isdir then
         DeleteDir{dir=Name}
      else
         if not iguana.isTest() then
            os.remove(Name)
         end
      end
   end
   for Name, Info in os.fs.glob(Dir..'/.*') do
      trace(Name)
      if Info.isdir then
         DeleteDir{dir=Name}
      else
         if not iguana.isTest() then
            os.remove(Name)
         end
      end
   end
   if not iguana.isTest() then
      os.fs.rmdir(Dir)
   end
end

return DeleteDir