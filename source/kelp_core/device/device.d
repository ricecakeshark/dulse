module kelp_core.device.device;

import kelp_core.core;
import kelp_core.core.subsystem;
import kelp_core.device;

final class DeviceSubsystem : Subsystem
{
	Core core;
	Keyboard keyboard;
	Mouse mouse;
	Gamepad gamepad;

	this(Core core)
	{
		this.core = core;
		this.keyboard = new Keyboard();
		this.mouse = new Mouse();
		this.gamepad = new Gamepad();
		return;
	}

	void initialize()
	{
		return;
	}

	void finalize()
	{
		return;
	}

	void process()
	{
		this.keyboard.process();
		this.mouse.process();
		this.gamepad.process();
		return;
	}
}
