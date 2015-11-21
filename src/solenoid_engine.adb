with Ada.Real_Time;
with Solenoid_Control;

with STM32F4.RCC; use STM32F4.RCC;
with UI;

pragma Warnings (Off);
with Last_Chance_Handler;
pragma Warnings (On);

procedure Solenoid_Engine is
begin
   UI.Initialize;

   Solenoid_Control.Initialize;

   UI.Start;

   --  The controller is all interrupt driven, we can set this task to sleep
   --  forever.
   delay until Ada.Real_Time.Time_Last;
end Solenoid_Engine;
