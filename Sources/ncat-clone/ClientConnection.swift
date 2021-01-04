import Foundation
import Network

@available(macOS 10.14, *)
class ClientConnection {

        // MARK: - Properties

        let MTU = 65536

        let nwConnection: NWConnection
        let queue = DispatchQueue(label: "com.gerh.client")

        var didStopCallback: ((Error?) -> Void)?

        // MARK: - Lifecycle

        init(nwConnection: NWConnection) {
                self.nwConnection = nwConnection
        }

        func start() {
                print("Connection will start")
                nwConnection.stateUpdateHandler = stateDidChange(to:)
                setupReceive()
                nwConnection.start(queue: queue)
        }

        // MARK: - Methods

        private func setupReceive() {
                nwConnection.receive(minimumIncompleteLength: 1, maximumLength: MTU) { [weak self] (data, _, isComplete, error) in
                        guard let self = self else { return }

                        if let data = data, !data.isEmpty {
                                let message = String(data: data, encoding: .utf8)
                                print("connection did receive, data: \(data as NSData), string: \(message ?? "-")")
                        }
                        if isComplete {
                                self.connectionDidEnd()
                        } else if let error = error {
                                self.connectionDidFail(error: error)
                        } else {
                                self.setupReceive()
                        }
                }
        }

        private func stateDidChange(to state: NWConnection.State) {
                switch state {
                case .waiting(let error):
                        connectionDidFail(error: error)
                case .ready:
                        print("Client connection ready")
                case .failed(let error):
                        connectionDidFail(error: error)
                default:
                        break
                }
        }

        func send(data: Data) {
                self.nwConnection.send(content: data, completion: .contentProcessed({ error in
                                                                                          if let error = error {
                                                                                                  self.connectionDidFail(error: error)
                                                                                                  return
                                                                                          }
                                                                                          print("connection did send, data: \(data as NSData)")
                                                                                  }))
        }

        func stop() {
                print("connection will stop")
                stop(error: nil)
        }

        private func connectionDidFail(error: Error) {
                print("connection did fail, error: \(error)")
                stop(error: error)
        }

        private func connectionDidEnd() {
                print("connection did end")
                stop(error: nil)
        }

        private func stop(error: Error?) {
                nwConnection.stateUpdateHandler = nil
                nwConnection.cancel()
                if let didStopCallback = didStopCallback {
                        self.didStopCallback = nil
                        didStopCallback(error)
                }
        }


}

