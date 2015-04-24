with Ada.Directories;
with AWS.Client;
with AWS.Response;
with Ada.Text_IO;

package body Casendra.Attachment is
   
   function Init (Element_JSON : GNATCOLL.JSON.JSON_Value) return Attachment_T is
      Element : Attachment_T;
      use GNATCOLL.JSON;
   begin
      Element.UUID := (if Has_Field (Element_Json, "uuid") then Get (Element_JSON, "uuid") else Null_Unbounded_String);
      Element.Length := (if Has_Field (Element_JSON, "length") then Get (Element_JSON, "length") else 0);
      Element.URI := (if Has_Field (Element_JSON, "uri") then Get (Element_JSON, "uri") else Null_Unbounded_String);
      Element.FIle_Name := (if Has_Field (Element_JSON, "file_name") then Get (Element_JSON, "file_name") else  Null_Unbounded_String);
      Element.Description := (if Has_Field (Element_JSON, "description") then Get (Element_JSON, "description") else Null_Unbounded_String);
      Element.Mime_Type := (if Has_Field (Element_JSON, "mime_type") then Get (Element_JSON, "mime_type") else Null_Unbounded_String);
      Element.Deprecated := (if Has_Field (Element_JSON, "deprecated") then Get (Element_JSON, "deprecated") else False);
      return Element;
   end Init;
      
   procedure Download (Obj      : in Attachment_T; Dir : in String; Connection : in out Casendra.Strata.Connection_T;
                       Callback : not null access procedure (Value : in Natural)) is
      Data     : AWS.Response.Data;
      Filename : constant String :=  Dir & "/" & To_String (Obj.File_Name);
   
   begin
      if not Ada.Directories.Exists (Dir) then
         raise Program_Error with "Directory " & Dir & " doesn't exist";
      end if;
      Casendra.Strata.Download (
                                URI        => To_String (Obj.URI),
                                Length     => Obj.Length,
                                Filename   => Filename,
                                Connection => Connection,
                                Progress   => Callback);
      pragma Debug (Ada.Text_IO.New_Line);
      pragma Debug (Ada.Text_IO.Put_Line ("DEBUG: " & Filename &  " saved"));
   end Download;
end Casendra.Attachment;
