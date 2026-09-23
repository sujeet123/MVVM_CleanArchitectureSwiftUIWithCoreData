import Foundation

/// Mirrors the exact JSON shape from the API. This is intentionally decoupled
/// from the Domain `UserProfile` model — if the API's shape changes, only this
/// file and its mapper change; the rest of the app is unaffected.
struct UserProfileDTO: Decodable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: AddressDTO
    let phone: String
    let website: String
    let company: CompanyDTO

    struct AddressDTO: Decodable {
        let street: String
        let city: String
        let zipcode: String
    }

    struct CompanyDTO: Decodable {
        let name: String
        let catchPhrase: String
    }
}

extension UserProfileDTO {
    /// Maps the network model into the Domain model.
    func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            name: name,
            username: username,
            email: email,
            phone: phone,
            website: website,
            address: UserProfile.Address(
                street: address.street,
                city: address.city,
                zipcode: address.zipcode
            ),
            company: UserProfile.Company(
                name: company.name,
                catchPhrase: company.catchPhrase
            )
        )
    }
}
