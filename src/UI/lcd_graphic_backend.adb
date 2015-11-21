package body LCD_Graphic_Backend is

   ---------------
   -- Set_Pixel --
   ---------------

   procedure Set_Pixel (This : in out LCD_Backend; Pt : Point_T) is
   begin
      if Pt.X in Dim (Width'First) .. Dim (Width'Last)
        and then
         Pt.Y in Dim (Height'First) .. Dim (Height'Last)
      then
         Set_Pixel (Width (Pt.X), Height (Pt.Y), This.Current_Color);
      end if;
   end Set_Pixel;

   ---------------
   -- Set_Color --
   ---------------

   procedure Set_Color (This : in out LCD_Backend; C : Giza.Colors.Color) is
   begin
      This.Current_Color := As_Color (C.R, C.G, C.B);
   end Set_Color;

   ----------
   -- Size --
   ----------

   function Size (This : LCD_Backend) return Size_T is
      pragma Unreferenced (This);
   begin
      return (Dim (Width'Last), Dim (Height'Last));
   end Size;

end LCD_Graphic_Backend;
