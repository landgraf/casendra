with Ada.Command_Line;
with Ada.Directories;
with Ada.Text_IO;
with GNAT.OS_Lib;
with Csdownloader;

procedure Casendra_Cli is 
   procedure Usage is
      use Ada.Text_IO;
   begin
      Put_Line ("casendrda download <case number>");
      Gnat.OS_Lib.OS_Exit (1);
   end Usage;
   Command : constant String := Ada.Directories.Simple_Name (Ada.Command_Line.Command_Name);

begin
   if Ada.Command_Line.Argument_Count < 1 then
      Usage;
   end if;
   
   Ada.Text_IO.Put_Line (Command);
   if Command  = "csdownloader" then
      Csdownloader;
   end if;

end Casendra_Cli;
