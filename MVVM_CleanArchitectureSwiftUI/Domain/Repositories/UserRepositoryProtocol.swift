import Foundation

/// Defined in the Domain layer, implemented in the Data layer.
/// The Domain layer never imports Data — Data depends inward on Domain,
/// satisfying the Dependency Inversion Principle at the heart of Clean Architecture.
protocol UserRepositoryProtocol {
    func fetchUserProfile(id: Int) async throws -> UserProfile
}
