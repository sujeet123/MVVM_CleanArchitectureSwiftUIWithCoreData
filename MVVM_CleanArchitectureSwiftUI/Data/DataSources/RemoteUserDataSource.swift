import Foundation

/// Data sources own the "where does the data physically come from" question.
/// Today it's remote-only; adding a `LocalUserDataSource` (cache/DB) later
/// wouldn't require touching the repository's public contract.
protocol RemoteUserDataSourceProtocol {
    func getUserProfile(id: Int) async throws -> UserProfileDTO
}

final class RemoteUserDataSource: RemoteUserDataSourceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getUserProfile(id: Int) async throws -> UserProfileDTO {
        try await apiClient.request(UserEndpoint.getUserProfile(id: id))
    }
}
