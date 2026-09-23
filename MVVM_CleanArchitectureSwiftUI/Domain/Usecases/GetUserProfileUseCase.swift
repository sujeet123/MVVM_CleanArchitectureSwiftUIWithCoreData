import Foundation

/// One use case = one business action. Keeping this as its own type (rather than
/// calling the repository directly from the ViewModel) means business rules
/// (validation, combining multiple repositories, caching policy, etc.) have
/// a home that isn't the ViewModel and isn't the repository.
protocol GetUserProfileUseCaseProtocol {
    func execute(userId: Int) async throws -> UserProfile
}

final class GetUserProfileUseCase: GetUserProfileUseCaseProtocol {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: Int) async throws -> UserProfile {
        guard userId > 0 else { throw AppError.notFound }
        return try await repository.fetchUserProfile(id: userId)
    }
}
