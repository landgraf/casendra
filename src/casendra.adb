with Ada.Directories;
package body Casendra is
begin
   if Ada.Directories.Exists (Config_File_Name) then
      Config_File.Load (Config, Config_File_Name, Read_Only => True);
   else
      raise Program_Error with "Config file not found";
   end if;
end Casendra;
