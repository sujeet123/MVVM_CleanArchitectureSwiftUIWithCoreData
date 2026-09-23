import Foundation
import Combine

enum ViewState<T: Equatable>: Equatable {
    case idle
    case loading
    case loaded(T)
    case failed(String)
}

/// `@MainActor` guarantees all @Published mutations happen on the main thread
/// without manual dispatching. The ViewModel depends only on the use case
/// (Domain layer) — it has no idea the data ultimately comes from a URLSession.
@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published private(set) var state: ViewState<UserProfile> = .idle

    private var getUserProfileUseCase: GetUserProfileUseCaseProtocol
    private var currentTask: Task<Void, Never>?

    init(getUserProfileUseCase: GetUserProfileUseCaseProtocol) {
        self.getUserProfileUseCase = getUserProfileUseCase
    }

    func loadProfile(userId: Int) {
        currentTask?.cancel()
        state = .loading

        currentTask = Task {
            do {
                let profile = try await getUserProfileUseCase.execute(userId: userId)
                guard !Task.isCancelled else { return }
                state = .loaded(profile)
            } catch let error as AppError {
                guard !Task.isCancelled else { return }
                state = .failed(error.errorDescription ?? "Unknown error")
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(AppError.unknown.errorDescription ?? "Unknown error")
            }
        }
    }

    func cancel() {
        currentTask?.cancel()
    }
}
