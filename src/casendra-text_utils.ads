with Ada.Unchecked_Deallocation;
package casendra.text_utils is 

  type Natural_Array is array (Positive range <>) of Natural;
  type Natural_Array_Access is access all Natural_Array;

  function String_To_Natural_Array (Input : in String; Delimeter : in String) return Natural_Array;
  procedure Free is new Ada.Unchecked_Deallocation (Natural_Array, Natural_Array_Access);

end casendra.text_utils; 
