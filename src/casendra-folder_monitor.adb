with Ada.Directories;
with Ada.Text_IO;
with Casendra.Cases;
with Casendra.Attachments;
with Casendra.Text_Utils;
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
      File : Ada.Text_IO.File_Type;

      procedure Display_Progress (Percents_Downloaded : in Natural) is null;
    begin
      Casendra.Cases.Init (Working_On, Simple_Name (Item));
      Casendra.Cases.Save_History (Working_On, Dir);
      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Full_Name (Item));
      if Ada.Text_IO.End_Of_File (File) then
         Casendra.Cases.Download_Attachment (Working_On,
                                             Working_On.Attachments, 
                                             Dir => Dir,
                                             Callback => Display_Progress'Access);
         
      else
        declare
          First_Line : constant String := Ada.Text_IO.Get_Line (File);
          List : Casendra.Text_Utils.Natural_Array_Access :=
            new Casendra.Text_Utils.Natural_Array'(Casendra.Text_Utils.String_To_Natural_Array (First_Line, ","));
        begin
          null;
        end;

      end if;
      Ada.Text_IO.Close (File);
      Ada.Directories.Delete_File (Full_Name (Item));
    end Process;
  begin
    Search (Name, Pattern, (Directory=> False, others => True), Process'Access);
    null;
  end Walk_And_Process;

  procedure Stop (Self : in out Folder_Monitor_T) is
  begin
    Self.Monitor.Stop;
  end Stop;

  task body Monitor_Task_T is
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
  end Monitor_Task_T;

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
    Self.Monitor.Start (Self.Directory);
  end Start;
end casendra.folder_monitor; 

