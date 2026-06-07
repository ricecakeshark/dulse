module kelp_core.input.input_binder;

import kelp_core.input;

struct InputBinder
{
	InputAction delegate(Event) dlg;

}
