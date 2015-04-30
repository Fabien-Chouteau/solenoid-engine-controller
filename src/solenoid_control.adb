with Ada.Interrupts.Names;
with Ada.Real_Time; use Ada.Real_Time;
with Registers;     use Registers;
with STM32F4;       use STM32F4;
with STM32F4.GPIO;  use STM32F4.GPIO;
with Coil_Pulse; use Coil_Pulse;
with LEDs;
with LED_Pulse;

package body Solenoid_Control is

   protected Sensor is
      pragma Interrupt_Priority;

      function Get_RPM return Natural;
   private
      procedure Interrupt_Handler;
      pragma Attach_Handler
         (Interrupt_Handler,
          Ada.Interrupts.Names.EXTI0_Interrupt);

      Last_Trig : Ada.Real_Time.Time := Ada.Real_Time.Time_First;
      RPM : Natural;

      Coil_Control : Coil_Pulse_Controller;
      LED_Control  : LED_Pulse.LED_Pulse_Controller (LEDs.Red);
   end Sensor;

   protected body Sensor is

      function Get_RPM return Natural is (RPM);

      procedure Interrupt_Handler is
         Start, Stop : Time;
         Elapsed, TDC_To_BDC, Ignition, Power_Phase : Float;
         Now : Ada.Real_Time.Time := Ada.Real_Time.Time_First;
      begin
         Now := Clock;

         --  Time since last interrupt
         Elapsed := Float (To_Duration (Now - Last_Trig));

         --  Current engine speed
         RPM := Natural (60.0 / Elapsed);

         Last_Trig := Now;

         --  We choose not to try to power the engine if it's current speed is
         --  less than 60 RPM. Below this speed, the rotation of the engine is
         --  not predictable enough for us to compute the right time to
         --  energize the coil.

         if RPM > 60 then

            --  How much time will the engine take to go from Top Dead Center
            --  to Bottom Dead Center (half of a turn) based on how much time
            --  it took to make the last complete rotation.
            TDC_To_BDC := Elapsed / 2.0;

            --  We start energizing at 20% of the TDC to BDC time
            Ignition    :=  TDC_To_BDC * 0.2;

            --  We energize the coil during 50% of the TDC to BDC time
            Power_Phase := TDC_To_BDC * 0.5;

            --  Convert to start and stop time
            Start := Now + Milliseconds (Natural (1000.0 * Ignition));
            Stop := Start + Milliseconds (Natural (1000.0 * Power_Phase));

            --  Send the pulse command
            Coil_Control.Pulse (Start, Stop);

            --  Also start a LED pulse for a visual indication that the coil is
            --  energized.
            LED_Control.Pulse (Start, Stop);
         end if;

         --  Clear interrupt
         EXTI.PR (0) := 1;
      end Interrupt_Handler;
   end Sensor;

   function Get_RPM return Natural is (Sensor.Get_RPM);

   procedure Initialize is
      RCC_AHB1ENR_GPIOA : constant Word := 16#01#;
   begin
      Coil_Pulse.Initialize;

      --  Enable clock for GPIO-A
      RCC.AHB1ENR := RCC.AHB1ENR or RCC_AHB1ENR_GPIOA;

      --  Configure PA0
      GPIOA.MODER (0) := Mode_IN;
      GPIOA.PUPDR (0) := No_Pull;

      --  Select PA for EXTI0
      SYSCFG.EXTICR1 (0) := 0;

      --  Interrupt on rising edge
      EXTI.FTSR (0) := 0;
      EXTI.RTSR (0) := 1;
      EXTI.IMR (0) := 1;
   end Initialize;

end Solenoid_Control;
