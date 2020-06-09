//
//  AppData.swift
//  Pastiche
//
//  Created by Keith Irwin on 6/8/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Foundation
import CoreData

class AppData: NSPersistentContainer {
    static let shared = AppData()

    convenience init() {
        self.init(name: "Pastiche")
        persistentStoreDescriptions[0].setOption(NSNumber(booleanLiteral: true), forKey: NSSQLiteManualVacuumOption)
        loadPersistentStores { (storeDescription, error) in
            self.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.viewContext.automaticallyMergesChangesFromParent = true
            self.viewContext.undoManager = nil

            if let error = error {
                print("\(error)")
                fatalError("\(error)")
            }
        }
    }

    func upsert(paste rawValue: String, _ completion: @escaping (Error) -> Void) {
        findPaste(value: rawValue) { (result) in
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let pasteMO):
                if let pasteMO = pasteMO {
                    pasteMO.dateUpdated = Date()
                } else {
                    let pasteMO = Paste(context: self.viewContext)
                    pasteMO.id = self.hashOf(paste: rawValue)
                    pasteMO.value = rawValue
                    pasteMO.name = rawValue.flattened().trimmed().sized(100)
                    pasteMO.dateUpdated = Date()
                }

                self.save(completion)
            }
        }
    }

    func save(_ completion: ((Error) -> Void)? = nil) {
        do {
            try self.viewContext.save()
        } catch {
            completion?(error)
        }
    }

    func pasteFetchController() -> NSFetchedResultsController<Paste> {
        let fetcher: NSFetchRequest = Paste.fetchRequest()
        fetcher.sortDescriptors = [
            NSSortDescriptor(key: "dateUpdated", ascending: false)
        ]
        let controller = NSFetchedResultsController(fetchRequest: fetcher, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try controller.performFetch()
        } catch {
            fatalError("Unable to make a fetch results controller: \(error).")
        }
        return controller
    }

    private func findPaste(value: String, _ completion: @escaping (Result<Paste?, Error>) -> Void) {
        viewContext.perform {
            let hash = NSNumber(value: self.hashOf(paste: value))
            let request: NSFetchRequest<Paste> = Paste.fetchRequest()
            do {
                request.predicate = NSPredicate(format: "id == %@", hash);
                let paste = try self.viewContext.fetch(request).first
                completion(Result.success(paste))
            } catch {
                completion(Result.failure(error))
            }
        }
    }

    private func hashOf(paste: String) -> Int64 {
        var hasher = Hasher()
        hasher.combine(paste)
        return Int64(hasher.finalize())
    }
}

extension String {

    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func flattened() -> String {
        if let regex = try? NSRegularExpression(pattern: "\\s+", options: []) {
            return regex.stringByReplacingMatches(in: self, options: .withTransparentBounds, range: NSMakeRange(0, self.count), withTemplate: " ")
        }
        return self
    }

    func sized(_ n: Int) -> String {
        // FIXME: Reconsider ellipses once we've moved to a UI
        count <= n ? self : String(self[startIndex...index(startIndex, offsetBy: n)])
    }
}
