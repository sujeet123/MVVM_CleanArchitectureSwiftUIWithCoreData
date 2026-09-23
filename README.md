
# UserProfileApp

A SwiftUI app demonstrating **MVVM + Clean Architecture + Swift Concurrency**,
fetching a user profile from a REST API (jsonplaceholder.typicode.com).
Also implemented offine support feature with core data.

## Layers

```
UserProfileApp/
├── App/
│   └── UserProfileApp.swift          # @main entry point
├── Domain/                            # Pure business logic — no imports of SwiftUI/Foundation-networking
│   ├── Entities/
│   │   ├── UserProfile.swift          # Business model
│   │   └── AppError.swift             # Framework-agnostic error type
│   ├── Repositories/
│   │   └── UserRepositoryProtocol.swift  # Boundary Domain defines, Data implements
│   └── UseCases/
│       └── GetUserProfileUseCase.swift
├── Data/                               # Everything that talks to the outside world
│   ├── DTO/
│   │   └── UserProfileDTO.swift       # Raw JSON shape + mapper -> Domain model
│   ├── Network/
│   │   ├── APIEndpoint.swift          # Endpoint definitions
│   │   └── APIClient.swift            # async/await URLSession wrapper
│   ├── DataSources/
│   │   └── RemoteUserDataSource.swift
│   └── Repositories/
│       └── UserRepository.swift       # Implements Domain's protocol
├── Presentation/                       # MVVM
│   ├── ViewModels/
│   │   └── UserProfileViewModel.swift # @MainActor, ObservableObject, async/await
│   └── Views/
│       ├── ContentView.swift
│       └── UserProfileView.swift
├── DI/
│   └── DependencyContainer.swift      # Composition root — wires all layers together
└── UserProfileAppTests/
    └── UserProfileViewModelTests.swift # ViewModel tested with a mock use case
```

## Dependency Rule

Dependencies only point **inward**:

```
Presentation  --->  Domain  <---  Data
```

- `Domain` has zero knowledge of SwiftUI, URLSession, or JSON.
- `Data` depends on `Domain` (it implements `UserRepositoryProtocol`), never the reverse.
- `Presentation` depends on `Domain` (use cases), never directly on `Data`.
- `DependencyContainer` is the only file that "sees" every layer at once and
  wires concrete types (APIClient, UserRepository, ViewModel) together.

## Concurrency

- `APIClient.request(_:)` is `async throws`, using `URLSession.data(for:)`.
- `UserProfileViewModel` is `@MainActor` so all `@Published` state mutations
  are automatically main-thread-safe — no manual `DispatchQueue.main.async`.
- Task cancellation is handled: starting a new load cancels any in-flight one,
  and results are dropped if the task was cancelled before completion.

## How to set this up in Xcode

1. Create a new **iOS App** project in Xcode (SwiftUI interface, Swift language).
2. Delete the default `ContentView.swift`.
3. Drag the folders above (`App`, `Domain`, `Data`, `Presentation`, `DI`) into
   your Xcode project, keeping the folder structure and checking
   "Copy items if needed" + "Create groups".
4. For tests: add a Unit Test target if you don't have one, then drag in
   `UserProfileAppTests/UserProfileViewModelTests.swift`.
5. Build & run — it fetches user id `1` from
   `https://jsonplaceholder.typicode.com/users/1` on launch.

## Extending it

- **Swap the API**: change `APIEndpoint.baseURL` / add cases to `UserEndpoint`.
- **Add caching**: create a `LocalUserDataSource` and make `UserRepository`
  check it before hitting the network — no other layer needs to change.
- **Add more features**: repeat the same 3-layer pattern per feature
  (e.g. `Domain/Entities/Post.swift`, `Data/.../PostRepository.swift`, etc.)
- **Mock networking for previews/tests**: implement `APIClientProtocol` or
  `GetUserProfileUseCaseProtocol` with canned data (see the test file).
>>>>>>> 14d7556 (Implemented Clean architecture along with offline sys with core data)
