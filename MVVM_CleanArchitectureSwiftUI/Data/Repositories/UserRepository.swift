//import Foundation
//
///// Implements the Domain-defined `UserRepositoryProtocol`. This is the only
///// place that knows the data comes from a remote source (vs local cache, etc.).
//final class UserRepository: UserRepositoryProtocol {
//    private let remoteDataSource: RemoteUserDataSourceProtocol
//
//    init(remoteDataSource: RemoteUserDataSourceProtocol) {
//        self.remoteDataSource = remoteDataSource
//    }
//
//    func fetchUserProfile(id: Int) async throws -> UserProfile {
//        let dto = try await remoteDataSource.getUserProfile(id: id)
//        return dto.toDomain()
//    }
//}

import Foundation

/// Implements the Domain-defined `UserRepositoryProtocol`. This is the only
/// place that knows data can come from either the network or a local cache —
/// the use case, ViewModel, and View above it have no idea this fallback exists.
///
/// Strategy ("network-first, cache-as-fallback"):
/// 1. Try the network.
/// 2. On success, write the result into Core Data (so it's available offline
///    next time), then return it.
/// 3. On failure (no internet, timeout, server error, etc.), try Core Data.
///    If we have a previously cached profile, return that instead of failing.
///    If we don't, rethrow the original network error so the UI can show it.
final class UserRepository: UserRepositoryProtocol {
    private let remoteDataSource: RemoteUserDataSourceProtocol
    private let localDataSource: LocalUserDataSourceProtocol

    init(
        remoteDataSource: RemoteUserDataSourceProtocol,
        localDataSource: LocalUserDataSourceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchUserProfile(id: Int) async throws -> UserProfile {
        do {
            let dto = try await remoteDataSource.getUserProfile(id: id)
            let profile = dto.toDomain()

            // Best-effort cache write. If saving fails we still return the
            // freshly fetched profile to the caller — caching is a bonus,
            // not something that should ever block showing live data.
            try? await localDataSource.saveUserProfile(profile)

            return profile
        } catch {
            if let cached = try? await localDataSource.getUserProfile(id: id) {
                return cached
            }
            // No cache available either — surface the original network error.
            throw error
        }
    }
}
