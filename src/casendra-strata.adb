with Ada.Directories;
with AWS.Client;
with AWS.Response;
with AWS.Headers.Set;
with AWS.Messages;
with AWS.Headers;
with AWS.Net.SSL.Certificate;
with Ada.Streams.Stream_IO;
with AWS.URL;
with Ada.Text_IO;


package body Casendra.Strata is
   
   procedure Connect (Connection : out Connection_T) is
      use type AWS.Net.SSL.Certificate.Object;
   begin
      AWS.Client.Create (Connection => Connection.Connection,
          Host => Strata_URI,
          User => User,
          Pwd  => Pass);
      if AWS.Client.Get_Certificate (Connection.Connection) = AWS.Net.SSL.Certificate.Undefined then
    raise Program_Error with "not secured";
      end if;
   end Connect;
   
   
   function Get (URI : in String; Connection : in out Connection_T) return String is
      Response : AWS.Response.Data;
      Headers : AWS.Headers.List := AWS.Headers.Empty_List;
      use type AWS.Messages.Status_Code;
   begin
      AWS.Headers.Set.Add (Headers, "Accept", Content);
      AWS.Client.Get (Connection => Connection.Connection,
            URI => URI,
            Result => Response,
            Headers => Headers);
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
   
   procedure Download (URI : in String;
             Length : in Natural;
             Connection : in out Connection_T;
             Filename : in String;
             Overwrite : in Boolean := False;
             Progress  : not null access 
          procedure (Left : in Natural) := Null_Progress'Access) is
      Buffer_Size : constant Ada.Streams.Stream_Element_Offset := 1000;
      File : Ada.Streams.Stream_IO.File_Type;
      Output_Stream : Ada.Streams.Stream_IO.Stream_Access;
      Buffer : Ada.Streams.Stream_Element_Array (1 .. Buffer_Size);
      last : Ada.Streams.Stream_Element_Offset := 0;
      Response : AWS.Response.Data;
      Left : Natural := Length;
      use type AWS.Client.Content_Bound;
      
   begin
      if Ada.Directories.Exists (Filename) then
    if not Overwrite then
       pragma Debug (Ada.Text_IO.Put_Line ("File already exists. Skipping"));
       Left := 0;
       return;
    end if;
    Ada.Streams.Stream_IO.Open (File, Ada.Streams.Stream_IO.Out_File, Filename);
      else
    Ada.Streams.Stream_IO.Create (File, Ada.Streams.Stream_IO.Out_File, Filename);
      end if;
      Output_Stream := Ada.Streams.Stream_IO.Stream (File);
      AWS.Client.Set_Streaming_Output (Connection.Connection, True);
      AWS.Client.Get (Connection.Connection,
            Response,
            URI);
      loop
         exit when Left = 0;
         AWS.Client.Read (Connection.Connection, Buffer, Last);
    Ada.Streams.Stream_IO.Write (File, Buffer ( Buffer'First .. Last));
         Left := Left - Natural (Last);
         Progress (100 -  Natural((Float(Left)/Float(Length))*100.0));
      end loop;
      Ada.Streams.Stream_IO.Close (File);
   end Download;
end Casendra.Strata;
