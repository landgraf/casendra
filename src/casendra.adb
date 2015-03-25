with Ada.Directories;
package body Casendra is
begin
   if Ada.Directories.Exists (Config_File_Name) then
      Config_File.Load (Config, "casendra.conf", Read_Only => True);
   end if;
end Casendra;
