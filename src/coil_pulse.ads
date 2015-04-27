with Pulse_Control; use Pulse_Control;

package Coil_Pulse is
   type Coil_Pulse_Controller is new Pulse_Controller with null record;

   overriding
   procedure Start (Self : in out Coil_Pulse_Controller);
   overriding
   procedure Stop (Self : in out Coil_Pulse_Controller);

   procedure Initialize;

end Coil_Pulse;
