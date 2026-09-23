import Foundation

/// Pure domain model. Contains no networking / persistence / UI concerns.
/// This is what the rest of the app (ViewModels, Views) should depend on —
/// never on the DTO that comes from the network layer.
struct UserProfile: Identifiable, Equatable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let address: Address
    let company: Company
    /// True when this value was served from the offline cache rather than
    /// a live network response. Defaults to false so existing call sites
    /// (e.g. tests, mappers) that don't pass it keep working unchanged.
    var isFromCache: Bool = false

    struct Address: Equatable {
        let street: String
        let city: String
        let zipcode: String
    }

    struct Company: Equatable {
        let name: String
        let catchPhrase: String
    }
}


//import Foundation
//
///// Pure domain model. Contains no networking / persistence / UI concerns.
///// This is what the rest of the app (ViewModels, Views) should depend on —
///// never on the DTO that comes from the network layer.
//struct UserProfile: Identifiable, Equatable {
//    let id: Int
//    let name: String
//    let username: String
//    let email: String
//    let phone: String
//    let website: String
//    let address: Address
//    let company: Company
//
//    struct Address: Equatable {
//        let street: String
//        let city: String
//        let zipcode: String
//    }
//
//    struct Company: Equatable {
//        let name: String
//        let catchPhrase: String
//    }
//}
