module kelp_core.core.message_bus;

import kelp_core.core.structure;


class MessageBus
{
	InterfacedPool!(Message) pool;

	typeof(this) send(Message message)
	{
		this.pool.append(message);
		return this;
	}

	Message[] recieve(Type)()
	{
		return this.pool.query!(Type)();
	}
}

interface Message
{

}

class QuitMessage : Message
{

}