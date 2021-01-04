import Foundation

// source: https://rderik.com/guides/

if #available(macOS 10.14, *) {
var isServer = false

func initServer(port: UInt16) {
        let server = Server(port: port)
        try! server.start()
}

func initClient(server: String, port: UInt16) {
        let client = Client(host: server, port: port)
        client.start()

        while true {
                var command = readLine(strippingNewline: true)
                switch command {
                // send a Carriage Return Line Feed to the server
                case "CRLF":
                        command = "\r\n"
                // send a Line Feed to the server
                case "RETURN":
                        command = "\n"
                // close connection
                case "exit":
                        client.stop()
                default:
                        break
                }
                let data = command?.data(using: .utf8) ?? Data()
                client.connection.send(data: data) 
        }
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
                initClient(server: server, port: port)
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
