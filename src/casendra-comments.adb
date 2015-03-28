with GNATCOLL.JSON;
with Ada.Text_IO;
package body Casendra.Comments is
   function Init (Case_Id : in String;
		  Connection : in out Casendra.Strata.Connection_T) return Comments_T is
      Retval : Comments_T;
      Response_JSON : Gnatcoll.JSON.JSON_Value;
      use GNATCOLL.JSON;
   begin
      declare
	 Response : constant String := Casendra.Strata.Get_Comments_JSON (Case_Id, Connection);
      begin
	 Response_JSON := GNATCOLL.JSON.Read (Response);
      end;
      -- TODO generic/class
      if Has_Field (Response_JSON, "attachment") then
	 declare
	    Comments_JSON : JSON_Array;
	 begin
	    Comments_JSON := Get (Response_JSON, "comment");
	    for Index in 1 .. Length (Comments_JSON) loop
	       declare
		  Element_JSON : constant JSON_Value := Get (Comments_JSON, Index);
		  Element : Casendra.Comment.Comment_T := Casendra.Comment.Init (Element_JSON);
	       begin
		  Comments_P.Append (Retval, Element);
               end;
	    end loop;
	 end;
      else
	 -- No attachments? 
	 null;
      end if;
      
      return Retval;
   end Init;

end Casendra.Comments;
