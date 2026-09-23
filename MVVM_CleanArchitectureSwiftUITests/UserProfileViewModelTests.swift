//
//  UserProfileViewModelTests2.swift
//  MVVM_CleanArchitectureSwiftUITests
//
//  Created by Sujeet kumar on 14/09/26.
//

import XCTest
@testable import MVVM_CleanArchitectureSwiftUI

private final class MockGetUserProfileUseCase: GetUserProfileUseCaseProtocol {
    var result: Result<UserProfile, Error>!

    func execute(userId: Int) async throws -> UserProfile {
        try result.get()
    }
}

private extension UserProfile {
    static func stub(id: Int = 1) -> UserProfile {
        UserProfile(
            id: id,
            name: "Leanne Graham",
            username: "Bret",
            email: "leanne@example.com",
            phone: "1-770-736-8031",
            website: "hildegard.org",
            address: .init(street: "Kulas Light", city: "Gwenborough", zipcode: "92998-3874"),
            company: .init(name: "Romaguera-Crona", catchPhrase: "Multi-layered client-server neural-net")
        )
    }
}

@MainActor
final class UserProfileViewModelTests: XCTestCase {
    func test_loadProfile_success_updatesStateToLoaded() async throws {
        let mockUseCase = MockGetUserProfileUseCase()
        mockUseCase.result = .success(.stub())
        let viewModel = UserProfileViewModel(getUserProfileUseCase: mockUseCase)

        viewModel.loadProfile(userId: 1)
        // Allow the Task to run.
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.state, .loaded(.stub()))
    }

    func test_loadProfile_failure_updatesStateToFailed() async throws {
        let mockUseCase = MockGetUserProfileUseCase()
        mockUseCase.result = .failure(AppError.notFound)
        let viewModel = UserProfileViewModel(getUserProfileUseCase: mockUseCase)

        viewModel.loadProfile(userId: 999)
        try await Task.sleep(nanoseconds: 50_000_000)

        if case .failed(let message) = viewModel.state {
            XCTAssertEqual(message, AppError.notFound.errorDescription)
        } else {
            XCTFail("Expected failed state, got \(viewModel.state)")
        }
    }
}
