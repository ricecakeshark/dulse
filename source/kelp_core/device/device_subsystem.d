module kelp_core.device.device_subsystem;

import kelp_core.core;
import kelp_core.core.subsystem;
import kelp_core.device;

final class DeviceSubsystem : Subsystem
{
	Keyboard keyboard;
	Mouse mouse;
	Gamepad gamepad;

	this(Core core)
	{
		super(core);
		this.keyboard = new Keyboard();
		this.mouse = new Mouse();
		this.gamepad = new Gamepad();
		return;
	}

	typeof(this) initialize()
	{
		return this;
	}

	typeof(this) finalize()
	{
		return this;
	}

	typeof(this) process()
	{
		this.keyboard.process();
		this.mouse.process();
		this.gamepad.process();
		return this;
	}
}
