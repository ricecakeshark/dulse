module kelp_core.input.action.action_binding;

import kelp_core.input;

struct ActionBinding
{
	Action delegate(ref Keyboard) dlg;
}
