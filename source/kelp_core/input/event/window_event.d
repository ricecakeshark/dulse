module kelp_core.input.event.window_event;

import std.sumtype;

alias WindowEvent = SumType!(
	WindowMaximizedEvent,
	WindowMinimizedEvent,
);

/+struct WindowEvent
{

}+/

struct WindowMaximizedEvent
{

}

struct WindowMinimizedEvent
{

}
