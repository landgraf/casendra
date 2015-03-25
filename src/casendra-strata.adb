with AWS.Client;
with AWS.Response;
with AWS.Headers.Set;
with AWS.Messages;
with AWS.Headers;
with AWS.Net.SSL.Certificate;
with Ada.Streams.Stream_IO;
with AWS.URL;


-- this is for debug only
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
      pragma Debug (Ada.Text_IO.Put_Line ("DEBUG: strata.get:" & URI));
      AWS.Client.Get (Connection => Connection.Connection,
		      URI => URI,
		      Result => Response,
		      Headers => Headers);
      if AWS.Response.Status_Code (Response) in AWS.Messages.Success then
	 Ada.Text_IO.Put_Line ("DEBUG: Response " &  Aws.Response.Message_Body (Response));
	 return Aws.Response.Message_Body (Response);
      else
	 raise Program_Error with "ERROR: Getting URL=" & URI & 
	   "; with Status_Code = "  & AWS.Response.Status_Code (Response)'Img &
	   "; Message: " & AWS.Response.Message_Body (Response) ;
      end if;
   end Get;
   
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
		       Overwrite : in Boolean := False) is
     Buffer_Size : constant Ada.Streams.Stream_Element_Offset := 1000;
     Buffer : Ada.Streams.Stream_Element_Array (1 .. Buffer_Size);
     last : Ada.Streams.Stream_Element_Offset := 0;
     Response : AWS.Response.Data;
     Left : Natural := Length;
     use type AWS.Client.Content_Bound;
   begin
     AWS.Client.Set_Streaming_Output (Connection.Connection, True);
     AWS.Client.Get (Connection.Connection,
                     Response,
                     URI);
     loop
         exit when Left = 0;
         AWS.Client.Read (Connection.Connection, Buffer, Last);
         Left := Left - Natural (Last);
     end loop;
   end Download;
end Casendra.Strata;
