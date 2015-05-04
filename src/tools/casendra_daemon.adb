with Ada.Command_Line;
with Ada.Text_IO;
with Casendra.Folder_Monitor;
procedure casendra_daemon is
  FM : Casendra.Folder_Monitor.Folder_Monitor_T;
begin
  Ada.Text_IO.Put_Line ("Casendra daemon started...");
  loop
    FM.Start;
    -- TODO
    -- Add signal handler here
  end loop;
  FM.Stop;
exception
  when others =>
    Ada.Text_IO.Put_Line ("Exception raised");
    FM.Stop;
end casendra_daemon; 

