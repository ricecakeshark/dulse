module kelp_core.input.state.keyboard_state;

import kelp_core.device.keyboard;
import kelp_core.input;
import std.sumtype;

struct KeyboardState
{
	KeyboardKeyState[Scancode] state_dict;
}

struct KeyboardKeyState
{
	bool downed;
}

KeyboardState apply(ref KeyboardState state, KeyboardEvent[] event_list...) pure nothrow
{
	foreach (event; event_list)
	{
		state.apply(event.data.get!KeyboardKeyEvent);
	}
	return state;
}

KeyboardState apply(ref KeyboardState state, KeyboardKeyEvent event) pure nothrow
{
	state.state_dict[event.scancode].downed = event.downed;
	return state;
}
