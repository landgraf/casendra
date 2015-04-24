with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Config_File;
with Ada.Environment_Variables;
package Casendra is
   pragma Elaborate_Body (Casendra);
   Config_File_Name : constant String := 
                        (if Ada.Environment_Variables.Exists ("HOME")
                         then Ada.Environment_Variables.Value ("HOME") & "/.config/casendra.conf"
                         else "casendra.conf");
   Config           : Config_File.Config_Data;
end Casendra;
