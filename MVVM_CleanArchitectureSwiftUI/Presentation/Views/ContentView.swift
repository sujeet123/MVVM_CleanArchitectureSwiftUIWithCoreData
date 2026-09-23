import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            UserProfileView(
                userId: 1,
                viewModel: DependencyContainer.shared.makeUserProfileViewModel()
            )
        }
    }
}

#Preview {
    ContentView()
}
