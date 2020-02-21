//===----------------------------------------------------------------------===//
// Toy HTTPs listener
// For linux & macOS
// Based on Apple's SwiftNIO and SwiftNIO SSL libraries
//===----------------------------------------------------------------------===//

import Foundation
import NIO
import NIOSSL
import NIOHTTP1

// An action takes a String and returns a String
public protocol AAction {
    init()
    func process(message m:String) -> String 
}

// Echo is the default action for the server
public final class Echo: AAction {
    public init() {}
    public func process(message m:String) -> String {
        return m
    }
}

public final class HTTPServer {

    public init() {}

    public func serve(host:String = "localhost", port:Int = 8888, cert:String = "cert.pem", key:String = "key.pem", nbThread:Int = 1, maxBodySize:Int = 4096, action:AAction = Echo()) throws {

        let group = MultiThreadedEventLoopGroup(numberOfThreads: nbThread)
        defer { try! group.syncShutdownGracefully() }

        // openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
        let certificateChain = try NIOSSLCertificate.fromPEMFile(cert)
        let sslContext = try! NIOSSLContext(configuration: TLSConfiguration.forServer(certificateChain: certificateChain.map { .certificate($0) }, privateKey: .file(key)))

        let socketBootstrap = ServerBootstrap(group: group)
            .childChannelInitializer { channel in
                return channel.pipeline.addHandler(try! NIOSSLServerHandler(context: sslContext)).flatMap {
                    channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).flatMap {
                        channel.pipeline.addHandler(
                            HTTPHandler(maxBodySize: maxBodySize, action: action)
                        )
                    }
                }
            }

        let channel = try { () -> Channel in
            return try socketBootstrap.bind(host: host, port: port).wait()
        }()

        guard channel.localAddress != nil else {
            fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
        }
        print("Server started and listening on \(channel.localAddress!) with \(nbThread) threads and maxBodySize \(maxBodySize)" )

        // This will never unblock as we don't close the ServerChannel
        try channel.closeFuture.wait()
        print("Server closed")
    }
}

private final class HTTPHandler: ChannelInboundHandler {

    public typealias InboundIn = HTTPServerRequestPart
    public typealias OutboundOut = HTTPServerResponsePart
    
    var head_uri:String = ""
    var body:ByteBuffer!
    var end_description:String = ""
    var maxBodySize:Int
    var action:AAction

    public init(maxBodySize: Int, action: AAction) {
        self.maxBodySize = maxBodySize
        self.action = action
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let part = self.unwrapInboundIn(data)

        switch part {

        case .head(let head):
            self.head_uri = head.uri
            return

        case .body(var body):
            self.body.writeBuffer(&body)
            return

        case .end(let end):
            self.end_description = end?.description ?? ""

            // read the request body
            var m = "request body size overhead"
            if self.body.readableBytes < self.maxBodySize {
                m = self.body.readString(length: self.body.readableBytes) ?? ""
            }

            // call the action to set the response
            let response = self.action.process(message: m)

            // set the headers
            var headers = HTTPHeaders()
            headers.add(name: "Content-Type", value: "application/json")
            headers.add(name: "Content-Length", value: "\(response.count)")
            let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: headers)
            context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)

            // set the response data
            var buffer = context.channel.allocator.buffer(capacity: response.count)
            buffer.writeString(response)
            let body = HTTPServerResponsePart.body(.byteBuffer(buffer))
            context.writeAndFlush(self.wrapOutboundOut(body), promise: nil)
            context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)

        }
    }
    
    func handlerAdded(context: ChannelHandlerContext) {
        self.body = context.channel.allocator.buffer(capacity: 0)
    }

}
