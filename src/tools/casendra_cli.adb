with Ada.Command_Line;
with Ada.Directories;
with Ada.Text_IO;

with Csdownloader;
with Casendra_daemon;

procedure Casendra_Cli is 
   Command : constant String := Ada.Directories.Simple_Name (Ada.Command_Line.Command_Name);

begin
   Ada.Text_IO.Put_Line (Command);
   if Command  = "csdownloader" then
      Csdownloader;
   elsif Command = "casendrad" then
     Casendra_Daemon;
   end if;

end Casendra_Cli;
