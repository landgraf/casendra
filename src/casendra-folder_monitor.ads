with Config_File;
package casendra.folder_monitor is 
  -- Package to monitor queue folder and download attachments
  -- Queue file can be either empty or contain list of attachments to download (filenames/indexes?)

  type Folder_Monitor_T is tagged limited private;

  procedure Set_Directory (Self : in out Folder_Monitor_T; Directory : in String);
  procedure Start (Self : in out Folder_Monitor_T);
  procedure Stop (Self : in out Folder_Monitor_T);

  private

  task type Monitor_Task_T is
    entry Start (Directory : in Unbounded_String);
    entry Stop;
  end Monitor_Task_T;

  type Folder_Monitor_T is tagged limited record
    Directory : Unbounded_String := Null_Unbounded_String;
    Monitor : Monitor_Task_T;
  end record;

end casendra.folder_monitor; 

