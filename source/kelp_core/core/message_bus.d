module kelp_core.core.message_bus;

import kelp_core.core.container;

class MessageBus
{
	InterfacedPool!(IMessage) pool;

	typeof(this) send(IMessage message)
	{
		this.pool.append(message);
		return this;
	}

	Type[] recieve(Type)()
	{
		return this.pool.query_all!(Type)();
	}
}

interface IMessage
{

}

class Message(Type) : IMessage
{

}

class QuitMessage : Message!(QuitMessage)
{

}
