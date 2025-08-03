//
//  NetworkManager.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import Foundation
import Network

// MARK: - Modern Network Manager

final class NetworkManager: NetworkManagerProtocol, ObservableObject {
    private let session: URLSession
    private let configuration: AppConfigurationProtocol
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?
    
    init(configuration: AppConfigurationProtocol) {
        self.configuration = configuration
        
        // Configure URLSession with security and performance settings
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.requestTimeout
        sessionConfig.timeoutIntervalForResource = configuration.requestTimeout * 2
        sessionConfig.waitsForConnectivity = true
        sessionConfig.allowsCellularAccess = true
        sessionConfig.allowsExpensiveNetworkAccess = true
        sessionConfig.allowsConstrainedNetworkAccess = false
        
        // Add security headers
        sessionConfig.httpAdditionalHeaders = [
            "User-Agent": "HeyBoomerang-iOS/1.0",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        self.session = URLSession(configuration: sessionConfig)
        
        startNetworkMonitoring()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    // MARK: - Network Requests
    
    func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async -> Result<T, AppError> {
        // Pre-flight checks
        guard isConnected else {
            Logger.shared.error("Network request failed - no connection", category: .network)
            return .failure(.network(.noConnection))
        }
        
        // Validate URL
        guard let url = request.url else {
            Logger.shared.error("Invalid URL in request", category: .network)
            return .failure(.network(.invalidURL("URL is nil")))
        }
        
        Logger.shared.debug("Starting request to: \(url.absoluteString)", category: .network)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.shared.error("Invalid response type", category: .network)
                return .failure(.api(.invalidResponse))
            }
            
            Logger.shared.debug("Received response: \(httpResponse.statusCode) from \(url.absoluteString)", category: .network)
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                return await decodeResponse(data: data, responseType: responseType)
            case 401:
                Logger.shared.warning("Unauthorized request", category: .network)
                return .failure(.api(.unauthorized))
            case 403:
                Logger.shared.warning("Forbidden request", category: .network)
                return .failure(.api(.forbidden))
            case 404:
                Logger.shared.warning("Resource not found", category: .network)
                return .failure(.api(.notFound))
            case 429:
                Logger.shared.warning("Rate limited", category: .network)
                return .failure(.network(.rateLimited))
            case 500...599:
                Logger.shared.error("Server error: \(httpResponse.statusCode)", category: .network)
                return .failure(.network(.serverError(httpResponse.statusCode)))
            default:
                Logger.shared.error("Unexpected status code: \(httpResponse.statusCode)", category: .network)
                return .failure(.network(.serverError(httpResponse.statusCode)))
            }
            
        } catch let error as URLError {
            return await handleURLError(error)
        } catch {
            Logger.shared.error("Unexpected network error", error: error, category: .network)
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    func performRequest(_ request: URLRequest) async -> Result<Void, AppError> {
        let result: Result<EmptyResponse, AppError> = await performRequest(request, responseType: EmptyResponse.self)
        return result.map { _ in () }
    }
    
    // MARK: - Private Methods
    
    private func decodeResponse<T: Codable>(data: Data, responseType: T.Type) async -> Result<T, AppError> {
        // Handle empty responses
        if data.isEmpty && responseType == EmptyResponse.self {
            return .success(EmptyResponse() as! T) // Safe cast since we checked the type
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let decodedResponse = try decoder.decode(responseType, from: data)
            Logger.shared.debug("Successfully decoded response", category: .network)
            return .success(decodedResponse)
            
        } catch {
            Logger.shared.error("Failed to decode response", error: error, category: .network)
            
            // Log response data for debugging in development
            if configuration.isDebugMode {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode data as string"
                Logger.shared.debug("Response data: \(responseString)", category: .network)
            }
            
            return .failure(.api(.decodingFailed(error.localizedDescription)))
        }
    }
    
    private func handleURLError<T>(_ error: URLError) async -> Result<T, AppError> {
        Logger.shared.error("URLError occurred", error: error, category: .network)
        
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .failure(.network(.noConnection))
        case .timedOut:
            return .failure(.network(.timeout))
        case .badURL:
            return .failure(.network(.invalidURL(error.localizedDescription)))
        default:
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    // MARK: - Network Monitoring
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
                
                Logger.shared.info("Network status changed - Connected: \(path.status == .satisfied)", category: .network)
            }
        }
        
        networkMonitor.start(queue: monitorQueue)
    }
}

// MARK: - Request Builder

extension URLRequest {
    static func apiRequest(
        url: URL,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        additionalHeaders: [String: String] = [:],
        authToken: String? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Add authentication header if token is provided
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add additional headers
        for (key, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Helper Types

private struct EmptyResponse: Codable {}

// MARK: - URL Extensions

extension URL {
    static func apiURL(path: String, configuration: AppConfigurationProtocol) -> URL? {
        return URL(string: "\(configuration.apiBaseURL)/\(path)")
    }
}