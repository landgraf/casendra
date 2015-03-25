with Casendra.Strata;
with Ada.Text_IO;
with Gnatcoll.JSON;
package body Casendra.Attachments is
   
   procedure Print_All (Obj : Attachments_T) is 
      use Ada.Text_IO;
   begin
      for Att of Obj loop
	 Put_Line("filename: " & To_String (Att.File_Name) & "Length = " & Natural'Image (Att.Length));
      end loop;
   end Print_All;
	 
   function Init (Case_Id : in String; Connection : in out Casendra.Strata.Connection_T) return Attachments_T is
      -- curl -v -k -u $USER:$PASS -X GET -H 'Accept: application/xml' $HOST/rs/cases/$CASENUMBER/attachments -D - 
      Retval : Attachments_T;
      Response_JSON : Gnatcoll.JSON.JSON_Value;
      use GNATCOLL.JSON;
     
   begin
      declare
	 Response : constant String := Casendra.Strata.Get_Attachments_JSON (Case_Id, Connection);
      begin
	 Response_JSON := GNATCOLL.JSON.Read (Response);
      end;
      if Has_Field (Response_JSON, "attachment") then
	 declare
	    Attachments_JSON : JSON_Array;
	 begin

	    Attachments_JSON := Get (Response_JSON, "attachment");
	    for Index in 1 .. Length (Attachments_JSON) loop
	       declare
		  Element_JSON : constant JSON_Value := Get (Attachments_JSON, Index);
		  Element : Casendra.Attachment.Attachment_T;
	       begin
		  Element.UUID := (if Has_Field (Element_Json, "uuid") then Get (Element_JSON, "uuid") else Null_Unbounded_String);
		  Element.Length := (if Has_Field (Element_JSON, "length") then Get (Element_JSON, "length") else 0);
		  Element.URI := (if Has_Field (Element_JSON, "uri") then Get (Element_JSON, "uri") else Null_Unbounded_String);
		  Element.FIle_Name := (if Has_Field (Element_JSON, "file_name") then Get (Element_JSON, "file_name") else  Null_Unbounded_String);
		  Element.Description := (if Has_Field (Element_JSON, "description") then Get (Element_JSON, "description") else Null_Unbounded_String);
		  Element.Mime_Type := (if Has_Field (Element_JSON, "mime_type") then Get (Element_JSON, "mime_type") else Null_Unbounded_String);
		  Element.Deprecated := (if Has_Field (Element_JSON, "deprecated") then Get (Element_JSON, "deprecated") else False);
		  Attachments.Attachments_P.Append (Retval, Element);
               end;
	    end loop;
	 end;
      else
	 -- No attachments? 
	 null;
      end if;
      return Retval;
   end Init;

   procedure Download (Obj : in Attachments_T;
		       Connection : in out Casendra.Strata.Connection_T;
		       Index : in Natural; Dir : in String) is
   begin
      if Index > Natural (Attachments_P.Length (Obj)) then
	 raise Program_Error with "Index is out of range";
      end if;
      Casendra.Attachment.Download (Obj (Index), Dir, Connection);
   end Download;


end Casendra.Attachments;
