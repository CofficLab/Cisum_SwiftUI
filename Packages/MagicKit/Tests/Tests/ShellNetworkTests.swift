import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellNetworkCommandsPreserveLiteralInputs() {
    let host = #"example.com $HOME `uname` "quote" and 'single quote'"#
    let url = #"https://example.com/path?q=$HOME&name=`uname`&quote="double"&single='one'"#
    let output = #"/tmp/download $HOME `uname` "quote" and 'single quote'.bin"#
    let quotedHost = ShellNetwork.shellQuoted(host)
    let quotedURL = ShellNetwork.shellQuoted(url)
    let quotedOutput = ShellNetwork.shellQuoted(output)

    #expect(ShellNetwork.pingCommand(host) == "ping -c 1 -W 3000 \(quotedHost)")
    #expect(ShellNetwork.pingDetailedCommand(host, count: 3) == "ping -c 3 \(quotedHost)")
    #expect(ShellNetwork.pingDetailedCommand(host, count: -2) == "ping -c 0 \(quotedHost)")
    #expect(ShellNetwork.downloadCommand(url, to: output) == "curl -L \(quotedURL) -o \(quotedOutput)")
    #expect(ShellNetwork.curlCommand(url) == "curl -s \(quotedURL)")
    #expect(ShellNetwork.headersCommand(url) == "curl -I \(quotedURL)")
    #expect(ShellNetwork.testPortCommand(host, port: 443) == "nc -z -w3 \(quotedHost) 443")
    #expect(ShellNetwork.nslookupCommand(host) == "nslookup \(quotedHost)")
    #expect(ShellNetwork.tracerouteCommand(host) == "traceroute \(quotedHost)")
    #expect(ShellNetwork.httpStatusCommand(url) == "curl -s -o /dev/null -w '%{http_code}' \(quotedURL)")
}
#endif
