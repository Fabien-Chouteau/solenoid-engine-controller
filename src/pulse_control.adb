with System;

package body Pulse_Control is

   protected Pulse_Procedures is
      pragma Priority (System.Interrupt_Priority'Last);
      procedure Start_Pulse (Event : in out Timing_Event);
      procedure Stop_Pulse (Event : in out Timing_Event);
   end Pulse_Procedures;

   protected body Pulse_Procedures is

      -----------------
      -- Start_Pulse --
      -----------------

      procedure Start_Pulse (Event : in out Timing_Event) is
         Stop_Time : Time;
      begin
         Stop_Time := Pulse_Controller
           (Timing_Events.Timing_Event'Class (Event)).Stop_Time;

         --  Dispatching call to Start
         Pulse_Controller'Class
           (Timing_Events.Timing_Event'Class (Event)).Start;

         --  Setup event for stop
         Set_Handler (Event   => Event,
                      At_Time => Stop_Time,
                      Handler => Stop_Pulse'Access);
      exception
         when others =>
            null;
      end Start_Pulse;

      ----------------
      -- Stop_Pulse --
      ----------------

      procedure Stop_Pulse (Event : in out Timing_Event) is
      begin
         --  Dispatching call to Stop
         Pulse_Controller'Class
           (Timing_Events.Timing_Event'Class (Event)).Stop;
      exception
         when others =>
            null;
      end Stop_Pulse;
   end Pulse_Procedures;

   -----------
   -- Pulse --
   -----------

   procedure Pulse (Ctrl        : in out Pulse_Controller;
                    Start, Stop : Time) is
   begin
      Ctrl.Stop_Time := Stop;

      --  Setup event for start
      Set_Handler (Event   => Ctrl,
                   At_Time => Start,
                   Handler => Pulse_Procedures.Start_Pulse'Access);
   end Pulse;

end Pulse_Control;
