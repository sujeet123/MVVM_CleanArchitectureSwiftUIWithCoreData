import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel: UserProfileViewModel
    let userId: Int

    init(userId: Int, viewModel: UserProfileViewModel) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                ProgressView("Loading profile…")
            case .loaded(let profile):
                profileContent(profile)
            case .failed(let message):
                errorView(message)
            }
        }
        .navigationTitle("Profile")
        .task {
            viewModel.loadProfile(userId: userId)
        }
        .refreshable {
            viewModel.loadProfile(userId: userId)
        }
    }

    @ViewBuilder
    private func profileContent(_ profile: UserProfile) -> some View {
        List {
            if profile.isFromCache {
                Section {
                    Label("Showing offline data — pull to refresh", systemImage: "wifi.slash")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.orange.opacity(0.1))
            }

            Section("Personal") {
                LabeledContent("Name", value: profile.name)
                LabeledContent("Username", value: "@\(profile.username)")
                LabeledContent("Email", value: profile.email)
                LabeledContent("Phone", value: profile.phone)
                LabeledContent("Website", value: profile.website)
            }

            Section("Address") {
                LabeledContent("Street", value: profile.address.street)
                LabeledContent("City", value: profile.address.city)
                LabeledContent("Zip", value: profile.address.zipcode)
            }

            Section("Company") {
                LabeledContent("Name", value: profile.company.name)
                LabeledContent("Catchphrase", value: profile.company.catchPhrase)
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Retry") {
                viewModel.loadProfile(userId: userId)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        UserProfileView(
            userId: 1,
            viewModel: DependencyContainer.shared.makeUserProfileViewModel()
        )
    }
}

//import SwiftUI
//
//struct UserProfileView: View {
//    @StateObject private var viewModel: UserProfileViewModel
//    let userId: Int
//
//    init(userId: Int, viewModel: UserProfileViewModel) {
//        self.userId = userId
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//
//    var body: some View {
//        Group {
//            switch viewModel.state {
//            case .idle:
//                Color.clear
//            case .loading:
//                ProgressView("Loading profile…")
//            case .loaded(let profile):
//                profileContent(profile)
//            case .failed(let message):
//                errorView(message)
//            }
//        }
//        .navigationTitle("profile_name")
//        .task {
//            viewModel.loadProfile(userId: userId)
//        }
//    }
//
//    @ViewBuilder
//    private func profileContent(_ profile: UserProfile) -> some View {
//        List {
//            Section("Personal") {
//                LabeledContent("Name", value: profile.name)
//                LabeledContent("Username", value: "@\(profile.username)")
//                LabeledContent("Email", value: profile.email)
//                LabeledContent("Phone", value: profile.phone)
//                LabeledContent("Website", value: profile.website)
//            }
//
//            Section("Address") {
//                LabeledContent("Street", value: profile.address.street)
//                LabeledContent("City", value: profile.address.city)
//                LabeledContent("Zip", value: profile.address.zipcode)
//            }
//
//            Section("Company") {
//                LabeledContent("Name", value: profile.company.name)
//                LabeledContent("Catchphrase", value: profile.company.catchPhrase)
//            }
//        }
//    }
//
//    private func errorView(_ message: String) -> some View {
//        VStack(spacing: 12) {
//            Image(systemName: "exclamationmark.triangle")
//                .font(.largeTitle)
//                .foregroundStyle(.orange)
//            Text(message)
//                .multilineTextAlignment(.center)
//                .foregroundStyle(.secondary)
//            Button("Retry") {
//                viewModel.loadProfile(userId: userId)
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    NavigationStack {
//        UserProfileView(
//            userId: 1,
//            viewModel: DependencyContainer.shared.makeUserProfileViewModel()
//        )
//    }
//}
