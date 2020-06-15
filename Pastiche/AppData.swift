//
//  AppData.swift
//  Pastiche
//
//  Created by Keith Irwin on 6/8/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Foundation
import CoreData
import CryptoKit
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AppData")

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
                os_log("%{public}s", log: logger, type: .error, "\(error)")
                fatalError("\(error)")
            }
        }
    }

    func upsert(paste rawValue: String, _ completion: @escaping (Error) -> Void) {
        viewContext.perform {
            do {
                let hash = self.hashOf(paste: rawValue)
                let request: NSFetchRequest<Paste> = Paste.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", hash);
                if let pasteMO = try self.viewContext.fetch(request).first {
                    pasteMO.dateUpdated = Date()
                } else {
                    let pasteMO = Paste(context: self.viewContext)
                    pasteMO.id = hash
                    pasteMO.value = rawValue
                    pasteMO.name = rawValue.flattened().trimmed().sized(100)
                    pasteMO.dateUpdated = Date()
                }
                self.save(completion)
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

    func delete(_ paste: Paste) {
        viewContext.perform {
            self.viewContext.delete(paste)
            self.save() { print("delete save error: \($0)")}
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

    private func hashOf(paste: String) -> String {
        let data = paste.data(using: .utf8)!
        return SHA256.hash(data: data).hex
    }
}

extension Digest {
    var hex: String {
        self.map { String(format: "%02hhx", $0) }.joined()
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
        count <= n ? self : String(self[startIndex...index(startIndex, offsetBy: n)])
    }
}
