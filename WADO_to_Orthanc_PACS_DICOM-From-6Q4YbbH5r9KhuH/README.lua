--             README 
--             ------
-- 
-- 1. Import this channel to local Iguana instance
--	2. Launch this channel
--	3. Open Internet Browser window to ORTHANC1 at http://localhost:8043
-- Monitor ORTHANC1 Dashboard to show it received Sample data
-- 4. Once ORTHANC1 Dashboard shows it received Sample data, stop this channel
-- 5.  Open Internet Browser window to ORTHANC2 at http://localhost:8044
-- Note that ORTHANC2 Dashboard shows it has no Patients data
--	6. Open this project in Translator IDE and display main.lua
--	7. Execute this project in Translator IDE and monitor Annotations for how things get calculated 
-- 8. Refresh and Inspect ORTHANC2 Browser window
-- Note how Iguana made ORTHANC1 to perform CSTORE to ORTHANC2
--
--
--
--
--                          Players Diagram
--                          ---------------
--
--          ------------------                             -------------------
--          |    ORTHANC1    |     ---> C-STORE -->        |    ORTHANC2     |
--          ------------------                             -------------------
--                  ^
--                  ^
--        web calls utilizing WADO
--                  ^
--                  ^
--          -------------------
--          |    IGUANA       |
--          -------------------
--
--
--
--  To reset environment execute "as Admin":
--  c:\> taskkill /IM Orthanc-1.0.0-Release.exe  /f
--  c:\> rmdir c:\temp\pacs\ /s /q
--  Now steps from 2 to 8 can be repeated.