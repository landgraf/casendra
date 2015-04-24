with Casendra.Cases;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Characters.Latin_1;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Fixed;
with Config_File;
with GNAT.OS_Lib;
with Casendra.Attachments;
procedure Csdownloader is
   
   procedure Usage is
      use Ada.Text_IO;
   begin
      Put_Line ("casendrda download <case number>");
      Gnat.OS_Lib.OS_Exit (1);
   end Usage;
   
   Working_On : Casendra.Cases.Case_T;

   type Natural_Array is array (Positive range <>) of Natural;
   type Natural_Array_Access is access all Natural_Array;
   
   Selection : Natural_Array_Access := null;
   
   procedure Free is new Ada.Unchecked_Deallocation (Natural_Array, Natural_Array_Access);
   
   procedure Display_Progress (Percents_Downloaded : in Natural) is
      Screen_Width     : constant Natural := 100;
      Number_Of_Arrows : constant Natural := Percents_Downloaded * Screen_Width / 100;
   begin
      
      Ada.Text_IO.Put(ASCII.ESC & "[2K" & ASCII.CR);
      Ada.Text_IO.Put ("[ ");
      for I in 1 .. Screen_Width loop
    if I < Number_Of_Arrows then
       Ada.Text_IO.Put ("=");
    elsif I > Number_Of_Arrows then
       Ada.Text_IO.Put ('.');
    else
       Ada.Text_IO.Put ('>');
    end if;
      end loop;
      Ada.Text_IO.Put (" ]");
      Ada.Text_IO.Put(Percents_Downloaded'Img & " %");
      
   end Display_Progress;
   
   function Select_Attachment_To_Download (Case_Object : in Casendra.Cases.Case_T) return Natural_Array_Access  is
      function String_To_Natural (Input : in String) return Natural is
      begin
         return Natural'Value (Input);
      end String_To_Natural;

   begin
     Casendra.Cases.Print_All_Attachmnents (Case_Object, Numbered => True, Deprecated => False);
     Ada.Text_IO.Put ("Please enter attachment(-s) to download separated by comma (Hit ENTER to dowload all): ");
     declare
       Raw_Selection : constant String := Ada.Text_IO.Get_Line;
       Delimeter : constant String := ",";
       Retval : Natural_Array_Access := null;
       Cursor : Natural := 0;
       Next_Cursor : Natural := 0;
     begin
       if Raw_Selection'Length = 0 then
         return Retval;
       end if;
       Retval := new Natural_Array (1 .. Ada.Strings.Fixed.Count (Raw_Selection, Delimeter) + 1);

       if Retval'Length /= 1 then
         for Index in Retval'First .. Retval'Last - 1 loop
           Next_Cursor := Ada.Strings.Fixed.Index (Raw_Selection (Cursor + 1 .. Raw_Selection'Last), Delimeter);
           Retval (Index) := String_To_Natural (Raw_Selection (Cursor + 1  .. Next_Cursor - 1));
           Cursor := Next_Cursor;
         end loop;
       end if;
       pragma Debug (Ada.Text_IO.Put_Line ("User input :" & Raw_Selection)); 
       if Raw_Selection = "" then
         return Retval;
       end if;
       Retval (Retval'Last) := String_To_Natural (Raw_Selection (Cursor + 1 .. Raw_Selection'Last));
       return Retval;
     end;
     raise Program_Error;
   end Select_Attachment_To_Download;
   
   Dir : constant String := Config_FIle.Get_String (Casendra.Config,
                      "downloader.directory",
                      False, 
                      "/tmp/folder/");
   
   

begin
   if Ada.Command_Line.Argument_Count < 1 then
      Usage;
   end if;
   

   Casendra.Cases.Init (Working_On, Ada.Command_Line.Argument (1));
   
   Casendra.Cases.Save_History (Working_On, Dir);
   loop
  Try:
      begin
         Selection := Select_Attachment_To_Download (Working_On);
         exit;
      exception
         when others =>
            Ada.Text_IO.Put_Line ("Invalid input. Please try again!");
      end Try;
   end loop;
   
   if Selection = null then
      for Index in 1 .. Casendra.Attachments.Attachments_P.Length (Casendra.Cases.Attachments (Working_On)) loop
        Casendra.Cases.Download_Attachment (Working_On,
                                            Integer (Index), 
                                            Dir => Dir,
                                            Callback => Display_Progress'Access);
         
      end loop;
      goto Cleanup;
   end if;
   for Index of Selection.all loop
      -- TODO Should be done in parallel
      -- Have to find the way how to pass array 
      Casendra.Cases.Download_Attachment (Working_On,
                                          Index, 
                                          Dir => Dir,
                                          Callback => Display_Progress'Access);
   end loop;
   
<<Cleanup>>
  if Selection /= null then
   Free (Selection);
  end if;
end Csdownloader;
