with Csdownloader;
with Ada.Directories;
with Casendra.Directories;
with Aunit.Assertions;
package body Casendra.Test_Downloader is 
   
   procedure Tear_Down (T : in out TC) is
      -- Remove downloaded files, close connections
   begin
      -- Do some real things here
      if Ada.Directories.Exists (Case_Dir) then
         Casendra.Directories.Delete_Tree (Case_Dir);
      end if;
   end Tear_Down;


   procedure Run_Test (T : in out TC) is
      -- Download attachments based on number selection
      -- Download attachments based on timestamp selection
      use Aunit.Assertions;
      File1 : constant String := Attachments_Dir & "/rhevm2.2-status2.jpg";
      File2 : constant String := Attachments_Dir & "/rhevm2.2-status.jpg";
      File3 : constant String  := Attachments_Dir & "/rhevm2.2-status1.jpg";
   begin
      Assert (Condition => not Ada.Directories.Exists (Case_Dir), Message => "case directory exists");
      Csdownloader (Caseid => Caseid, Input => "2,5,4", Interactive => False);
      Assert (Condition => Ada.Directories.Exists (Attachments_Dir), Message => "attchments directory doesn't exist");
      Assert (Condition => Ada.Directories.Exists (File1), Message => "File " & File1 & " is missed");
      Assert (Condition => Ada.Directories.Exists (File2), Message => "File " & File2 & " is missed");
      Assert (Condition => Ada.Directories.Exists (File3), Message => "File " & File3 & " is missed");
   end Run_Test;

   function Name (T : TC) return Message_String is
   begin
      return Aunit.Format ("Test case name : Casendra.downloader");
   end Name;

end Casendra.Test_Downloader;
