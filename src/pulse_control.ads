with Ada.Real_Time; use Ada.Real_Time;
with Ada.Real_Time.Timing_Events; use Ada.Real_Time.Timing_Events;

--  This package provides a convenient interface to generate pulse signal.

package Pulse_Control is

   type Pulse_Controller is abstract new Timing_Event with private;

   procedure Start (Ctrl : in out Pulse_Controller) is abstract;
   procedure Stop (Ctrl : in out Pulse_Controller) is abstract;

   procedure Pulse (Ctrl        : in out Pulse_Controller;
                    Start, Stop : Time);

private
   type Pulse_Controller is abstract new Timing_Event with record
      Stop_Time : Time;
   end record;
end Pulse_Control;
