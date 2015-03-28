with GNATCOLL.JSON;
package Casendra.Comment is 
   type Comment_T is record
      Created_By : Unbounded_String;
      Date : Unbounded_String; -- FIXME
      Text : Unbounded_String;
      Public : Boolean;
   end record;
   
   function "=" (Left, Right : Comment_T) return Boolean is (Left.Date = Right.Date);
   
   function Init (Element_JSON : in GNATCOLL.JSON.JSON_Value) return Comment_T;
end Casendra.Comment;
