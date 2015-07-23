with Ada.Directories;
with Ada.Text_IO;
with Casendra.Comments;
with Gnatcoll.Json;
with Casendra.Directories;
package body Casendra.Cases is
   function Attachments (Self : in Case_T) return Casendra.Attachments.Attachments_T is (Self.Attachments);
   function Is_Closed (Self : in Case_T) return Boolean is (Self.Is_Closed);
   function Id (Self : in Case_T) return String is (To_String(Self.Id));

   procedure Init (Self : out Case_T; Case_Id : in String) is
   begin
      Casendra.Strata.Connect (Self.Connection);
      Self.Id := To_Unbounded_String (Case_Id);
      declare
         use Gnatcoll.Json;
         Response : constant String := Casendra.Strata.Get_Case_JSON (Case_Id, Self.Connection);
         Response_Json : Gnatcoll.Json.Json_Value;
      begin
         Response_Json := Gnatcoll.Json.Read (Response, Filename => "");
         Self.Is_Closed := (if Has_Field (Response_Json, "closed") then Get (Response_Json, "closed") else True);
      end;
      -- TODO
      -- Retrieve one single json here? 
      Self.Attachments := Casendra.Attachments.Init (Case_Id, Self.Connection);
      Self.Comments := Casendra.Comments.Init (Case_Id, Self.Connection);
   end Init;
   
   procedure Download_Attachment (Self     : in out Case_T;
                                  Attachments : in              Casendra.Attachments.Attachments_T;
                                  Dir      : in String := "/tmp/";
                                  Callback : not null access procedure (Value : in Natural)) is
      Subdir : constant String := Dir & To_String (Self.Id) & "/attachments/";
   begin

      if not Ada.Directories.Exists (Subdir) then
         Ada.Directories.Create_Path (Subdir);
         Ada.Directories.Create_Path (Subdir & "/.by-uuid/");
      end if;
      Casendra.Attachments.Download (Attachments, Self.Connection, Subdir, Callback);
   exception
      when Ada.Directories.Use_Error =>
         pragma Debug (Ada.Text_IO.Put_Line ("Unable to create directory " & Subdir));
         null;
   end Download_Attachment;
   
   procedure Save_History (Self : in Case_T; Dir : in String := "/tmp/") is
      Subdir : constant String := Dir & To_String (Self.Id);
   begin
      Casendra.Comments.Save_All (Self.Comments, Subdir);
   end Save_History;
   
   procedure Delete_Data (Self : in Case_T) 
   is
      Dir : constant String := Config_FIle.Get_String (Casendra.Config,
                                                       "downloader.directory",
                                                       False, 
                                                       "/tmp/folder/");

      Subdir : constant String := Dir & To_String (Self.Id);
   begin
      Casendra.Directories.Delete_Tree (Subdir);
   exception
      when Ada.Directories.Use_Error =>
         Ada.Text_Io.Put_Line ("Failed to delete directory" & Subdir & ". Probably because of permissions. Please delete it manually with:");
         Ada.Text_Io.Put_Line ("sudo rm -rf " & Subdir);
   end Delete_Data;
   
   function Get_All_Attachments (Self : in Case_T) return Casendra.Attachments.Attachments_T is (Self.Attachments);
   
end Casendra.Cases;
