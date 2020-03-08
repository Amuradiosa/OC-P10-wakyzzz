//
//  Alarms+CoreDataProperties.swift
//  WakyZzz
//
//  Created by Ahmad Murad on 08/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData


extension Alarms {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Alarms> {
        return NSFetchRequest<Alarms>(entityName: "Alarms")
    }

    @NSManaged public var repeatMon: Bool
    @NSManaged public var repeatTue: Bool
    @NSManaged public var repeatWed: Bool
    @NSManaged public var repeatThu: Bool
    @NSManaged public var repeatFri: Bool
    @NSManaged public var repeatSat: Bool
    @NSManaged public var repeatSun: Bool
    @NSManaged public var enabled: Bool
    @NSManaged public var creationDateID: String
    @NSManaged public var time: Int32

}
