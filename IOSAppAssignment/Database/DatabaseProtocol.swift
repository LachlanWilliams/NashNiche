//
//  DatabaseProtocol.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 17/4/2024.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case user
    case jobs
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onParentJobChange(change: DatabaseChange, parentJobs: [Job])
    func onAllJobsChange(change: DatabaseChange, jobs: [Job])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addJob(title: String, location: String, dateTime: Date, duration: String, description: String)-> Job
    func deleteJob(job: Job)
}
