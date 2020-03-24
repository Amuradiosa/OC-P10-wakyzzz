//
//  CoreDataManager.swift
//  WakyZzz
//
//  Created by Ahmad Murad on 29/02/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    // This class will follow the singleton code design pattern to allow us to use a single instance of CoreDataManager object to provide data throughout the whole application.
    static let shared = CoreDataManager()
    
    private init() {
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedRC: NSFetchedResultsController<Alarms>!
    
    func refresh() {
        let request = Alarms.fetchRequest() as NSFetchRequest<Alarms>
        
        let sort = NSSortDescriptor(key: #keyPath(Alarms.time), ascending: true)
        request.sortDescriptors = [sort]
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Couldn't fetch. \(error), \(error.userInfo)")
        }
    }
    
}

extension CoreDataManager {
    
    func fetchAlarm(with alarmCreationDateID: String) -> Alarms? {
        let request = Alarms.fetchRequest() as NSFetchRequest<Alarms>

            request.predicate = NSPredicate(format: "creationDateID == %@", alarmCreationDateID)
        do {
            return try context.fetch(request).first
        } catch let error as NSError {
            print("could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
}
