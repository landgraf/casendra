with Casendra.Strata;
with Ada.Text_IO;
with Gnatcoll.JSON;
package body Casendra.Attachments is
   
   procedure Print_All (Obj        : in Attachments_T;
                        Numbered   : in Boolean := False;
                        Deprecated : in Boolean := False) is 
      use Ada.Text_IO;
      Counter : Positive;
   begin
      Counter := 1;
      for Att of Obj loop
         if Numbered then
            Put (Counter'Img & "  ");
            Counter := Counter + 1;
         end if;
         if not Deprecated and Att.Deprecated then
            null;
         else
            Put_Line ("filename: " & To_String (Att.File_Name) & " ; Length = " & Natural'Image (Att.Length / 1024) & " Kb");
         end if;
      end loop;
   end Print_All;
    
    function Init (Case_Id      : in String; 
                   Connection                   : in out Casendra.Strata.Connection_T) return Attachments_T is
       -- curl -v -k -u $USER:$PASS -X GET -H 'Accept: application/xml' $HOST/rs/cases/$CASENUMBER/attachments -D - 
       Retval                   : Attachments_T;
       Response_JSON            : Gnatcoll.JSON.JSON_Value;
       use GNATCOLL.JSON;
   begin
      declare
         Response : constant String := Casendra.Strata.Get_Attachments_JSON (Case_Id, Connection);
      begin
         Response_JSON := GNATCOLL.JSON.Read (Response, Filename => "");
      end;
      if Has_Field (Response_JSON, "attachment") then
         declare
            Attachments_JSON : JSON_Array;
         begin

            Attachments_JSON := Get (Response_JSON, "attachment");
            for Index in 1 .. Length (Attachments_JSON) loop
               declare
                  Element_JSON : constant JSON_Value := Get (Attachments_JSON, Index);
                  Element      : Casendra.Attachment.Attachment_T := Casendra.Attachment.Init (Element_JSON);
               begin
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

   procedure Download (Obj        : in Attachments_T;
                       Connection : in out Casendra.Strata.Connection_T;
                       Index      : in Natural;
                       Dir        : in String;
                       Callback   : not null access procedure (Value : in Natural)) is
   begin
      if Index > Natural (Attachments_P.Length (Obj)) then
         raise Program_Error with "Index is out of range";
      end if;
      Casendra.Attachment.Download (Obj (Index), Dir, Connection, Callback);
   end Download;

   procedure Download (Obj              : in Attachments_T;
                       Connection       : in out Casendra.Strata.Connection_T;
                       Dir              : in String;
                       Callback         : not null access procedure (Value      : in Natural)) is
   begin
      for Attach of Obj loop
         Casendra.Attachment.Download (Attach, Dir, Connection, Callback);
      end loop;
   end Download;
   
end Casendra.Attachments;
