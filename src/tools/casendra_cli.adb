with Ada.Command_Line;
with Ada.Directories;
with Ada.Text_IO;

with Csdownloader;

procedure Casendra_Cli is 
   Command : constant String := Ada.Directories.Simple_Name (Ada.Command_Line.Command_Name);

begin
   Ada.Text_IO.Put_Line (Command);
   if Command  = "csdownloader" then
      Csdownloader;
   end if;

end Casendra_Cli;
