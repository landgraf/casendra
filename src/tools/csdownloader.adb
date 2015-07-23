with Casendra.Cases;
with Ada.Calendar.Formatting;
with Ada.Calendar.Arithmetic;
with Ada.Characters.Handling;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Characters.Latin_1;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Config_File;
with GNAT.OS_Lib;
with Casendra.Attachment;
with Casendra.Attachments;
with Casendra.Text_Utils;

procedure Csdownloader (Caseid      : in String := "";
                        Input       : in String := "";
                        Interactive :    Boolean) 
  -- TODO: Add simulate only option to save traffic
is
   
   procedure Usage is
      use Ada.Text_IO;
   begin
      Put_Line ("casendrda download <case number>");
      Gnat.OS_Lib.OS_Exit (1);
   end Usage;
   
   Working_On : Casendra.Cases.Case_T;
   
   Selection : Casendra.Attachments.Attachments_T;
   Dir  : constant String       := Config_FIle.Get_String (Casendra.Config,
                                                           "downloader.directory",
                                                           False, 
                                                           "/tmp/folder/");
   
   procedure Display_Progress (Percents_Downloaded : in Natural)
   is
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
      if Percents_Downloaded = 100 then
         Ada.Text_Io.New_Line;
      end if;
      
   end Display_Progress;
   
   procedure Display_Progress_Non_Interactive (Percents_Downloaded : in Natural) is null;
   
   function Select_Attachment_To_Download (Case_Object  : in Casendra.Cases.Case_T) return Casendra.Attachments.Attachments_T 
   is
      function Get_Time_Stamp (Raw_Selection    : in String) return Ada.Calendar.Time is
         Unit                           : Character             := Raw_Selection (Raw_Selection'Last);
         Day_Duration                   : constant Duration     := Ada.Calendar.Day_Duration'Last;
         Hour_Duration                  : constant Duration     := Ada.Calendar.Day_Duration'Last / 24;
         Dur                            : Duration;
         use Ada.Calendar;
      begin
         if Raw_Selection'Length < 2 or else
           (for some X of Raw_Selection (Raw_Selection'First .. Raw_Selection'Last - 1) => not Ada.Characters.Handling.Is_Digit (X)) then
            raise Constraint_Error with "Wrong time format"     ;
         end if;
         case Unit is
            when 'd'    =>
               Dur := Day_Duration * Natural'Value (Raw_Selection (Raw_Selection'First .. Raw_Selection'Last -1 ));
            when 'h' =>
               Dur := Hour_Duration * Natural'Value (Raw_Selection (Raw_Selection'First .. Raw_Selection'Last -1 ));
            when others =>
               Ada.Text_Io.Put_Line ("Only h (hours) and d (days) is allowed");
               raise Constraint_Error;
         end case;
         return  Clock - Dur;
      end Get_Time_Stamp;
      
      Attachments       : Casendra.Attachments.Attachments_T    := Case_Object.Get_All_Attachments;
      Counter           : Positive;
   begin
      Counter := 1;
      for Attachment of Attachments loop
         declare
            Days                : Ada.Calendar.Arithmetic.Day_Count;
            Seconds             : Duration;
            Leap_Seconds        : Ada.Calendar.Arithmetic.Leap_Seconds_Count;
         begin
            -- Fixme
            if not Attachment.Is_Downloaded (Dir & Working_On.Id & "/attachments/") then
               Ada.Calendar.Arithmetic.Difference (Right           => Attachment.Created_At,
                                                   Left            => Ada.Calendar.Clock, 
                                                   Days            => Days, 
                                                   Seconds         => Seconds, 
                                                   Leap_Seconds    => Leap_Seconds);
               if Interactive then
                  Ada.Text_Io.Put_Line (Counter'Img &
                                          "; Filename: " & To_String (Attachment.File_Name) & 
                                          "; Length = " & Natural'Image (Attachment.Length / 1024) & " Kb" & 
                                          "; Uploaded " & Days'Img & " days ago");
               end if;
               Counter := Counter + 1;
            end if;
         end;
      end loop;
      if Interactive then
         Ada.Text_IO.Put_Line ("Please enter attachment(-s) to download separated by comma (Hit ENTER to dowload all). ");
         Ada.Text_Io.Put_Line ("To download attchemts for last N days (hours) use Nd (or Nh):");
         Ada.Text_Io.Put ("To download last N attachments use -N :");
      end if;
      declare
         Raw_Selection  : constant String                               := (if not Interactive then Input else Ada.Text_IO.Get_Line);
         Delimeter      : constant String                               := ",";
         Retval         : Casendra.Attachments.Attachments_T;
      begin
         if Raw_Selection'Length = 0 then
            return Attachments;
         end if;
         if Ada.Characters.Handling.Is_Letter (Raw_Selection (Raw_Selection'Last)) then
            -- Assuming time delta has been specified
            declare 
               use Ada.Calendar;
               Timestamp        : Time  := Get_Time_Stamp (Raw_Selection);
            begin
               for Attach of Attachments  loop
                  if Timestamp < Attach.Created_At then
                     Retval.Append (Attach);
                  end if;
               end loop;
            end;
               
         else
            for Index of Casendra.Text_Utils.String_To_Natural_Array (Raw_Selection, Delimeter) loop
               Retval.Append (Attachments (Index));
            end loop;
         end if;
         return Retval;
      end;
      raise Program_Error;
   end Select_Attachment_To_Download;
   
   
   
   use type Casendra.Text_Utils.Natural_Array_Access;

begin
   if not Interactive then
      Casendra.Cases.Init (Working_On, Caseid);
   else
      if Ada.Command_Line.Argument_Count < 1 then
         Usage;
      end if;
      Casendra.Cases.Init (Working_On, Ada.Command_Line.Argument (1));
   end if;
   
   Casendra.Cases.Save_History (Working_On, Dir);
   loop
  Try:
      begin
         Selection      := Select_Attachment_To_Download (Working_On);
         exit;
      exception
         when others    =>
            if Interactive then
               Ada.Text_IO.Put_Line ("Invalid input. Please try again!");
            else
               raise;
            end if;
      end Try;
   end loop;
   
   if Interactive then
      Casendra.Cases.Download_Attachment (Working_On,
                                          Selection, 
                                          Dir              => Dir,
                                          Callback => Display_Progress'Access);
   else
      Casendra.Cases.Download_Attachment (Working_On,
                                          Selection, 
                                          Dir              => Dir,
                                          Callback => Display_Progress_Non_Interactive'Access);
   end if;
   
                                       
   
   
end Csdownloader;
