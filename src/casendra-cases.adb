package body Casendra.Cases is
   
   procedure Init (Self : out Case_T; Case_Id : in String) is
   begin
      Casendra.Strata.Connect (Self.Connection);
      Self.Attachments := Casendra.Attachments.Init (Case_Id, Self.Connection);

      null;
   end Init;
   
   procedure Download_Attachment (Self : in out Case_T;
				  Index : in Positive;
				  Dir : in String := "/tmp/";
				  Callback : not null access procedure (Value : in Natural)) is
   begin
      Casendra.Attachments.Download (Self.Attachments, Self.Connection, Index, Dir, Callback);
   end Download_Attachment;
   
   procedure Print_All_Attachmnents (Self : in Case_T;
				     Numbered : Boolean := False;
				     Deprecated : Boolean := False) is
   begin
      Casendra.Attachments.Print_All (Self.Attachments, Numbered, Deprecated);
   end Print_All_Attachmnents;
      
end Casendra.Cases;
