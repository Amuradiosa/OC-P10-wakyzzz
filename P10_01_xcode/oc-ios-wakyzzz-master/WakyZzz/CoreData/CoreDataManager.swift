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
            request.predicate = NSPredicate(format: "creationDate == %@", alarmCreationDateID)
        do {
            return try context.fetch(request).first
        } catch let error as NSError {
            print("could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
}

//    var repeating: String {
//        var captions = [String]()
//        let repeatingDays = [repeatSun,repeatMon,repeatTue,repeatWed,repeatThu,repeatFri,repeatSat]
//        for i in 0 ..< 6 {
//            if repeatingDays[i] {
//                captions.append(Alarm.daysOfWeek[i])
//            }
//        }
//        return captions.count > 0 ? captions.joined(separator: ", ") : "One time alarm"
//    }
