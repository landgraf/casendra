with Casendra.Cases;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Characters.Latin_1;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Fixed;
procedure Csdownloader is
   Working_On : Casendra.Cases.Case_T;

   type Natural_Array is array (Positive range <>) of Natural;
   type Natural_Array_Access is access all Natural_Array;
   
   Selection : Natural_Array_Access := null;
   
   procedure Free is new Ada.Unchecked_Deallocation (Natural_Array, Natural_Array_Access);
   
   procedure Display_Progress (Percents_Left : in Natural) is
      Downloaded : constant Natural := 100 - Percents_Left;
      Screen_Width     : constant Natural := 100;
      Number_Of_Spaces : constant Natural := Downloaded * Screen_Width / 100;
   begin
      
      Ada.Text_IO.Put(ASCII.ESC & "[2K" & ASCII.CR);
      Ada.Text_IO.Put ("[ ");
      for I in 1 .. Screen_Width loop
	 if I < Number_Of_Spaces then
	    Ada.Text_IO.Put ("=");
	 elsif I > Number_Of_Spaces then
	    Ada.Text_IO.Put ('.');
	 else
	    Ada.Text_IO.Put ('>');
	 end if;
      end loop;
      Ada.Text_IO.Put (" ]");
      Ada.Text_IO.Put(Downloaded'Img);
      
   end Display_Progress;
   
   function Select_Attachment_To_Download (Case_Object : in Casendra.Cases.Case_T) return Natural_Array_Access  is
     function String_To_Natural (Input : in String) return Natural is
     begin
	return Natural'Value (Input);
     exception
	when Constraint_Error =>
	   pragma Debug (Ada.Text_IO.Put_Line ("Unable to convert " & Input & " to digits"));
	   raise;
     end String_To_Natural;
     
   begin
      Casendra.Cases.Print_All_Attachmnents (Case_Object, Numbered => True, Deprecated => False);
      Ada.Text_IO.Put ("Please enter attachment(-s) to dowmload separated by comma");
      declare
	 Raw_Selection : constant String := Ada.Text_IO.Get_Line;
	 Delimeter : constant String := ",";
	 Retval : Natural_Array_Access := new Natural_Array (1 .. Ada.Strings.Fixed.Count (Raw_Selection, Delimeter) + 1);
	 Cursor : Natural := 0;
	 Next_Cursor : Natural := 0;
      begin
	 if Retval'Length = 1 then
	    goto Last;
	 end if;
	 for Index in Retval'First .. Retval'Last - 1 loop
	    Next_Cursor := Ada.Strings.Fixed.Index (Raw_Selection (Cursor + 1 .. Raw_Selection'Last), Delimeter);
	    Retval (Index) := String_To_Natural (Raw_Selection (Cursor + 1  .. Next_Cursor - 1));
	    Cursor := Next_Cursor;
	 end loop;
	 pragma Debug (Ada.Text_IO.Put_Line ("User input :" & Raw_Selection)); 
     <<Last>>
	 Retval (Retval'Last) := String_To_Natural (Raw_Selection (Cursor + 1 .. Raw_Selection'Last));
	 return Retval;
      end;
      raise Program_Error;
   end Select_Attachment_To_Download;
   
begin
   Casendra.Cases.Init (Working_On, Ada.Command_Line.Argument (1));
   Selection := Select_Attachment_To_Download (Working_On);
   for Index of Selection.all loop
      Casendra.Cases.Download_Attachment (Working_On, Index, Callback => Display_Progress'Access);
   end loop;
end Csdownloader;
