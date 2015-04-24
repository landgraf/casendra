with GNATCOLL.JSON;
with Ada.Text_IO;
with Ada.Directories;
package body Casendra.Comments is
   function Init (Case_Id    : in String;
                  Connection : in out Casendra.Strata.Connection_T) return Comments_T is
      Retval        : Comments_T;
      Response_JSON : Gnatcoll.JSON.JSON_Value;
      use GNATCOLL.JSON;
   begin
      declare
         Response : constant String := Casendra.Strata.Get_Comments_JSON (Case_Id, Connection);
      begin
         Response_JSON := GNATCOLL.JSON.Read (Response, Filename => "");
      end;
      -- TODO generic/class
      if Has_Field (Response_JSON, "comment") then
         declare
            Comments_JSON : JSON_Array;
         begin
            Comments_JSON := Get (Response_JSON, "comment");
            for Index in 1 .. Length (Comments_JSON) loop
               declare
                  Element_JSON : constant JSON_Value := Get (Comments_JSON, Index);
                  Element      : Casendra.Comment.Comment_T := Casendra.Comment.Init (Element_JSON);
               begin
                  Comments_P.Append (Retval, Element);
               end;
            end loop;
         end;
      else
         -- No comments? 
         null;
      end if;
    
      return Retval;
   end Init;
   
   procedure Save_All (Self : in Comments_T;
                       Dir  : in String) is
      Filename : constant String := Dir & "/comments.txt";
      File     : Ada.Text_IO.File_Type;
   begin
      if not Ada.Directories.Exists (Dir) then
         Try :
         begin
            Ada.Directories.Create_Path (Dir);
         exception
            when Ada.Text_IO.Use_Error =>
               raise;
         end Try;
      end if;
      
      if Ada.Directories.Exists (Filename) then
         Ada.Text_IO.Open (File, Ada.Text_IO.Out_File, Filename);
      else
         Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, Filename);
      end if;
      Ada.Text_IO.Set_Line_Length (File, 100);
      Ada.Text_IO.Put_Line ("Saving comments: " & Filename);
      for Comment of Self loop
         declare
            Text : constant String := Casendra.Comment.To_Txt (Comment);
         begin
            Ada.Text_IO.Put_Line (File, Text);
         end;
      end loop;
      if Ada.Text_IO.Is_Open (File) then
         Ada.Text_IO.Close (File);
      end if;

   exception
      when Ada.Text_IO.Use_Error | Ada.Text_IO.Mode_Error =>
         if Ada.Text_IO.Is_Open (File) then
            Ada.Text_IO.Close (File);
         end if;
         raise;
      when others =>
         raise;
   end Save_All;
  
end Casendra.Comments;
