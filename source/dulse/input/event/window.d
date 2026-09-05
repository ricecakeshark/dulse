module dulse.input.event.window;

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
