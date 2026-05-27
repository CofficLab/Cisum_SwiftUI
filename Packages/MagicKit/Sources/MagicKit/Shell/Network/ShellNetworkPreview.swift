#if DEBUG && os(macOS)
    import SwiftUI

    struct ShellNetworkPreviewView: View {
        var body: some View {
            VStack(spacing: 20) {
                Text("🌐 ShellNetwork 功能演示")
                    .font(.title)
                    .bold()

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        VDemoSection(title: "连接测试", icon: "📡") {
                            VPingTestRow("google.com")
                            VPingTestRow("baidu.com")
                            VPingTestRow("github.com")

                            VDemoButtonWithLog("详细Ping测试", action: {
                                do {
                                    let result = try ShellNetwork.pingDetailed("google.com", count: 3)
                                    return "详细Ping结果:\n\(result)"
                                } catch {
                                    return "详细Ping测试失败: \(error.localizedDescription)"
                                }
                            })
                        }

                        VDemoSection(title: "IP信息", icon: "🏠") {
                            VIPInfoRow("本机IP", ShellNetwork.getLocalIPs().first ?? "未知")

                            VDemoButtonWithLog("获取公网IP", action: {
                                let publicIP = ShellNetwork.getPublicIP()
                                return "公网IP: \(publicIP)"
                            })

                            VDemoButtonWithLog("所有本机IP", action: {
                                let ips = ShellNetwork.getLocalIPs()
                                return "所有本机IP:\n\(ips.joined(separator: "\n"))"
                            })
                        }

                        VDemoSection(title: "端口测试", icon: "🚪") {
                            VPortTestRow("google.com", 80)
                            VPortTestRow("google.com", 443)
                            VPortTestRow("github.com", 22)
                            VPortTestRow("localhost", 3000)
                        }

                        VDemoSection(title: "HTTP测试", icon: "🌍") {
                            VHTTPStatusRow("https://www.google.com")
                            VHTTPStatusRow("https://www.github.com")
                            VHTTPStatusRow("https://httpstat.us/404")

                            VDemoButtonWithLog("获取HTTP头", action: {
                                do {
                                    let headers = try ShellNetwork.getHeaders("https://www.google.com")
                                    return "HTTP头:\n\(headers)"
                                } catch {
                                    return "获取HTTP头失败: \(error.localizedDescription)"
                                }
                            })
                        }

                        VDemoSection(title: "网络信息", icon: "ℹ️") {
                            VDemoButtonWithLog("网络接口状态", action: {
                                let status = ShellNetwork.getNetworkStatus()
                                return "网络接口状态:\n\(status)"
                            })

                            VDemoButtonWithLog("路由表", action: {
                                let routes = ShellNetwork.getRoutes()
                                let lines = routes.components(separatedBy: .newlines)
                                return "路由表:\n\(routes)"
                            })

                            VDemoButtonWithLog("WiFi信息", action: {
                                let wifi = ShellNetwork.getWiFiInfo()
                                return "WiFi信息:\n\(wifi)"
                            })
                        }

                        VDemoSection(title: "DNS和路由", icon: "🔍") {
                            VDemoButtonWithLog("DNS查询", action: {
                                do {
                                    let result = try ShellNetwork.nslookup("google.com")
                                    return "DNS查询结果:\n\(result)"
                                } catch {
                                    return "DNS查询失败: \(error.localizedDescription)"
                                }
                            })

                            VDemoButtonWithLog("路由追踪", action: {
                                do {
                                    let result = try ShellNetwork.traceroute("8.8.8.8")
                                    return "路由追踪结果:\n\(result)"
                                } catch {
                                    return "路由追踪失败: \(error.localizedDescription)"
                                }
                            })
                        }

                        VDemoSection(title: "速度测试", icon: "⚡") {
                            VDemoButtonWithLog("网络速度测试", action: {
                                let speed = ShellNetwork.speedTest()
                                return "网络速度测试结果: \(speed)"
                            })
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
    }

    #if DEBUG
    #Preview("ShellNetwork Demo") {
        ShellNetworkPreviewView()
    }
    #endif

#endif
