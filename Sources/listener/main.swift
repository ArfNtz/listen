import Foundation
import listen

var host = "localhost"
var port = 8888
var cert = "cert.pem"
var key = "key.pem"
var nbThread = 4 // System.coreCount
var maxBodySize = 65535

let arg1 = CommandLine.arguments.dropFirst(1).first
if [nil,"","?","-h","--help"].contains(arg1?.trimmingCharacters(in: .whitespaces)) {
    print ("Use : $ listener <host> <port> <certFile> <keyFile> <numberOfThreads> <maxBodySize>")
    print ("Example : $ listener localhost 8888 cert.pem key.pem 4 4096")
} else {
    host = arg1!
}

if let arg2 = CommandLine.arguments.dropFirst(2).first.flatMap(Int.init) {
    port = arg2
}

if let arg3 = CommandLine.arguments.dropFirst(3).first {
    cert = arg3
}

if let arg4 = CommandLine.arguments.dropFirst(4).first {
    key = arg4
}

if let arg5 = CommandLine.arguments.dropFirst(5).first.flatMap(Int.init) {
    nbThread = arg5
}

if let arg6 = CommandLine.arguments.dropFirst(6).first.flatMap(Int.init) {
    maxBodySize = arg6
}

print("Starting listener host: \(host), port: \(port), cert: \(cert), key: \(key), nbThread: \(nbThread), maxBodySize: \(maxBodySize)")

try HTTPServer().serve(host:host, port:port, cert:cert, key:key, nbThread:nbThread, maxBodySize:maxBodySize, action: Echo())

