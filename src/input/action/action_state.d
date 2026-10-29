module dulse.input.action.action_state;

import dulse.input.state.input;

struct ActionState(State)
{
	State value;
	/+
	void delegate(in InputState, ref State)[] binding;

	ref typeof(this) bind(in InputState input_state)
	{
		foreach (binder; this.binding)
		{
			binder(input_state, this.value);
		}
		return this;
	}+/
}
