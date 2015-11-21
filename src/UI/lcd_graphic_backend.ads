with Giza.Graphics; use Giza.Graphics;
with Giza.Colors;

generic
   type Color is (<>);
   type Width is range <>;
   type Height is range <>;
   with procedure Set_Pixel (X : Width; Y : Height; Hue : Color);
   with function As_Color (R, G, B : Giza.Colors.RGB_Component) return Color;
package LCD_Graphic_Backend is
   type LCD_Backend is new Backend with private;

   overriding
   procedure Set_Pixel (This : in out LCD_Backend; Pt : Point_T);

   overriding
   procedure Set_Color (This : in out LCD_Backend; C : Giza.Colors.Color);

   overriding
   function Size (This : LCD_Backend) return Size_T;

private
   type LCD_Backend is new Backend with record
      Current_Color : Color;
   end record;
end LCD_Graphic_Backend;
