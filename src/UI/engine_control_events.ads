with Giza.Events; use Giza.Events;
with Power_Phase_Widget;

package Engine_Control_Events is

   type Set_RPM_Event is new Event with record
      RPM : Integer;
   end record;

   type Set_RPM_Event_Ref is not null access constant Set_RPM_Event;

   type Set_PP_Event is new Event with record
      Ignition : Power_Phase_Widget.PP_Range;
      Duration : Power_Phase_Widget.PP_Range;
   end record;

   type Set_PP_Event_Ref is not null access constant Set_PP_Event;

end Engine_Control_Events;
