import Foundation
import Network

@available(macOS 10.14, *)
class Server {

        // MARK: - Properties

        let port: NWEndpoint.Port
        let listener: NWListener

        private var connectionsById: [Int: ServerConnection] = [:]

        // MARK: - Lifecycle

        init(port: UInt16) {
             guard let p = NWEndpoint.Port(rawValue: port) else {
                     fatalError("Failed to create port")
             }
             self.port = p
             do {
                     listener = try NWListener(using: .tcp, on: self.port)
             } catch {
                     fatalError("Failed to start listener. Error: \(error.localizedDescription)")
             }
        }

        func start() throws {
                print("Server starting...")
                listener.stateUpdateHandler = self.stateDidChange(to:)
                listener.newConnectionHandler = self.didAccept(nwConnection:)
                listener.start(queue: .main)
        }

	func stop() {
		self.listener.stateUpdateHandler = nil
		self.listener.newConnectionHandler = nil
		self.listener.cancel()
		
		for connection in self.connectionsById.values {
			connection.didStopCallback = nil
			connection.stop()
		}
		self.connectionsById.removeAll()
	}

        // MARK: - Methods

        func stateDidChange(to newState: NWListener.State) {
                // TODO: add support for `cancelled`, `waiting`, and other states.
                switch newState {
                case .ready:
                        print("Server ready.")
                case .failed(let error):
                        print("Server failure, error: \(error.localizedDescription)")
                        exit(EXIT_FAILURE)
                default:
                        break
                }
        }

        private func didAccept(nwConnection: NWConnection) {
                let connection = ServerConnection(nwConnection: nwConnection)
                self.connectionsById[connection.id] = connection

                connection.didStopCallback = { [weak self] _ in
                        self?.connectionDidStop(connection)
                }
                connection.start()
                let msg = "Welcome you are connection: \(connection.id)"
                connection.send(data: msg.data(using: .utf8)!)
                print("Server did open connection \(connection.id)")
        }

	func connectionDidStop(_ connection: ServerConnection) {
		self.connectionsById.removeValue(forKey: connection.id)
		print("Server did close connection \(connection.id)")
	}

}
