with Casendra.Attachments;
with Casendra.Comments;
with Casendra.Strata;
package Casendra.Cases is
   type Case_T is limited private;
   
   procedure Init (Self : out Case_T; Case_Id : in String);
   procedure Download_Attachment (Self : in out Case_T; Index : Positive; Dir : String := "/tmp/"; Callback : not null access procedure (Value : in Natural));
   -- TODO should return value rather print to terminal
   -- to support another UIs
   procedure Print_All_Attachmnents (Self : in Case_T; Numbered : Boolean := False; Deprecated : Boolean := False);
   function Attachments (Self : in Case_T) return Casendra.Attachments.Attachments_T;
   
private
   type Case_T is limited record
      Connection : Casendra.Strata.Connection_T;
      Connected : Boolean := False;
      Id : Unbounded_String := Null_Unbounded_String; -- FIXME Should be Case_Id_T
      Owner : Unbounded_String := Null_Unbounded_String;
      Comments : Casendra.Comments.Comments_T;
      Attachments : Casendra.Attachments.Attachments_T;
   end record;
end Casendra.Cases;
