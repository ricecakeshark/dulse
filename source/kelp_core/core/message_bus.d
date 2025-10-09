module kelp_core.core.message_bus;

import kelp_core.core.structure;


class MessageBus : InterfacedPool!(Message)
{
	typeof(this) send(Message message)
	{
		this.register(message);
		return this;
	}

	Message[] recieve(Type)()
	{
		return this.query!(Type)();
	}
}

interface Message
{

}

class QuitRequest : Message
{

}