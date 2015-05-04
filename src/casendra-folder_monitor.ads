with Config_File;
package casendra.folder_monitor is 
  -- Package to monitor queue folder and download attachments
  -- Queue file can be either empty or contain list of attachments to download (filenames/indexes?)

  type Folder_Monitor_T is tagged private;

  procedure Set_Directory (Self : in out Folder_Monitor_T; Directory : in String);
  procedure Start (Self : in out Folder_Monitor_T);
  procedure Stop (Self : in out Folder_Monitor_T);

  private

  task Monitor is
    entry Start (Directory : in Unbounded_String);
    entry Stop;
  end Monitor;

  type Folder_Monitor_T is tagged record
    Directory : Unbounded_String := Null_Unbounded_String;
  end record;

end casendra.folder_monitor; 

