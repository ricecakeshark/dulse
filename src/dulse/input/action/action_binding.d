module dulse.input.action.action_binding;

import dulse.input;
import dulse.core.container;
import dulse.math.linalg.vector;

alias StateTable = TypeTable!(ActionState!Vec1, ActionState!Vec2);
alias Handler = void delegate(ref InputState state_list, ref StateTable);

struct ActionBinding(WriteState)
{
	Handler dlg;

	this(Handler handler) pure nothrow @nogc @safe
	{
		this.dlg = handler;
		return;
	}

	ref typeof(this) handle(ref InputState input_state, ref StateTable action_state)
	{
		this.dlg(input_state, action_state);
		return this;
	}
}
