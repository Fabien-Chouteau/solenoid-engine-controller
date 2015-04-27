with Ada.Real_Time;
with Solenoid_Control;

procedure Solenoid_Engine is
begin
   Solenoid_Control.Initialize;

   --  The controller is all interrupt driven, we can set this task to sleep
   --  forever.
   delay until Ada.Real_Time.Time_Last;
end Solenoid_Engine;
