--             README 
--             ------
-- 
-- 1. Import this channel to local Iguana instance
--	2. Launch this channel
--	3. Open Internet Browser window to "URL path" in "From HTTPS" Source component configuration page. 
-- 4. Follow instructions on 'Configuration for WADO integration example' web page.
--
--
--
--
--                          Players Diagram
--                          ---------------
--
--          -------------------
--          |    IGUANA       |
--          -------------------
--                 √
--                 √
--        web calls utilizing WADO
--                 √
--                 √
--          ------------------                             -------------------
--          |    ORTHANC1    |     ---> C-STORE -->        |    ORTHANC2     |
--          ------------------                             -------------------
-- 