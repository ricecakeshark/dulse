module kelp_core.input.event.window;

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
