package body Casendra.Comment is
   function Init (Element_JSON : in GNATCOLL.JSON.JSON_Value) return Comment_T is
      Element : Comment_T;
      use GNATCOLL.JSON;
   begin
      Element.Created_By := (if Has_Field (Element_Json, "created_by") then Get (Element_JSON, "created_by") else Null_Unbounded_String);
      Element.Text := (if Has_Field (Element_Json, "text") then Get (Element_JSON, "text") else Null_Unbounded_String);
      Element.Public := (if Has_Field (Element_JSON, "public") then Get (Element_JSON, "public") else False);
      return Element;
      
   end Init;
   
   function To_Txt (Self : Comment_T) return String is
      Unbounded_Return : Unbounded_String := Null_Unbounded_String;
   begin
      Append (Unbounded_Return, "**" & Self.Created_By);
      Append (Unbounded_Return, Self.Text);
      return To_String (Unbounded_Return); -- FIXME
   end To_Txt;



end Casendra.Comment;
