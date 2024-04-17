//
//  Job+CoreDataProperties.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 17/4/2024.
//
//

import Foundation
import CoreData


extension Job {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Job> {
        return NSFetchRequest<Job>(entityName: "Job")
    }

    @NSManaged public var title: String?
    @NSManaged public var location: String?
    @NSManaged public var dateTime: Date?
    @NSManaged public var duration: String?
    @NSManaged public var desc: String?
    @NSManaged public var parent: String?
    @NSManaged public var nanny: String?
    @NSManaged public var review: String?

}

extension Job : Identifiable {

}
