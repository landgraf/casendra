with Ada.Directories;
with Casendra.Cases;
package body casendra.folder_monitor is 

  procedure Set_Directory (Self : in out Folder_Monitor_T; Directory : in String) is
  begin
    Self.Directory := To_Unbounded_String (Directory);
  end Set_Directory;

  procedure Walk_And_Process (Name : String) is
    use Ada.Directories;
    Pattern : constant String := "*"; -- FIXME
    procedure Process (Item : Directory_Entry_Type) is
      Working_On : Casendra.Cases.Case_T;
      Dir : constant String := Config_FIle.Get_String (Casendra.Config,
        "downloader.directory",
        False, 
        "/tmp/folder/");
    begin
      Casendra.Cases.Init (Working_On, Simple_Name (Item));
      Casendra.Cases.Save_History (Working_On, Dir);
      Ada.Directories.Delete_File (Full_Name (Item));
    end Process;
  begin
    Search (Name, Pattern, (Directory=> False, others => True), Process'Access);
    null;
  end Walk_And_Process;

  procedure Stop (Self : in out Folder_Monitor_T) is
  begin
    Monitor.Stop;
  end Stop;

  task body Monitor is
    Dir : Unbounded_String := To_Unbounded_String ("/tmp");
    Finished : Boolean := False;
  begin
    accept Start (Directory : in Unbounded_String) do
      Dir := Directory;
    end Start;
    loop
      exit when Finished;
      select
        accept Stop do
          Finished := True;
        end Stop;
      or
        -- Do something usefull
        delay 1.0;
        Walk_And_Process (To_String (Dir));
      end select;
    end loop;
  end Monitor;

  procedure Start (Self : in out Folder_Monitor_T) is
  begin
    if Self.Directory = Null_Unbounded_String then
      Self.Directory := (if Config_File.Is_Has_Key (Casendra.Config, "downloader.queue") 
        then To_Unbounded_String (Config_File.Get_String (Config, "downloader.queue"))
        else To_Unbounded_String ("/tmp/queue/"));
    end if;
    if not Ada.Directories.Exists (To_String (Self.Directory)) then
      Ada.Directories.Create_Path (To_String (Self.Directory));
    end if;
    Monitor.Start (Self.Directory);
  end Start;
end casendra.folder_monitor; 

