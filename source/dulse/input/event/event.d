module dulse.input.event.event;

import dulse.input;
import dulse.math.linalg.vector;
import std.sumtype;
import std.typecons : tuple, Tuple;
import core.time : MonoTime;

import std.meta : AliasSeq;

alias AnyEvent = SumType!(
	QuitEvent,
	WindowMaximizedEvent,
	WindowMinimizedEvent,
	MouseMotionEvent,
	MouseButtonEvent,
	MouseWheelEvent,
	KeyboardKeyEvent,
	TextEditingEvent,
	TextEditCandidateEvent,
	TextInputEvent,
	GamepadButtonEvent,
	GamepadAxisEvent, //GamepadEvent,

	

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

	bool has(Type)() const pure nothrow @nogc @safe
	{
		return this.data.has!Type();
	}

	inout(Type) get(Type)() inout pure nothrow @nogc @safe
	{
		return this.data.get!(inout(Type))();
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
	else static if (event_type!(Type).major == EventTypeMajor.text)
	{
		return Event(
			cast(MonoTime) time,
			event_type!Type,
			AnyEvent(event_data),
		);
	}
	else static if (event_type!(Type).major == EventTypeMajor.mouse)
	{
		static if (event_type!Type.minor == EventTypeMinor.mouse_motion)
		{
			return Event(
				cast(MonoTime) time,
				event_type!Type,
				AnyEvent(event_data),
			);
		}
		else static if (event_type!Type.minor == EventTypeMinor.mouse_button)
		{
			return Event(
				cast(MonoTime) time,
				event_type!Type,
				AnyEvent(event_data),
			);
		}
		else static if (event_type!Type.minor == EventTypeMinor.mouse_wheel)
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
	else static if (event_type!(Type).major == EventTypeMajor.gamepad)
	{
		static if (event_type!Type.minor == EventTypeMinor.gamepad_button)
		{
			return Event(
				cast(MonoTime) time,
				event_type!Type,
				AnyEvent(event_data),
			);
		}
		else static if (event_type!Type.minor == EventTypeMinor.gamepad_axis)
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
	text,
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
	text_editing,
	text_input,
	text_candidate,
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
	else static if (is(Type == TextEditingEvent))
	{
		return EventType(EventTypeMajor.text, EventTypeMinor.text_editing);
	}
	else static if (is(Type == TextEditCandidateEvent))
	{
		return EventType(EventTypeMajor.text, EventTypeMinor.text_candidate);
	}
	else static if (is(Type == TextInputEvent))
	{
		return EventType(EventTypeMajor.text, EventTypeMinor.text_input);
	}
	else static if (is(Type == MouseMotionEvent))
	{
		return EventType(EventTypeMajor.mouse, EventTypeMinor.mouse_motion);
	}
	else static if (is(Type == MouseButtonEvent))
	{
		return EventType(EventTypeMajor.mouse, EventTypeMinor.mouse_button);
	}
	else static if (is(Type == MouseWheelEvent))
	{
		return EventType(EventTypeMajor.mouse, EventTypeMinor.mouse_wheel);
	}
	else static if (is(Type == GamepadButtonEvent))
	{
		return EventType(EventTypeMajor.gamepad, EventTypeMinor.gamepad_button);
	}
	else static if (is(Type == GamepadAxisEvent))
	{
		return EventType(EventTypeMajor.gamepad, EventTypeMinor.gamepad_axis);
	}
	else
	{
		assert(false);
	}
}
