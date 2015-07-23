with Casendra.Attachments;
with Casendra.Comments;
with Casendra.Strata;
package Casendra.Cases is
   type Case_T is tagged limited private;
   
   procedure Init (Self : out Case_T; Case_Id : in String);
   
   procedure Download_Attachment (Self        : in out          Case_T;
                                  Attachments : in              Casendra.Attachments.Attachments_T;
                                  Dir         :                 String := "/tmp/";
                                  Callback    : not null access procedure (Value : Natural));

   -- TODO should return value rather print to terminal
   -- to support another UIs
   
   function Get_All_Attachments (Self : in Case_T) return Casendra.Attachments.Attachments_T;
   -- Return list of all attachments to process

   function Attachments (Self : in Case_T) return Casendra.Attachments.Attachments_T;
   
   procedure Save_History (Self : in Case_T; Dir : in String := "/tmp/");
   
   procedure Delete_Data (Self : in Case_T);
   -- Delete all attachments and comments from the local directory
   
   function Is_Closed (Self     : in Case_T) return Boolean;
   function Id (Self    : in Case_T) return String;
   
private
   type Case_T is tagged limited record
      Connection  : Casendra.Strata.Connection_T;
      Connected   : Boolean := False;
      Id          : Unbounded_String := Null_Unbounded_String; -- FIXME Should be Case_Id_T
      Owner       : Unbounded_String := Null_Unbounded_String;
      Comments    : Casendra.Comments.Comments_T;
      Attachments : Casendra.Attachments.Attachments_T;
      Is_Closed   : Boolean;
   end record;
end Casendra.Cases;
