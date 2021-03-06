with Casendra.Strata;
with GNATCOLL.JSON;
with Ada.Calendar;
package Casendra.Attachment is
   
   type Attachment_T is tagged record
      UUID              : Unbounded_String      := Null_Unbounded_String;
      Length            : Natural               := 0;
      Deprecated        : Boolean               := False;
      File_Name         : Unbounded_String      := Null_Unbounded_String;
      Mime_Type         : Unbounded_String      := Null_Unbounded_String;       -- TODO correlate with AWS.Mime
      Description       : Unbounded_String      := Null_Unbounded_String;
      URI               : Unbounded_String      := Null_Unbounded_String;
      Created_At        : Ada.Calendar.Time;
   end record;
   
   function "=" (Left, Right : Attachment_T) return Boolean is (Left.URI = Right.URI);
   
   procedure Download (Obj              : in Attachment_T; 
                       Dir              : in String;
                       Connection       : in out Casendra.Strata.COnnection_T;
                       Callback         : not null access procedure (Value      : in Natural));
   function Init (Element_JSON : GNATCOLL.JSON.JSON_Value) return Attachment_T;
   
   function Is_Downloaded (Obj : in Attachment_T;
                           Dir : in String) return Boolean;
end Casendra.Attachment;
