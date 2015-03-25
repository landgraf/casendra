package body Casendra.Cases is
   
   procedure Init (Self : out Case_T; Case_Id : in String) is
   begin
      Casendra.Strata.Connect (Self.Connection);
      Self.Attachments := Casendra.Attachments.Init (Case_Id, Self.Connection);
      Casendra.Attachments.Print_All (Self.Attachments);
      null;
   end Init;
   
   procedure Download_Attachment (Self : in out Case_T;
				  Index : in Positive;
				  Dir : in String := "/tmp/") is
   begin
      Casendra.Attachments.Download (Self.Attachments, Self.Connection, Index, Dir);
   end Download_Attachment;
end Casendra.Cases;
