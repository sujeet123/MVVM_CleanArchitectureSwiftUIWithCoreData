import Foundation

/// Abstraction over URLSession so it can be swapped/mocked in tests.
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = APIClient.makeDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let urlRequest = try endpoint.makeURLRequest()

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw AppError.network(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 404:
            throw AppError.notFound
        default:
            throw AppError.network("Server returned status \(httpResponse.statusCode)")
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppError.decoding
        }
    }
}
