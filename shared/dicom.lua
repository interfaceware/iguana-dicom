require 'dicom_raw'
local dicom_raw = _G.dicom_raw
_G.dicom_raw = nil

local load_help = [[Usage: dicom.load(path [,options])

Load a DICOM file.  Requires:
   path - the name of the DICOM file to load.

A table of options may also be specified to control loading:
   transfer_syntax  - the transfer syntax to assume instead of auto-detecting.
   grp_len_encoding - how to handle group-length tags: 'no-change' (the default),
                      'without-GL' (remove them), 'with-GL' (keep or add them),
                      'recalc-GL' (recalculate existing, add missing).
   read_mode        - how to interpret the file: 'auto' (the default),
                      'dataset' (a dataset without file-meta), 'whole-file'
                      (a standard DICOM file with file-meta), 'meta-only'
                      (ignore dataset, just load file-meta).

Returns a DICOM file object.

e.g. local x = dicom.load('d:\\sample.dcm', {read_mode='meta-only'})
     if need_to_load(x) then
        x = dicom.load('d:\\sample.dcm')  -- load everything
     end
]]

local save_help = [[Usage: dicom_file:save(path, [,options])

Save a DICOM file.  Requires:
   dicom_file - a DICOM file object.
   path       - the name of the DICOM file to create.

A table of options may also be specified to control saving:
   encoding_type    - either 'explicit-length' or 'undefined-length' (the default).
   grp_len_encoding - how to handle group-length tags: 'without-GL' (don't write),
                      'with-GL' (add missing), 'recalc-GL' (recompute; the default).
   padding_tags     - how to handle padding tags: 'no-change' (the default),
                      'without-padding' or 'with-padding' (remove or insert tags).
   write_mode       - control the file format written: 'file-format' (the default;
                      standard DICOM file-format; missing meta data is added),
                      'dataset' (only write the dataset, no meta), 'update-meta'
                      (include normal meta information, updated as required),
                      'create-new-meta' (discard existing), or 'do-not-update-meta'.
   dataset_padding  - number of bytes to pad out the dataset (must be even).
   item_padding     - number of bytes to pad out each item (must be even).

e.g. local x = dicom.load('d:\\sample.dcm')
     x:save('d:\\sample-dataset.dcm', {write_mode='dataset'})
]]

local meta_help = [[Usage: dicom_file:meta()

Returns the meta-data of a DICOM file.  Requires:
   dicom_file - a DICOM file.

e.g. local x = dicom.load('d:\\sample.dcm')
     local m = x:meta()
]]

local insert_help = [[Usage: seq:insert(index)

Create a new sequence item at index.  Requires:
   seq   - a DICOM sequence.
   index - the position at which the new item should be.

Returns the new item.  If index > seq:length()+1, additional
items will be created to fill in the space.

e.g. local l = seq:length()
     local x = seq:insert(l+2)  -- append two new items
]]

local remove_help = [[Usage: seq:remove(index)

Remove a sequence item.  Requires:
   seq   - a DICOM sequence.
   index - the position of the item to remove.

e.g. seq:remove(seq:length())  -- remove the last item
]]

-- Call a function but throw errors
-- as if called so far up the stack.
local function upcall(up, f, ...)
   local out = { pcall(f,...) }
   if out[1] then
      return unpack(out, 2)
   else
      error(out[2], up+1)
   end
end

-- Call f(...) but if something goes
-- wrong append doc to the error.
local function help_call(doc, f, ...)
   local out = { pcall(f,...) }
   if out[1] then
      return unpack(out, 2)
   else
      error(out[2]..'\n\n'..doc, 3)
   end
end

-- For iteration over a raw DICOM
-- object.
local function dcm_pairs(dcm)
   local keys = dicom_raw.keys(dcm)
   return function(s)
      local k = keys[s.i]
      if k then
         s.i = s.i + 1
         return k, dcm[k]
      end
   end, { i=1 }
end

-- Replaces __index and __newindex when objects are invalidated.
local function invalid()
   error('This reference was invalidated by another change.', 2)
end

-- Invalidate a wrapped DICOM object when a
-- parent is changed.
local function invalidate(x)
   local f = (getmetatable(x) or {}).invalidate
   if f then f(x) end
end

-- Wrap the value table so that users can assign
-- directly to 'value' or 'vr', preserving the
-- other value.  Shorthand, really.
local function wrapValue(dcm, key, tbl)
   local meta = {
      __index = tbl;
      __newindex = function(self, k, v)
         if k == 'value' then
            dcm[key] = { value=v, vr=self.vr }
         elseif k == 'vr' then
            dcm[key] = { value=self.value, vr=v }
         elseif k == 'vm' then
            error('VM cannot be set directly')
         else
            error('unknown field: '..k)
         end
         -- Update values in tbl, don't replace it.
         for k,v in pairs(dcm[key]) do
            tbl[k] = v
         end;
      end;
      invalidate = function(self)
         local m = getmetatable(self) or {}
         m.__index    = invalid
         m.__newindex = invalid
      end;
   }
   return setmetatable({}, meta)
end

-- Method to iterate over the key/element
-- pairs of an item.
local function itemMethods(dcm)
   return {
      pairs = function(self)
         local tbl = getmetatable(self).__index
         local f,s,k = pairs(tbl)
         return function()
            local v
            repeat k,v = f(s,k) until k ~= 'pairs'
            return k,v
         end
      end;
   }
end

-- Methods to insert() and remove() items from
-- sequences, compute their length() or iterate
-- over their ipairs().
local wrap
local function sequenceMethods(dcm)
   return {
      insert = function(self, i)
         local new = help_call(insert_help, dicom_raw.insertItem, dcm, i)
         local tbl = getmetatable(self).__index
         for j = #tbl+1, i-1 do
            local x = dcm[j]
            table.insert(tbl, j, wrap(x, itemMethods(x)))
         end
         table.insert(tbl, i, wrap(new, itemMethods(new)))
         return tbl[i]
      end;
      remove = function(self, i)
         help_call(remove_help, dicom_raw.removeItem, dcm, i)
         local tbl = getmetatable(self).__index
         invalidate(table.remove(tbl, i))
      end;
      length = function(self)
         return #dcm
      end;
      ipairs = function(self)
         local tbl = getmetatable(self).__index
         return ipairs(tbl)
      end;
   }
end

local function checkValue(tbl)
   -- Other types are checked in dicom_raw.
   if type(tbl) == 'table' then
      for k,v in pairs(tbl) do
         if k == 'vm' then
            error('VM cannot be set directly')
         elseif k ~= 'value' and k ~= 'vr' then
            error('unknown field: '..tostring(k))
         end
      end
   end
end

-- Wrap a raw DICOM object to make things
-- a bit easier on users (maybe).  Applies
-- recursively to the entire tree.
wrap = function(dcm, tbl)
   local function set(k,v)
      local t = type(v)
      if t == 'userdata' then
         if type(k) == 'number' then
            v = wrap(v, itemMethods(v))
         else
            v = wrap(v, sequenceMethods(v))
         end
      elseif t == 'table' then
         v = wrapValue(dcm, k, v)
      end
      tbl[k] = v
   end
   for k,v in dcm_pairs(dcm) do
      set(k,v)
   end
   local meta = {
      __index = tbl;
      __newindex = function(self, k, v)
         upcall(2, function()
            checkValue(v)
            dcm[k] = v
         end)
         invalidate(tbl[k])
         set(k, dcm[k])
      end;
      invalidate = function(self)
         local m = getmetatable(self) or {}
         m.__index    = invalid
         m.__newindex = invalid
         for k,v in pairs(tbl) do
            invalidate(v)
         end
      end;
   }
   return setmetatable({}, meta)
end

-- Wraps the root node of a raw DICOM object,
-- adding the save() and meta() methods.  Meta()
-- can be used to get the file-meta information
-- when read from the DICOM file.
local function wrapTop(dcm)
   local methods = itemMethods(dcm)
   function methods.save(self, ...)
      return help_call(save_help, dicom_raw.save, dcm, ...)
   end
   function methods.meta(self, ...)
      local x = help_call(meta_help, dicom_raw.meta, dcm, ...)
      return wrap(x, itemMethods(x))
   end
   return wrap(dcm, methods)
end

dicom = {}
function dicom.load(...)
   return wrapTop(help_call(load_help, dicom_raw.load, ...))
end
