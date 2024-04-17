//
//  User+CoreDataProperties.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 17/4/2024.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var fname: String?
    @NSManaged public var email: String?
    @NSManaged public var lname: String?
    @NSManaged public var password: String?
    @NSManaged public var nanny: Bool
    @NSManaged public var jobs: NSSet?

}

// MARK: Generated accessors for jobs
extension User {

    @objc(addJobsObject:)
    @NSManaged public func addToJobs(_ value: Job)

    @objc(removeJobsObject:)
    @NSManaged public func removeFromJobs(_ value: Job)

    @objc(addJobs:)
    @NSManaged public func addToJobs(_ values: NSSet)

    @objc(removeJobs:)
    @NSManaged public func removeFromJobs(_ values: NSSet)

}

extension User : Identifiable {

}
