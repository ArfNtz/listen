import XCTest
@testable import listen

final class listenTests: XCTestCase {

    func testExample() throws {
        var host:String, port:Int, cert:String, key:String, nbThread:Int, maxBodySize:Int
        host = "localhost"
        port = 8888
        cert = "cert.pem"
        key = "key.pem"
        nbThread = 4
        maxBodySize = 65535
        print("host: \(host), port: \(port), cert: \(cert), key: \(key), nbThread: \(nbThread), maxBodySize: \(maxBodySize)")
        try HTTPServer().serve(host:host, port:port, cert:cert, key:key, nbThread:nbThread, maxBodySize:maxBodySize, action: Echo())
        XCTAssert(true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
