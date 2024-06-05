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
    case person
    case jobs
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onPersonChange(change: DatabaseChange, personJobs: [Job])
    func onAllJobsChange(change: DatabaseChange, jobs: [Job])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addJob(title: String, location: String, dateTime: String, duration: String, desc: String)-> Job
    func deleteJob(job: Job)
    
    var defaultPerson: Person {get}
    var currentPerson: Person {get}
    var currentPersonJobs: [(Job)] {get}
    var corePerson: CorePerson {get}
    func addPerson(fName: String, lName: String, email: String, isNanny: Bool, uid: String) -> Person
    func deletePerson(person: Person)
    func addJobtoPerson(job: Job, person: Person) -> Bool
    func removeJobfromPerson(job: Job, person: Person)
    func setCurrentPerson(id: String) async
    func getCurrentPersonJobs() -> [Job]
    func fetchCorePersons() -> [CorePerson]
    func setCorePerson(email: String, password: String, uid: String, isNanny: Bool)
    func signout()
    func addMessage(text: String, isNanny: Bool, job: Job) -> message
}
