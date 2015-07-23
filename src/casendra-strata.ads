with AWS.Client;
with Config_File;
package Casendra.Strata is
   
   type Connection_T is limited private;
   
   function Get_Attachments_JSON (Case_Id       : in     String;
                                  Connection    : in out Connection_T) return String;
   function Get_Comments_JSON (Case_Id          : in       String;
                               Connection       : in out Connection_T) return String;
   function Get_Case_JSON (Case_Id      : in     String;
                           Connection   : in out Connection_T) return String;
   
   procedure Connect (Connection : out Connection_T);
   procedure Null_Progress (Value : in Natural) is null;
   
   procedure Download (URI                           : in String;
                       Length                        : in Natural;
                       Uuid                          : in String;
                       Connection                    : in out Connection_T;
                       Filename                      : in String;
                       Overwrite                     : in Boolean := False;
                       Progress                      : not null access 
                         procedure (Left : in Natural) := Null_Progress'Access);
   
private
   Strata_URI : constant String := Config_File.Get_String (Config, "strata.host", False, "https://localhost/");
   Cases_Suffix : constant String := "/rs/cases/";
   Content : constant String := "application/json";
   User : constant String := Config_File.Get_String (Config, "strata.username", False, "");
   Pass : constant String := Config_File.Get_String (Config, "strata.password", False, "");
   
   
   type Connection_T is limited record
      Connection : AWS.Client.Http_Connection;
   end record;
   
   function Get (URI : in String; Connection : in out Connection_T) return String;
end Casendra.Strata;
