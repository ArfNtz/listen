# Listener

**A tiny HTTP server with support for SSL and POST requests only**

<a href="https://swift.org" target="_blank"><img src="https://img.shields.io/badge/Language-Swift%205-orange.svg" alt="Language Swift 5"></a>
<img src="https://img.shields.io/badge/os-macOS-green.svg?style=flat" alt="macOS">
<img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux">
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**Motivation**

- easy code integration into other projects
- less dependency when nginx/apache is not needed

**Features**
- non blocking multithread I/O
- linux and macOS compatible
- open source development environment and dependencies
- library and command line executable
- kiss (keep it stupid simple) : minimal code

**Dependencies**
- Foundation, SwiftNIO, SwiftNIOSSL

**Development tools**
- VSCode 
- <a href="https://lldb.llvm.org">LLDB</a>
- Sourcekit-LSP

**Testing platforms**
- macOS 10.15
- Linux Ubuntu 18.04.

----

## Build

```bash
$ swift build -c release
```

## Use

Launch the server :
```bash
$ ./.build/release/listener
Use : $ listener <host> <port> <certFile> <keyFile> <numberOfThreads> <maxBodySize>
Example : $ listener localhost 8888 cert.pem key.pem 4 4096
host: localhost, port: 8888, cert: cert.pem, key: key.pem, nbThread: 4, maxBodySize: 65535
Server started and listening on [IPv6]::1/::1:8888 with 4 threads and maxBodySize 65535
```

Test (post some data to the https server launched ) using `curl` :
```bash
$ echo "content to be sent" > myTextFile.txt
$ curl -k --data-binary "@myTextFile.txt" --output - https://localhost:8888
content to be sent
```

In a swift program : 
```swift
try HTTPServer().serve(host:host, port:port, cert:cert, key:key, nbThread:nbThread, maxBodySize:maxBodySize, action: Echo())
```

## Code

VSCode files are located in the `.vscode` directory.
They provide launch and task configurations for debug and test.
These configurations can be used with "Native Debug" or "CodeLLDB" extensions.


## Test

```bash
$ swift test
[8/8] Linking listenPackageTests.xctest
Test Suite 'All tests' started at 2020-02-11 11:57:46.592
Test Suite 'debug.xctest' started at 2020-02-11 11:57:46.596
Test Suite 'listenTests' started at 2020-02-11 11:57:46.596
Test Case 'listenTests.testExample' started at 2020-02-11 11:57:46.596
host: localhost, port: 8888, cert: cert.pem, key: key.pem, nbThread: 4, maxBodySize: 65535
Server started and listening on [IPv4]127.0.0.1/127.0.0.1:8888 with 4 threads and maxBodySize 65535
```
