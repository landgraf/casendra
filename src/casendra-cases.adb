with Ada.Directories;
with Ada.Text_IO;
package body Casendra.Cases is
   function Attachments (Self : in Case_T) return Casendra.Attachments.Attachments_T is (Self.Attachments);

   procedure Init (Self : out Case_T; Case_Id : in String) is
   begin
      Casendra.Strata.Connect (Self.Connection);
      Self.Id := To_Unbounded_String (Case_Id);
      Self.Attachments := Casendra.Attachments.Init (Case_Id, Self.Connection);
      null;
   end Init;
   
   procedure Download_Attachment (Self : in out Case_T;
				  Index : in Positive;
				  Dir : in String := "/tmp/";
				  Callback : not null access procedure (Value : in Natural)) is
      Subdir : constant String := Dir & '/' & To_String (Self.Id) & "/downloads/";
   begin

      if not Ada.Directories.Exists (Subdir) then
	 Ada.Directories.Create_Path (Subdir);
      end if;

      Casendra.Attachments.Download (Self.Attachments, Self.Connection, Index, Subdir, Callback);
   exception
      when Ada.Directories.Use_Error =>
	 pragma Debug (Ada.Text_IO.Put_Line ("Unable to create directory " & Subdir));
	 null;
   end Download_Attachment;
   
   procedure Print_All_Attachmnents (Self : in Case_T;
				     Numbered : Boolean := False;
				     Deprecated : Boolean := False) is
   begin
      Casendra.Attachments.Print_All (Self.Attachments, Numbered, Deprecated);
   end Print_All_Attachmnents;
      
end Casendra.Cases;
