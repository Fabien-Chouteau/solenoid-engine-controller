with STM32F4;       use STM32F4;
with STM32F4.GPIO;  use STM32F4.GPIO;
with STM32F429_Discovery;

package body Coil_Pulse is

   H_Bridge_Port : GPIO_Port renames STM32F429_Discovery.GPIO_E;

   --  H-bridge controls are wired to PE4, PE5 and PE6
   type IO_Pin is (Dir_1_A, Dir_1_B, Enable_1);
   for IO_Pin'Size use Word'Size;

   To_IO_Pin : constant array (IO_Pin) of GPIO_Pin :=
     (Dir_1_A  => Pin_4,  -- PE4
      Dir_1_B  => Pin_5,  -- PE5
      Enable_1 => Pin_6); -- PE6

   procedure On (This : IO_Pin);
   procedure Off (This : IO_Pin);

   --------
   -- On --
   --------

   procedure On (This : IO_Pin) is
   begin
      Set (H_Bridge_Port, To_IO_Pin (This));
   end On;

   ---------
   -- Off --
   ---------

   procedure Off (This : IO_Pin) is
   begin
      Clear (H_Bridge_Port, To_IO_Pin (This));
   end Off;

   ----------------
   -- Initialize --
   ----------------

   procedure  Initialize is
      Config : GPIO_Port_Configuration;
   begin

      STM32F429_Discovery.Enable_Clock (H_Bridge_Port);

      Config.Mode := Mode_Out;
      Config.Speed := Speed_100MHz;
      Config.Resistors := Pull_Down;
      Config.Output_Type := Push_Pull;

      Configure_IO (H_Bridge_Port,
                    (To_IO_Pin (Dir_1_A),
                     To_IO_Pin (Dir_1_B),
                     To_IO_Pin (Enable_1)),
                    Config);

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
