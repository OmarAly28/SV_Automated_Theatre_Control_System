# SV_Automated_Theatre_Control_System
This project implements a synchronous control system for a multi-purpose the
atre. The system is responsible for coordinating the house lights, visualization
display, and the theatre’s spotlight based on the selected mode of operation and
three active-low position sensors. The design is implemented using two interact
ing finite-state machines (FSM): a Mode FSM that manages theater modes and a
Spotlight FSM that controls spotlight movement, and on/off behavior.
The system is required to:
• Support four mutually exclusive modes selected by switches: House, Music,
Mode, Display
• Use an overall enable signal (EN) so that the theatre can be shut down and
safely transitioned to an “all off” state with House lights on, or be turned on
and the system be active.
• Ensure that the default behavior when the system is enabled is to have the
house lights on.
• Control a spotlight that tracks the performer using three active-low sensors:
left (TL), center (TC), and right (TR).
• Enforce that spotlight movement between left and right passes through the
center position.
• Ensureall modechangespassthroughanintermediatestatewherealllights
are off.
