with Ada.Containers.Vectors;
with Casendra.Attachment;
with Casendra.Strata;
package Casendra.Attachments is
   
   package Attachments_P is new Ada.Containers.Vectors (Index_Type => Positive,
							Element_Type => Casendra.Attachment.Attachment_T,
						       "=" => Casendra.Attachment."=");
   subtype Attachments_T is Attachments_P.Vector;
   
   function Init (Case_Id : in String;
		 Connection : in out Casendra.Strata.Connection_T) return Attachments_T;
   
   procedure Print_All (Obj : Attachments_T);
   
   procedure Download (Obj : in Attachments_T; 
		       Connection : in out Casendra.Strata.Connection_T;
		       Index : in Natural; 
		       Dir : in String;
		       Callback : not null access procedure (Value : in Natural));
      
end Casendra.Attachments;
