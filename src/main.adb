with Ada.Command_Line;
with Ada.Text_IO;
with GNAT.OS_Lib;
with Casendra.Cases;
procedure Main is
   
   procedure Usage is
      use Ada.Text_IO;
   begin
      Put_Line ("casendrda download <case number>");
      Gnat.OS_Lib.OS_Exit (1);
   end Usage;
   
   Working_On : Casendra.Cases.Case_T;
begin
   if Ada.Command_Line.Argument_Count < 1 then
      Usage;
   end if;
   Casendra.Cases.Init (Working_On, Ada.Command_Line.Argument (1));
   Casendra.Cases.Download_Attachment (Working_On, 25);
   null;
end Main;
