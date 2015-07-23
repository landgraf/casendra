with Aunit.Assertions;
with Ada.Directories;
with Csclean;
with Csclean;
with Csdownloader;
with Aunit.Assertions;
with Ada.Directories;
package body Casendra.Test_Cleaner is
   procedure Run_Test (T : in out TC) is
      -- Download attachments based on number selection
      -- Download attachments based on timestamp selection
      use Aunit.Assertions;
   begin
      Assert (Condition => not Ada.Directories.Exists (Case_Dir), Message => "Case directory exists");
      Csdownloader (Caseid => Caseid, Input => "", Interactive => False);
      Assert (Condition => Ada.Directories.Exists (Case_Dir), Message => "Case directory doesn't exist");
      Csclean (Interactive => False);
      Assert (Condition => not Ada.Directories.Exists (Case_Dir), Message => "Case directory exists after cleanup");
   end Run_Test;
   
   
   function Name (T : TC) return Message_String is
   begin
      return Aunit.Format ("Test case name : Casendra.cleaner");
   end Name;
   
end Casendra.Test_Cleaner;

