with Ada.Command_Line;
with Ada.Directories;
with Ada.Text_IO;

with Csdownloader;
with Casendra_daemon;
with Csclean;

procedure Casendra_Cli is 
   Command : constant String := Ada.Directories.Simple_Name (Ada.Command_Line.Command_Name);

begin
   Ada.Text_IO.Put_Line (Command);
   if Command  = "csdownloader" then
      Csdownloader (Interactive => True);
   elsif Command = "csclean" then
      Csclean (Interactive => True);
   elsif Command = "casendrad" then
     Casendra_Daemon;
   end if;

end Casendra_Cli;
