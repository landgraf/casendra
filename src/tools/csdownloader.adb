with Casendra.Cases;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Characters.Latin_1;
procedure Csdownloader is
   Working_On : Casendra.Cases.Case_T;
   
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
      Ada.Text_IO.Put(Percents_Left'Img);
      
   end Display_Progress;
   
begin
   Casendra.Cases.Init (Working_On, Ada.Command_Line.Argument (1));
   Casendra.Cases.Download_Attachment (Working_On, 1, Callback => Display_Progress'Access);
end Csdownloader;
