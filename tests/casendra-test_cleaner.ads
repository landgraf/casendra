with Aunit; use Aunit;
with Casendra;
with Casendra.Cases;
with Aunit.Simple_Test_Cases;
package Casendra.Test_Cleaner is
   
   
    type TC is new Simple_Test_Cases.Test_Case with record
       C1 : Casendra.Cases.Case_T;
    end record;

    overriding
    procedure Tear_Down (T : in out TC) is null;

    overriding
    procedure Run_Test (T : in out TC); 

    overriding
    function Name (T : TC) return Message_String;
    
private
   Dir  : String       := Config_FIle.Get_String (Casendra.Config,
                                                  "downloader.directory",
                                                  False, 
                                                  "/tmp/folder/");
   Caseid : constant String := "00529192";
   Case_Dir : constant String := Dir & "/" & Caseid;
   Attachments_Dir : constant String := Case_Dir & "/attachments/";

end Casendra.Test_Cleaner;
