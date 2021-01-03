import Foundation

if #available(macOS 10.14, *) {
var isServer = false

func initServer(port: UInt16) {
        let server = Server(port: port)
        try! server.start()
}

let firstArgument = CommandLine.arguments[1]

switch firstArgument {
case "-l":
        isServer = true
default:
        break
}

if isServer {
        if let port = UInt16(CommandLine.arguments[2]) {
                initServer(port: port)
        } else {
                print("Error: invalid port")
        }
} else {
        let server = CommandLine.arguments[1]
        if let port = UInt16(CommandLine.arguments[2]) {
                print("Starting as client, connecting to server: \(server) port: \(port)")
        } else {
                print("Error: invalid port")
        }
}

RunLoop.current.run()

} else {
        let stderr = FileHandle.standardError
        let message = "Requires macOS 10.14 or newer"
        stderr.write(message.data(using: .utf8)!)
        exit(EXIT_FAILURE)
}
