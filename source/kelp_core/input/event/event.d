module kelp_core.input.event.event;

import kelp_core.device;
import kelp_core.input;
import kelp_core.math.linalg.vector;
import std.sumtype;
import std.typecons : tuple, Tuple;
import core.time : MonoTime;

import std.meta:AliasSeq;

alias AnyEvent = SumType!(
	QuitEvent,
	WindowEvent,
	MouseEvent,
	KeyboardKeyEvent,
	GamepadEvent,
);
alias AllEvent = AliasSeq!(
	QuitEvent,
	WindowEvent,
	MouseEvent,
	KeyboardKeyEvent,
	GamepadEvent,
);


alias EventType = Tuple!(
	EventTypeMajor, "major",
	EventTypeMinor, "minor",
);

struct Event
{
	MonoTime time;
	EventType type;
	AnyEvent data;

	Type get(Type)()
	{
		return this.data.get!Type();
	}
}

public Event event(Type)(ulong time, Type event_data)
{
	static if (event_type!(Type).major == EventTypeMajor.quit)
	{
		return Event(
			cast(MonoTime) time,
			event_type!Type,
			AnyEvent(event_data),
		);
	}
	else static if (event_type!(Type).major == EventTypeMajor.window)
	{
		return Event(
			cast(MonoTime) time,
			event_type!Type,
			AnyEvent(WindowEvent(event_data)),
		);
	}
	else static if (event_type!(Type).major == EventTypeMajor.keyboard)
	{
		return Event(
			cast(MonoTime) time,
			event_type!Type,
			AnyEvent(event_data),
		);
	}
	else
	{
		assert(false);
	}
}

enum EventTypeMajor
{
	invalid,
	quit,
	window,
	keyboard,
	mouse,
	gamepad,
	other,
}

enum EventTypeMinor
{
	invalid,
	quit,
	window_minimized,
	window_maximized,
	window_shown,
	window_hidden,
	window_exposed,
	window_moved,
	window_resized,
	keyboard_key,
	mouse_motion,
	mouse_button,
	mouse_wheel,
	gamepad_button,
	gamepad_axis,
	other,
}

EventType event_type(Type)()
{
	static if (is(Type == QuitEvent))
	{
		return EventType(EventTypeMajor.quit, EventTypeMinor.quit);
	}
	else static if (is(Type == KeyboardKeyEvent))
	{
		return EventType(EventTypeMajor.keyboard, EventTypeMinor.keyboard_key);
	}
	else
	{
		assert(false);
	}
}
