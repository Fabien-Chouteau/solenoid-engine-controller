with Ada.Interrupts.Names;
with Ada.Real_Time; use Ada.Real_Time;
with STM32F4;       use STM32F4;
with STM32F4.GPIO;  use STM32F4.GPIO;
with Coil_Pulse; use Coil_Pulse;
with LED_Pulse;
with STM32F429_Discovery;
use STM32F429_Discovery;
with STM32F4.SYSCFG; use STM32F4.SYSCFG;

package body Solenoid_Control is

   Sensor_Port : GPIO_Port renames STM32F429_Discovery.GPIO_A;
   Sensor_Pin  : constant GPIO_Pin  := Pin_0;

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
      LED_Control  : LED_Pulse.LED_Pulse_Controller (Red);
   end Sensor;

   protected body Sensor is

      function Get_RPM return Natural is (RPM);

      procedure Interrupt_Handler is
         Start, Stop : Time;
         Elapsed, TDC_To_BDC, Ignition, Power_Phase : Float;
         Now : Ada.Real_Time.Time := Ada.Real_Time.Time_First;
      begin
         Clear_External_Interrupt (Sensor_Pin);

         --  What time is it?
         Now := Clock;

         --  Time since last interrupt
         Elapsed := Float (To_Duration (Now - Last_Trig));

         --  Store trigger time for the next interrupt
         Last_Trig := Now;

         --  Compute number of revolutions per minute
         RPM := Natural (60.0 / Elapsed);

         --  We choose not to try to power the engine if it's current speed is
         --  less than 60 RPM. Below this speed, the rotation of the engine is
         --  not predictable enough for us to compute the right time to
         --  energize the coil.

         if RPM > 60 then

            --  How much time will the engine take to go from Top Dead Center
            --  to Bottom Dead Center (half of a turn) based on how much time
            --  it took to make the last complete rotation.
            TDC_To_BDC := Elapsed / 2.0;

            --  We start energizing at 25% of the TDC to BDC time
            Ignition    :=  TDC_To_BDC * 0.25;

            --  We energize the coil during 50% of the TDC to BDC time
            Power_Phase := TDC_To_BDC * 0.5;

            --  Convert to start and stop time
            Start := Now   + Milliseconds (Natural (1000.0 * Ignition));
            Stop  := Start + Milliseconds (Natural (1000.0 * Power_Phase));

            --  Send the pulse command
            Coil_Control.Pulse (Start, Stop);

            --  Also start a LED pulse for a visual indication that the coil is
            --  energized.
            LED_Control.Pulse (Start, Stop);
         end if;
      end Interrupt_Handler;
   end Sensor;

   function Get_RPM return Natural is (Sensor.Get_RPM);

   procedure Initialize is
      Config : GPIO_Port_Configuration;
   begin
      STM32F429_Discovery.Initialize_LEDs;
      Coil_Pulse.Initialize;

      --  Enable clock for GPIO-A
      STM32F429_Discovery.Enable_Clock (Sensor_Port);

      --  Configure PA0

      Config.Mode := Mode_In;
      Config.Speed := Speed_100MHz;
      Config.Resistors := Floating;

      Configure_IO (Sensor_Port, Sensor_Pin, Config);

      Connect_External_Interrupt (Sensor_Port, Sensor_Pin);
      Configure_Trigger (Sensor_Port, Sensor_Pin, Interrupt_Rising_Edge);
   end Initialize;

end Solenoid_Control;
