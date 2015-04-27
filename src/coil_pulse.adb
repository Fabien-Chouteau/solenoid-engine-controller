with Registers;     use Registers;
with STM32F4;       use STM32F4;
with STM32F4.GPIO;  use STM32F4.GPIO;
with Ada.Unchecked_Conversion;

package body Coil_Pulse is

   --  H-bridge controls are wired to PE4, PE5 and PE6
   type IO_Pin is (Dir_1_A, Dir_1_B, Enable_1);
   for IO_Pin'Size use Word'Size;

   for IO_Pin use
     (Dir_1_A  => 4,  -- PE4
      Dir_1_B  => 5,  -- PE5
      Enable_1 => 6); -- PE6

   function As_Word is new Ada.Unchecked_Conversion
     (Source => IO_Pin, Target => Word);

   --------
   -- On --
   --------

   procedure On (This : IO_Pin) is
   begin
      GPIOE.BSRR := As_Word (This);
   end On;

   ---------
   -- Off --
   ---------

   procedure Off (This : IO_Pin) is
   begin
      GPIOE.BSRR := Shift_Left (As_Word (This), 16);
   end Off;

   ----------------
   -- Initialize --
   ----------------

   procedure  Initialize is
      RCC_AHB1ENR_GPIOE : constant Word := 2**4;
   begin
      --  Enable clock for GPIO-E
      RCC.AHB1ENR := RCC.AHB1ENR or RCC_AHB1ENR_GPIOE;

      --  Configure PE4, PE5 and PE6
      GPIOE.MODER (4 .. 6) := (Mode_OUT, Mode_OUT, Mode_OUT);
      GPIOE.OTYPER (4 .. 6) := (others => Type_PP);
      GPIOE.PUPDR (4 .. 6) := (others => Pull_Down);

      --  Set the H-bridge in one direction
      On (Dir_1_B);
      Off (Dir_1_A);

      --  Disable the H-bridge
      Off (Enable_1);
   end Initialize;

   -----------
   -- Start --
   -----------

   overriding procedure Start (Self : in out Coil_Pulse_Controller)
   is
      pragma Unreferenced (Self);
   begin
      --  Enable the H-bridge
      On (Enable_1);
   end Start;

   ----------
   -- Stop --
   ----------

   overriding procedure Stop (Self : in out Coil_Pulse_Controller)
   is
      pragma Unreferenced (Self);
   begin
      --  Disable the H-bridge
      Off (Enable_1);
   end Stop;

end Coil_Pulse;
