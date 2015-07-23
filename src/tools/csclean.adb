with Ada.Command_Line;
with Casendra;
with Casendra.Cases;
with Config_File;
with Ada.Directories;
with Ada.Text_Io;
with Ada.Strings.Unbounded;	use Ada.Strings.Unbounded;

procedure Csclean (Interactive : Boolean) is 
   -- Walk over subdirectories in "casedir" and check if case is still open
   -- Remove the directory otherwise
   -- NOTE: It should be done as root user because of permissions 
   Downloader_Directory_Parameter	: constant String := "downloader.directory";
   Downloader_Directory			: Unbounded_String	:= Null_Unbounded_String;
   Cleaned : Boolean := False;
   
   procedure Walk (Directory_Name : in String;
		   Pattern	  : in String			   := "";
		   Filter	  : in Ada.Directories.Filter_Type := (Ada.Directories.Directory => True, others => False))
   is
      use Ada.Directories;
      Search : Search_Type;
      Dir_Entry : Directory_Entry_Type;
   begin
      Start_Search (Search, Directory_Name, Pattern, Filter);
      while More_Entries (Search) loop
	 Get_Next_Entry (Search, Dir_Entry);
	 if Simple_Name (Dir_Entry)'Length = 8 then
	    declare
	       Current : Casendra.Cases.Case_T;
	    begin
	       Casendra.Cases.Init (Current, Simple_Name (Dir_Entry));
	       if Current.Is_Closed then
		  Cleaned := True;
		  Current.Delete_Data;
	       end if;
	    end;
	 end if;
      end loop;
      null;
   end Walk;
   
begin
   if not Config_File.Is_Has_Key (Casendra.Config, Downloader_Directory_Parameter) then
      raise Constraint_Error with "Configuration error:" & 
	"Please check if downloader.directory is specified in your config file";
   end if;
   Downloader_Directory	:=
     To_Unbounded_String(Config_File.Get_String (Casendra.Config, Downloader_Directory_Parameter));
   -- TODO: Add Unbounded_string operations to config_file
   -- Walk over the directory
   Walk (Directory_Name => To_String (Downloader_Directory));
   if Interactive and then Cleaned then
      pragma Debug (Ada.Text_Io.Put_Line ("Closed cases attachments have been removed"));
   else
      pragma Debug (Ada.Text_Io.Put_Line ("No closed cases found"));
   end if;

end Csclean;
