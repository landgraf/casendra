with Ada.Strings.Fixed;
package body casendra.text_utils is 

  function String_To_Natural_Array (Input : in String; Delimeter : in String) return Natural_Array is
    Retval : Natural_Array (1 ..  Ada.Strings.Fixed.Count (Input, Delimeter) + 1);
    Next_Cursor : Natural := 0;
    Cursor : Natural := 0;
    function String_To_Natural (Input : in String) return Natural is
    begin
      return Natural'Value (Input);
    end String_To_Natural;
  begin
    if Retval'Length /= 1 then
      if Input = "" then
        raise PROGRAM_ERROR with "Empty string";
      end if;
      for Index in Retval'First .. Retval'Last - 1 loop
        Next_Cursor := Ada.Strings.Fixed.Index (Input (Cursor + 1 .. Input'Last), Delimeter);
        Retval (Index) := String_To_Natural (Input (Cursor + 1  .. Next_Cursor - 1));
        Cursor := Next_Cursor;
      end loop;
    end if;
    return Retval;
  end String_To_Natural_Array;

end casendra.text_utils; 

