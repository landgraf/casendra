with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Config_File;
package Casendra is
   pragma Elaborate_Body (Casendra);
   Config_File_Name : constant String := "casendra.conf";
   Config : Config_File.Config_Data;
end Casendra;
