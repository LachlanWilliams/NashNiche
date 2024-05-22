//
//  CorePerson+CoreDataProperties.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 21/5/2024.
//
//

import Foundation
import CoreData


extension CorePerson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CorePerson> {
        return NSFetchRequest<CorePerson>(entityName: "CorePerson")
    }

    @NSManaged public var inNanny: Bool
    @NSManaged public var email: String?
    @NSManaged public var password: String?
    @NSManaged public var uid: String?

}

extension CorePerson : Identifiable {

}
