//
//  LocalUserDataSource.swift
//  MVVM_CleanArchitectureSwiftUI
//
//  Created by Sujeet kumar on 21/09/26.
//
import CoreData

protocol LocalUserDataSourceProtocol: Sendable {
    /// Returns the cached profile for this id, or nil if nothing is cached yet.
    func getUserProfile(id: Int) async throws -> UserProfile?
    /// Saves (or overwrites) the cached profile — called after a successful network fetch.
    func saveUserProfile(_ profile: UserProfile) async throws
}

/// `final class ... Sendable` is safe here because the only stored property
/// is the CoreDataStack singleton (itself just holding thread-safe Core Data
/// objects), and every method hops onto the background context's own queue
/// via `context.perform` before touching anything — so there's no shared
/// mutable state that two callers could race on.
final class CoreDataUserDataSource: LocalUserDataSourceProtocol, @unchecked Sendable {
    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    func getUserProfile(id: Int) async throws -> UserProfile? {
        let context = stack.backgroundContext

        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request = NSFetchRequest<CDUserProfile>(entityName: "CDUserProfile")
                request.predicate = NSPredicate(format: "id == %d", id)
                request.fetchLimit = 1

                do {
                    let result = try context.fetch(request).first
                    continuation.resume(returning: result?.toDomain())
                } catch {
                    continuation.resume(throwing: AppError.unknown)
                }
            }
        }
    }

    func saveUserProfile(_ profile: UserProfile) async throws {
        let context = stack.backgroundContext

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            context.perform {
                let request = NSFetchRequest<CDUserProfile>(entityName: "CDUserProfile")
                request.predicate = NSPredicate(format: "id == %d", profile.id)
                request.fetchLimit = 1

                do {
                    // Upsert: update the existing row if we have one, otherwise insert a new one.
                    let existing = try context.fetch(request).first
                    let cdProfile = existing ?? CDUserProfile(context: context)
                    cdProfile.update(from: profile)

                    if context.hasChanges {
                        try context.save()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: AppError.unknown)
                }
            }
        }
    }
}
