from autobahn.asyncio.websocket import WebSocketServerProtocol, \
    WebSocketServerFactory
import time

f=open('data'+str(time.time()), 'a')
class MyServerProtocol(WebSocketServerProtocol):

    
    def onConnect(self, request):
        print("Client connecting: {0}".format(request.peer))

    def onOpen(self):
        print("WebSocket connection open.")

    def onMessage(self, payload, isBinary):
        line=payload.decode('utf8')
        print("Received: {0}".format(line))
        f.write(line)


    def onClose(self, wasClean, code, reason):
        print("WebSocket connection closed: {0}".format(reason))
        f.close()


if __name__ == '__main__':

    try:
        import asyncio
    except ImportError:
        # Trollius >= 0.3 was renamed
        import trollius as asyncio

    factory = WebSocketServerFactory(u"ws://127.0.0.1:9000", debug=False)
    factory.protocol = MyServerProtocol

    loop = asyncio.get_event_loop()
    coro = loop.create_server(factory, '0.0.0.0', 9000)
    server = loop.run_until_complete(coro)
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.close()
        loop.close()