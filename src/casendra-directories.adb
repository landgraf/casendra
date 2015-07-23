with Ada.Text_Io;

package body Casendra.Directories is 

   procedure Delete_Tree (Name : in String)
   is 
      type Dir_T is null record;
      type Dir_Access_T is access all Dir_T;
      
      type Dir_Entry_T is null record;
      type Dir_Entry_Access_T is access all Dir_Entry_T;
      
      function C_Unlink (Name : in C.Strings.Chars_Ptr) return C.Int
      with Import, Convention => C, External_Name => ("unlink");
      -- Remove file/link
      
      function C_Rmdir (Name : in C.Strings.Chars_Ptr) return C.Int
      with Import, Convention => C, External_Name => ("rmdir");
      -- Remove (empty) dir
      
      function C_Opendir (Name : in C.Strings.Chars_Ptr) return Dir_Access_T
      with Import, Convention => C, External_Name => "opendir";
      
      function C_Readdir (Name : in C.Strings.Chars_Ptr) return Dir_Entry_Access_T
      with Import, Convention => C, External_Name => "readdir";
      
      function C_Remove (Name : in C.Strings.Chars_Ptr) return C.Int 
      with Import, Convention => C, External_Name => "remove";
      
      type Statbuf_T is null record;
      type Statbuf_Access_T is access all Statbuf_T;
      
      type Ftwbuf_T is null record;
      type Ftwbuf_Access_T is access all Ftwbuf_T;
      
      type Ftw_Flags_T is mod C.Int'Last;
      Ftw_Depth : constant Ftw_Flags_T := 8;
      Ftw_Phys : constant Ftw_Flags_T := 1;
      
      procedure Proceed (Name : in C.Strings.Chars_Ptr;
                         Statbuf : in Statbuf_Access_T;
                         Flags : in C.Int;
                         Ftw : in Ftwbuf_Access_T) with Convention => C;
      
      procedure Proceed (Name : in C.Strings.Chars_Ptr;
                         Statbuf : in Statbuf_Access_T;
                         Flags : in C.Int;
                         Ftw : in Ftwbuf_Access_T) 
      is
         use type C.Int;
      begin
         if C_Remove (Name) /= 0 then
            pragma Debug (Ada.Text_Io.Put_Line ("Failed to remove " & C.Strings.Value (Name)));
            raise Directories_Error with "Failed to remove " & C.Strings.Value (Name);
         end if;
      end Proceed;
      
      type Proceed_T is access procedure (Name : in C.Strings.Chars_Ptr;
                                          Statbuf : in Statbuf_Access_T;
                                          Flags : in C.Int;
                                          Ftw : in Ftwbuf_Access_T) with Convention => C;
      
      function C_Nftw (Name : in C.Strings.Chars_Ptr;
                       Callback : Proceed_T; Nopenfd : C.Int; Flags : Ftw_Flags_T) return C.Int 
      with Import, Convention => C, External_Name => "nftw";
      
      Res : C.Int;
   begin
      Res := C_Nftw (C.Strings.New_String (Name), Proceed'Access, 64, Ftw_Phys or Ftw_Depth); -- WARNING Magic number!

   end Delete_Tree;
end Casendra.Directories;
