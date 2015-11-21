with Ada.Interrupts.Names;
with Ada.Real_Time; use Ada.Real_Time;
with STM32F4;       use STM32F4;
with STM32F4.GPIO;  use STM32F4.GPIO;
with Coil_Pulse; use Coil_Pulse;
with LED_Pulse;
with STM32F429_Discovery;
use STM32F429_Discovery;
with STM32F4.SYSCFG; use STM32F4.SYSCFG;
with Engine_Control_Events; use Engine_Control_Events;
with Giza.GUI;

package body Solenoid_Control is

   Sensor_Port : GPIO_Port renames STM32F429_Discovery.GPIO_A;
   Sensor_Pin  : constant GPIO_Pin  := Pin_0;
   RPM_Evt     : aliased Set_RPM_Event;

   Ignition_Ratio : Float := 0.25;
   Duration_Ratio : Float := 0.5;

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

   ------------
   -- Sensor --
   ------------

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

            --  We start energizing at Ignition_Ratio % of the TDC to BDC time
            Ignition    :=  TDC_To_BDC * Ignition_Ratio;

            --  We energize the coil during Duration_Ratio % of the TDC to
            --  BDC time.
            Power_Phase := TDC_To_BDC * Duration_Ratio;

            --  Convert to start and stop time
            Start := Now   + Milliseconds (Natural (1000.0 * Ignition));
            Stop  := Start + Milliseconds (Natural (1000.0 * Power_Phase));

            --  Send the pulse command
            Coil_Control.Pulse (Start, Stop);

            --  Also start a LED pulse for a visual indication that the coil is
            --  energized.
            LED_Control.Pulse (Start, Stop);
         end if;

         --  Send the new RPM value to the GUI
         RPM_Evt.RPM := RPM;
         Giza.GUI.Emit (RPM_Evt'Access);
      end Interrupt_Handler;
   end Sensor;

   -------------
   -- Get_RPM --
   -------------

   function Get_RPM return Natural is (Sensor.Get_RPM);

   ----------------
   -- Initialize --
   ----------------

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

   ------------------
   -- Set_Ignition --
   ------------------

   procedure Set_Ignition (Ignition : PP_Range) is
   begin
      Ignition_Ratio := Float (Ignition) / 100.0;
   end Set_Ignition;

   ------------------
   -- Set_Duration --
   ------------------

   procedure Set_Duration (Duration : PP_Range) is
   begin
      Duration_Ratio := Float (Duration) / 100.0;
   end Set_Duration;

   ------------------
   -- Get_Ignition --
   ------------------

   function Get_Ignition return PP_Range is
   begin
      return PP_Range (Ignition_Ratio * 100.0);
   end Get_Ignition;

   ------------------
   -- Get_Duration --
   ------------------

   function Get_Duration return PP_Range is
   begin
      return PP_Range (Duration_Ratio * 100.0);
   end Get_Duration;

end Solenoid_Control;
