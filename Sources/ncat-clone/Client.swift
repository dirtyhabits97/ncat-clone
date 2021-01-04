import Foundation
import Network

@available(macOS 10.14, *)
class Client {

        // MARK: - Properties

        let connection: ClientConnection
        let host: NWEndpoint.Host
        let port: NWEndpoint.Port

        // MARK: - Lifecycle

        init(host: String, port: UInt16) {
                guard let p = NWEndpoint.Port(rawValue: port) else {
                        fatalError("Failed to create port.")
                }
                self.host = NWEndpoint.Host(host)
                self.port = p
                let nwConnection = NWConnection(host: self.host, port: self.port, using: .tcp)
                self.connection = ClientConnection(nwConnection: nwConnection)
        }

        func start() {
                print("Client started \(host) \(port)")
                connection.didStopCallback = didStopCallback(error:)
                connection.start()
        }

        func stop() {
                connection.stop()
        }

        // MARK: - Methods

        func send(data: Data) {
                connection.send(data: data)
        }

        func didStopCallback(error: Error?) {
                if error == nil {
                        exit(EXIT_SUCCESS)
                } else {
                        exit(EXIT_FAILURE)
                }
        }

}
