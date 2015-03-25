with Ada.Directories;
with AWS.Client;
with AWS.Response;
package body Casendra.Attachment is
   procedure Download (Obj : in Attachment_T; Dir : in String; Connection : in out Casendra.Strata.Connection_T;
							       Callback : not null access procedure (Value : in Natural)) is
      Data : AWS.Response.Data;
   begin
      if not Ada.Directories.Exists (Dir) then
	 raise Program_Error with "Directory " & Dir & " doesn't exist";
      end if;
      Casendra.Strata.Download (URI => To_String (Obj.URI),
				Length => Obj.Length,
				Filename => Dir & "/" & To_String (Obj.File_Name),
				Connection => Connection,
			        Progress => Callback);
   end Download;
end Casendra.Attachment;
