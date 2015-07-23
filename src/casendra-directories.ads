with Interfaces.C.Strings;
package Casendra.Directories is 
   procedure Delete_Tree (Name : in String);
   Directories_Error : exception;
private
   package C renames Interfaces.C;
end Casendra.Directories;
