with Ada.Directories;
package body Casendra is
begin
   if Ada.Directories.Exists (Config_File_Name) then
      Config_File.Load (Config, Config_File_Name, Read_Only => True);
   else
      raise Program_Error with "Config file not found. Please put configuration into ${HOME}/.config/casendra.conf" & ASCII.LF & "Example can be found in /usr/share/doc/casendra/";
   end if;
end Casendra;
