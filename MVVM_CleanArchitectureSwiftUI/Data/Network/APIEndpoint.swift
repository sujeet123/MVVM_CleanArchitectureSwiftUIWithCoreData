import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// Describes a single network request. Keeping this separate from APIClient
/// means adding a new endpoint never touches networking/transport code.
protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
}

extension APIEndpoint {
    var baseURL: String { "https://jsonplaceholder.typicode.com" }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var queryItems: [URLQueryItem]? { nil }

    func makeURLRequest() throws -> URLRequest {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw AppError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}

/// Concrete endpoints for the User feature.
enum UserEndpoint: APIEndpoint {
    case getUserProfile(id: Int)

    var path: String {
        switch self {
        case .getUserProfile(let id):
            return "/users/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUserProfile:
            return .get
        }
    }
}
