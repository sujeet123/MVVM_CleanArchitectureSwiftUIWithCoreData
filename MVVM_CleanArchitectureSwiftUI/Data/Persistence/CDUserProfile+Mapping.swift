//
//  CDUserProfile+Mapping.swift
//  MVVM_CleanArchitectureSwiftUI
//
//  Created by Sujeet kumar on 21/09/26.
//
import CoreData

/// Mapping helpers between the Core Data object and the Domain `UserProfile`.
/// Kept in a separate file from the generated CDUserProfile class/properties
/// so that if you ever regenerate the class via Xcode's
/// Editor -> Create NSManagedObject Subclass, this file is untouched and
/// won't be overwritten or need re-adding.
extension CDUserProfile {
    /// Copies values from a fetched network result into this Core Data object.
    func update(from profile: UserProfile) {
        id = Int64(profile.id)
        name = profile.name
        username = profile.username
        email = profile.email
        phone = profile.phone
        website = profile.website
        street = profile.address.street
        city = profile.address.city
        zipcode = profile.address.zipcode
        companyName = profile.company.name
        companyCatchPhrase = profile.company.catchPhrase
        lastUpdated = Date()
    }

    /// Maps this Core Data object back into the same Domain model the rest
    /// of the app already works with — the ViewModel/View never need to know
    /// whether a UserProfile came from the network or from the cache.
    func toDomain() -> UserProfile {
        UserProfile(
            id: Int(id),
            name: name ?? "",
            username: username ?? "",
            email: email ?? "",
            phone: phone ?? "",
            website: website ?? "",
            address: UserProfile.Address(street: street ?? "", city: city ?? "", zipcode: zipcode ?? ""),
            company: UserProfile.Company(name: companyName ?? "", catchPhrase: companyCatchPhrase ?? ""),
            isFromCache: true
        )
    }
}
