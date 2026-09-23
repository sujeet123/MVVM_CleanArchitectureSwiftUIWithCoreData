import Foundation

/// Domain-level error. The UI layer maps this to user-facing copy;
/// the data layer maps networking/decoding failures into this type,
/// so upper layers never see URLError / DecodingError directly.
enum AppError: Error, Equatable, LocalizedError {
    case network(String)
    case decoding
    case invalidResponse
    case notFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .network(let message):
            return "Network error: \(message)"
        case .decoding:
            return "We couldn't read the server's response."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .notFound:
            return "User profile not found."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
