//
//  CoreDataStack.swift
//  MVVM_CleanArchitectureSwiftUI
//
//  Created by Sujeet kumar on 21/09/26.
//



import CoreData

/// Owns the Core Data "stack": the persistent container (which loads the
/// schema from UserProfileApp.xcdatamodeld, compiled into the app bundle by
/// Xcode) and a background context for all read/write work so Core Data
/// never blocks the main thread.
final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    /// A dedicated background context for all our Core Data work.
    /// `automaticallyMergesChangesFromParent` keeps it in sync if you ever
    /// add other contexts (e.g. a main-thread one for UI-bound fetches).
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()

    private init() {
        // "UserProfileApp" here must match the .xcdatamodeld file's name
        // exactly — NSPersistentContainer looks it up by name in the app
        // bundle at runtime (Xcode compiles the .xcdatamodeld into a .momd
        // and bundles it automatically, no extra build step needed).
        persistentContainer = NSPersistentContainer(name: "UserProfileApp")

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                // In production, handle this more gracefully (e.g. try
                // deleting and recreating the store). For a cache layer,
                // a fatalError during development is fine — it usually means
                // the model file name doesn't match, or entity/attribute
                // names in the .xcdatamodeld don't match CDUserProfile.swift.
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
    }
}

//import CoreData
//
///// Owns the Core Data "stack": the persistent container (which loads the
///// schema from UserProfileApp.xcdatamodeld, compiled into the app bundle by
///// Xcode) and a background context for all read/write work so Core Data
///// never blocks the main thread.
//final class CoreDataStack {
//    static let shared = CoreDataStack()
//
//    let persistentContainer: NSPersistentContainer
//
//    /// A dedicated background context for all our Core Data work.
//    /// `automaticallyMergesChangesFromParent` keeps it in sync if you ever
//    /// add other contexts (e.g. a main-thread one for UI-bound fetches).
//    lazy var backgroundContext: NSManagedObjectContext = {
//        let context = persistentContainer.newBackgroundContext()
//        context.automaticallyMergesChangesFromParent = true
//        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return context
//    }()
//
//    private init() {
//        // "UserProfileApp" here must match the .xcdatamodeld file's name
//        // exactly — NSPersistentContainer looks it up by name in the app
//        // bundle at runtime (Xcode compiles the .xcdatamodeld into a .momd
//        // and bundles it automatically, no extra build step needed).
//        persistentContainer = NSPersistentContainer(name: "UserProfileApp")
//
//        persistentContainer.loadPersistentStores { _, error in
//            if let error {
//                // In production, handle this more gracefully (e.g. try
//                // deleting and recreating the store). For a cache layer,
//                // a fatalError during development is fine — it usually means
//                // the model file name doesn't match, or entity/attribute
//                // names in the .xcdatamodeld don't match CDUserProfile.swift.
//                fatalError("Failed to load Core Data store: \(error)")
//            }
//        }
//    }
//}
