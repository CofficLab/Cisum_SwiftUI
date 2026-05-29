import Foundation
import OSLog
import CryptoKit
import SwiftUI

/// A lightweight HTTP client that supports common HTTP methods with fluent interface.
/// Example usage:
/// ```swift
/// let client = HttpClient(url: URL(string: "https://api.example.com")!)
///     .withToken("your-token")
///     .withBody(["key": "value"])
/// let response = try await client.post()
/// ```
public class HttpClient {
    public static let emoji = "🛞"
    private var url: URL
    private var headers: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
    ]
    private var body: [String:Any] = [:]
    private var timeoutInterval: TimeInterval = 30
    private var task: URLSessionDataTask?
    private var cacheMaxAge: TimeInterval = 0
    private let cacheStore = FileCacheStore()
    
    public init(url: URL) {
        self.url = url
    }
    
    /// 初始化，支持设置缓存秒数（0 或以下为禁用缓存）
    /// - Parameters:
    ///   - url: 请求 URL
    ///   - cacheMaxAge: 缓存有效期（秒）
    public convenience init(url: URL, cacheMaxAge: TimeInterval) {
        self.init(url: url)
        self.cacheMaxAge = cacheMaxAge
    }
    
    /// Sets request timeout interval in seconds
    /// - Parameter timeout: The timeout interval in seconds
    /// - Returns: Self for method chaining
    public func withTimeout(_ timeout: TimeInterval) -> Self {
        self.timeoutInterval = timeout
        return self
    }
    
    /// 设置缓存有效期（秒）。0 或以下禁用缓存
    /// - Parameter seconds: 有效期（秒）
    /// - Returns: Self
    public func withCache(maxAge seconds: TimeInterval) -> Self {
        self.cacheMaxAge = seconds
        return self
    }
    
    /// Cancels any ongoing request
    public func cancel() {
        task?.cancel()
    }
    
    public func withHeaders(_ headers: [String:String]) -> Self {
        self.headers = headers
        return self
    }
    
    public func withHeader(_ key: String, _ value: String) -> Self {
        headers.updateValue(value, forKey: key)
        return self
    }

    public func withToken(_ token: String) -> Self {
        self.withHeader("Authorization", "Bearer \(token)")
    }
    
    public func withBody(_ body: [String:Any]) -> Self {
        self.body = body
        return self
    }

    public func get() async throws -> String {
        // 尝试读取缓存
        if cacheMaxAge > 0, let cached = try? cacheStore.read(url: url, headers: headers, maxAge: cacheMaxAge) {
            if let responseString = String(data: cached, encoding: .utf8) {
                return responseString
            }
        }
        var request = URLRequest(url: url)
        let session = URLSession.shared

        request.httpMethod = "GET"
        
        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }

        guard httpResponse.statusCode == 200 else {
            os_log(.error, "Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "Http URL -> \(self.url.absoluteString)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw HttpError.HttpNoData
        }
        // 写入缓存
        if cacheMaxAge > 0 {
            try? cacheStore.write(url: url, headers: headers, data: data)
        }

        return responseString
    }

    public func getDataAndResponse() async throws -> (Data, HTTPURLResponse) {
        // 尝试读取缓存
        if cacheMaxAge > 0, let cached = try? cacheStore.read(url: url, headers: headers, maxAge: cacheMaxAge) {
            let mock = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
            return (cached, mock)
        }
        var request = URLRequest(url: url)
        let session = URLSession.shared

        request.httpMethod = "GET"
        
        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }
        // 写入缓存（仅在 2xx 且内容长度完整时）
        if cacheMaxAge > 0 {
            let isStatusOK = httpResponse.statusCode.isHttpOkCode()
            let expectedLength = response.expectedContentLength
            let isUnknownLength = expectedLength < 0
            let isLengthOK = isUnknownLength || Int64(data.count) == expectedLength
            // 若是 JSON，则校验 JSON 合法性后再缓存，避免将截断数据写入缓存
            let acceptHeader = headers["Accept"]?.lowercased() ?? ""
            let shouldValidateJSON = acceptHeader.contains("application/json") || acceptHeader.contains("text/json")
            let isValidJSON = !shouldValidateJSON || (try? JSONSerialization.jsonObject(with: data)) != nil
            if isStatusOK && isLengthOK && isValidJSON {
                try? cacheStore.write(url: url, headers: headers, data: data)
            }
        }

        return (data, httpResponse)
    }

    public func delete() async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                os_log(.error, "Http Error -> \(httpResponse.statusCode)")
                os_log(.error, "Http Error -> DELETE \(self.url)")
                printHttpError(data, httpResponse: httpResponse)
                throw HttpError.HttpStatusError(httpResponse.statusCode)
            }
        } else {
            throw HttpError.HttpNoData
        }
    }

    @discardableResult
    public func post() async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }

        guard httpResponse.statusCode.isHttpOkCode() else {
            os_log(.error, "Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "Post -> \(self.url)")
            os_log(.error, "Headers -> \(self.headers)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw HttpError.HttpNoData
        }

        return responseString
    }

    @discardableResult
    public func patch() async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"

        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }

        guard httpResponse.statusCode.isHttpOkCode() else {
            os_log(.error, "Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "Patch -> \(self.url)")
            os_log(.error, "Headers -> \(self.headers)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw HttpError.HttpNoData
        }

        return responseString
    }

    @discardableResult
    public func put() async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }
        
        guard httpResponse.statusCode.isHttpOkCode() else {
            os_log(.error, "Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "Put -> \(self.url)")
            os_log(.error, "Headers -> \(self.headers)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw HttpError.HttpNoData
        }

        return responseString
    }

    func printHttpError(_ data: Data?, httpResponse: HTTPURLResponse) {
        if let data = data {
            let str = String(data: data, encoding: .utf8)
            os_log(.error, "\(str!)")
        } else {
            os_log("返回内容为空")
        }
    }

    private func executeRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var urlRequest = request
        urlRequest.timeoutInterval = timeoutInterval
        
        let session = URLSession.shared
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }
        
        if !httpResponse.statusCode.isHttpOkCode() {
            os_log(.error, "Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "URL -> \(self.url.absoluteString)")
            os_log(.error, "Headers -> \(self.headers)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }
        
        return (data, httpResponse)
    }

    // MARK: - Cache Directory Utilities
    /// 返回 HttpClient 使用的缓存目录 URL。若目录不存在会自动创建。
    public static func cacheDirectoryURL() -> URL {
        FileCacheStore.cacheDirectoryURL()
    }

    /// 打开缓存目录（macOS 在访达中打开；iOS 尝试通过系统打开该目录）
    public static func openCacheDirectory() {
        let dir = cacheDirectoryURL()
        dir.openFolder()
    }
}

// MARK: - 简单文件缓存实现
private final class FileCacheStore {
    private let directory: URL
    private let fm = FileManager.default
    
    init() {
        let dir = Self.cacheDirectoryURL()
        self.directory = dir
    }

    /// 计算并确保缓存目录存在
    static func cacheDirectoryURL() -> URL {
        let fm = FileManager.default
        let base = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("HttpClientCache", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    func read(url: URL, headers: [String:String], maxAge: TimeInterval) throws -> Data? {
        let path = fileURL(url: url, headers: headers)
        guard let attrs = try? fm.attributesOfItem(atPath: path.path),
              let modified = attrs[.modificationDate] as? Date else {
            return nil
        }
        let age = Date().timeIntervalSince(modified)
        guard age <= maxAge else {
            // 过期自动清理
            try? fm.removeItem(at: path)
            return nil
        }
        return try Data(contentsOf: path)
    }
    
    func write(url: URL, headers: [String:String], data: Data) throws {
        let path = fileURL(url: url, headers: headers)
        try data.write(to: path, options: .atomic)
    }
    
    private func fileURL(url: URL, headers: [String:String]) -> URL {
        let key = cacheKey(url: url, headers: headers)
        return directory.appendingPathComponent(key)
    }
    
    private func cacheKey(url: URL, headers: [String:String]) -> String {
        var input = url.absoluteString
        if !headers.isEmpty {
            let headerString = headers
                .sorted { $0.key < $1.key }
                .map { "\($0.key):\($0.value)" }
                .joined(separator: "|")
            input += "::" + headerString
        }
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

#if DEBUG
#Preview {
    HttpClientPreview()
}
#endif
