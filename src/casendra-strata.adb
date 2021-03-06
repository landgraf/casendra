with Ada.Directories;
with Ada.Calendar;
with AWS.Client;
with AWS.Response;
with AWS.Headers.Set;
with AWS.Messages;
with AWS.Headers;
with AWS.Net.SSL.Certificate;
with Ada.Streams.Stream_IO;
with AWS.URL;
with Ada.Text_IO;
with Interfaces.C.Strings;


package body Casendra.Strata is
   
   procedure Connect (Connection : out Connection_T) is
      use type AWS.Net.SSL.Certificate.Object;
   begin
      AWS.Client.Create (Connection => Connection.Connection,
                         Host       => Strata_URI,
                         User       => User,
                         Pwd        => Pass);
      if AWS.Client.Get_Certificate (Connection.Connection) = AWS.Net.SSL.Certificate.Undefined then
         raise Program_Error with "not secured";
      end if;
   end Connect;
   
   
   function Get (URI : in String; Connection : in out Connection_T) return String is
      Response : AWS.Response.Data;
      Headers  : AWS.Headers.List := AWS.Headers.Empty_List;
      use type AWS.Messages.Status_Code;
   begin
      AWS.Headers.Set.Add (Headers, "Accept", Content);
      AWS.Client.Get (Connection => Connection.Connection,
                      URI        => URI,
                      Result     => Response,
                      Headers    => Headers);
      if AWS.Response.Status_Code (Response) in AWS.Messages.Success then
         return Aws.Response.Message_Body (Response);
      else
         raise Program_Error with "ERROR: Getting URL=" & URI & 
           "; with Status_Code = "  & AWS.Response.Status_Code (Response)'Img &
           "; Message: " & AWS.Response.Message_Body (Response) ;
      end if;
   end Get;
   
   function Get_Comments_JSON (Case_Id : in String; Connection : in out Connection_T ) return String
   is
      URL : constant String := Cases_Suffix & Case_Id & "/comments/";
   begin
      return Get (URL, Connection);
   end Get_Comments_JSON;
   
   function Get_Attachments_JSON (Case_Id : in String; Connection : in out Connection_T ) return String
   is
      URL : constant String := Cases_Suffix & Case_Id & "/attachments/";
   begin
      return Get (URL, Connection);
   end Get_Attachments_JSON;
   
   function Get_Case_JSON (Case_Id      : in     String;
                          Connection    : in out Connection_T) return String
   is
      URL : constant String := Cases_Suffix & Case_Id;
   begin
      return Get (URL, Connection);
   end Get_Case_JSON;

   
   procedure Download (URI                           : in String;
                       Length                        : in Natural;
                       Uuid                          : in String;
                       Connection                    : in out Connection_T;
                       Filename                      : in String;
                       Overwrite                     : in Boolean := False;
                       Progress                      : not null access 
                         procedure (Left : in Natural) := Null_Progress'Access) is
      procedure Symlink (Source : in String; Target : in String) is
         package C renames Interfaces.C;
         use type C.Int;
         function C_Symlink (path1: C.Strings.Chars_Ptr; path2 : C.Strings.Chars_Ptr)
                            return Interfaces.C.Int with Import, Convention => C, External_Name => "symlink";
         procedure Perror with Import, Convention => C, External_Name => "perror";
      begin
         if C_Symlink (C.Strings.New_String (Source), C.Strings.New_String (Target)) /= 0 then
            pragma Debug (Ada.Text_Io.Put_Line ("Failed to create uuid symlink" ));
            pragma Debug (Perror);
         end if;
      end Symlink;
      
      Buffer_Size   : constant Ada.Streams.Stream_Element_Offset := 10000;
      Tmp_Filename  : constant String := Filename & ".part"; -- Firefox style
      File          : Ada.Streams.Stream_IO.File_Type;
      Output_Stream : Ada.Streams.Stream_IO.Stream_Access;
      Buffer        : Ada.Streams.Stream_Element_Array (1 .. Buffer_Size);
      Last          : Ada.Streams.Stream_Element_Offset := 0;
      Response      : AWS.Response.Data;
      Left          : Natural := Length;
      use type AWS.Client.Content_Bound;
      
      -- However this thread could be simply removed and Progress callback
      -- called from the main thread it will lead issue with terminal window
      -- updating too frequently and not readable
      -- To keep readability we have to keep this thread unless we don't use terminal output anymore
      task Monitor;
      -- Starting monitoring thread which calls every *Interval* 
      -- callback procedure to update client with the progress
      task body Monitor is
         Interval : Duration := 1.0;
         Last_Updated : Ada.Calendar.Time := Ada.Calendar.Clock;
         Prev_Left : Natural := 0;
         Timeout : Duration := 10.0; -- Do the action is progress don't change for TimeOut secs
         use type Ada.Calendar.Time;
      begin
         while Left > 0 loop
            declare
               subtype Percents_T is Natural range 0 .. 100;
               Percents : Percents_T := 100 -  Natural ((Float (Left) / Float (Length)) * 100.0);
            begin
               if Prev_Left /= Left then
                 Last_Updated := Ada.Calendar.Clock;
                 Progress (Percents);
               else
                 if Ada.Calendar.Clock - Last_Updated > Timeout then
                   pragma Debug(Ada.Text_IO.Put_Line ("DEBUG: Downloader is stuck for more than " & Timeout'Img & " secs"));
                   null; -- terminate downloader ?
                 end if;
               end if;
               Prev_Left := Left;
            end;
            delay Interval;
         end loop;
         Progress (100 - Left);
      exception
         when others =>
            -- TODO ?? Send -1  to callback to indicate that something went wrong ??
            pragma Debug (Ada.Text_IO.Put_Line ("Exception in monitoring thread. Left = " & Left'Img & "; Length = " & Length'Img));
      end Monitor;
      
   begin
     -- removing any leftovers
     if Ada.Directories.Exists (Tmp_Filename) then
       Ada.Directories.Delete_File (Tmp_Filename);
     end if;
      if Ada.Directories.Exists (Filename) then
         if not Overwrite then
            pragma Debug (Ada.Text_IO.Put_Line ("File already exists. Skipping"));
            Left := 0;
            return;
         end if;
         Ada.Streams.Stream_IO.Open (File, Ada.Streams.Stream_IO.Out_File, Tmp_Filename);
      else
         Ada.Streams.Stream_IO.Create (File, Ada.Streams.Stream_IO.Out_File, Tmp_Filename);
      end if;
      Output_Stream := Ada.Streams.Stream_IO.Stream (File);
      AWS.Client.Set_Streaming_Output (Connection.Connection, True);
      AWS.Client.Get (Connection.Connection,
                      Response,
                      URI);
   Try:
      begin
         loop
            exit when Left = 0;
            AWS.Client.Read (Connection.Connection, Buffer, Last);
            Ada.Streams.Stream_IO.Write (File, Buffer ( Buffer'First .. Last));
            Left := Left - Natural (Last);
         end loop;
      exception
         when others => 
            Left := 0;
            Ada.Streams.Stream_IO.Close (File);
            return;
      end Try;
      Ada.Streams.Stream_IO.Close (File);
      -- Assuming move operation is atomic inside of the FS
      Ada.Directories.Rename (Tmp_Filename, Filename);
      -- Create symlink to keep uuid
      Symlink (Filename, Ada.Directories.Containing_Directory (Filename) & "/.by-uuid/" & Uuid);
   end Download;
end Casendra.Strata;
