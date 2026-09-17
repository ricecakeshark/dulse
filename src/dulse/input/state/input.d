module dulse.input.state.input;

import dulse.input.state;
import std.typecons;

//alias InputState = SumType!(KeyboardState, MouseState, GamepadState);
alias InputState = Tuple!(
	KeyboardState,"keyboard",
	MouseState,"mouse",
	GamepadState,"gamepad",
);