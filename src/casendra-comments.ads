with Ada.Containers.Vectors;
with Casendra.Attachment;
with Casendra.Strata;
with Casendra.Comment;
package Casendra.Comments is
   
   package Comments_P is new Ada.Containers.Vectors (Index_Type => Positive,
						     Element_Type => Casendra.Comment.Comment_T,
						     "=" => Casendra.Comment."=");
   subtype Comments_T is Comments_P.Vector;
   
   function Init (Case_Id : in String;
		  Connection : in out Casendra.Strata.Connection_T) return Comments_T;
   
   
   
end Casendra.Comments;
