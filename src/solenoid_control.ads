with Power_Phase_Widget; use Power_Phase_Widget;

package Solenoid_Control is
   function Get_RPM return Natural;
   procedure Initialize;

   procedure Set_Ignition (Ignition : PP_Range);
   procedure Set_Duration (Duration : PP_Range);
   function Get_Ignition return PP_Range;
   function Get_Duration return PP_Range;
end Solenoid_Control;
