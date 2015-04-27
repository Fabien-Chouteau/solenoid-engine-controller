with Ada.Real_Time; use Ada.Real_Time;

package body LED_Pulse is

   -----------
   -- Start --
   -----------

   overriding procedure Start (Self : in out LED_Pulse_Controller)
   is
   begin
      On (Self.My_LED);
   end Start;

   ----------
   -- Stop --
   ----------

   overriding procedure Stop (Self : in out LED_Pulse_Controller)
   is
   begin
      Off (Self.My_LED);
   end Stop;

   -------------
   -- Example --
   -------------

   procedure Example is
      Green_Ctrl : LED_Pulse_Controller (Green);
      Red_Ctrl   : LED_Pulse_Controller (Red);
      Now        : Time;
   begin

      loop
         Now := Clock;
         Pulse (Green_Ctrl, Now + Seconds (1), Now + Seconds (2));
         Pulse (Red_Ctrl, Now + Seconds (1), Now + Seconds (3));

         delay until Now + seconds (3);
      end loop;
   end Example;

end LED_Pulse;
