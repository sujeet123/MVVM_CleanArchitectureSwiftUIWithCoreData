import Foundation

/// Composition root: the one place in the app that knows about every layer
/// at once and wires them together. Nothing else should reach across layers
/// directly (e.g. a View should never construct an APIClient itself).

//@MainActor
//final class DependencyContainer {
//    static let shared = DependencyContainer()
//
//    private init() {}
//
//    // MARK: - Data layer
//    private lazy var apiClient: APIClientProtocol = APIClient()
//
//    private lazy var remoteUserDataSource: RemoteUserDataSourceProtocol =
//        RemoteUserDataSource(apiClient: apiClient)
//
//    private lazy var userRepository: UserRepositoryProtocol =
//        UserRepository(remoteDataSource: remoteUserDataSource)
//
//    // MARK: - Domain layer
//    private func makeGetUserProfileUseCase() -> GetUserProfileUseCaseProtocol {
//        GetUserProfileUseCase(repository: userRepository)
//    }
//
//    // MARK: - Presentation layer
//    func makeUserProfileViewModel() -> UserProfileViewModel {
//        UserProfileViewModel(getUserProfileUseCase: makeGetUserProfileUseCase())
//    }
//}

import Foundation

/// Composition root: the one place in the app that knows about every layer
/// at once and wires them together. Nothing else should reach across layers
/// directly (e.g. a View should never construct an APIClient itself).
final class DependencyContainer {
    static let shared = DependencyContainer()

    private init() {}

    // MARK: - Data layer
    private lazy var apiClient: APIClientProtocol = APIClient()

    private lazy var remoteUserDataSource: RemoteUserDataSourceProtocol =
        RemoteUserDataSource(apiClient: apiClient)

    private lazy var localUserDataSource: LocalUserDataSourceProtocol =
        CoreDataUserDataSource()

    private lazy var userRepository: UserRepositoryProtocol =
        UserRepository(
            remoteDataSource: remoteUserDataSource,
            localDataSource: localUserDataSource
        )

    // MARK: - Domain layer
    private func makeGetUserProfileUseCase() -> GetUserProfileUseCaseProtocol {
        GetUserProfileUseCase(repository: userRepository)
    }

    // MARK: - Presentation layer
    @MainActor
    func makeUserProfileViewModel() -> UserProfileViewModel {
        UserProfileViewModel(getUserProfileUseCase: makeGetUserProfileUseCase())
    }
}
