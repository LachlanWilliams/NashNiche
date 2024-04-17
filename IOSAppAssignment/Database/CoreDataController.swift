//
//  CoreDataController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 17/4/2024.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "NashNicheDataModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    func cleanup() {
        <#code#>
    }
    
    func addListener(listener: any DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .jobs || listener.listenerType == .all {
            listener.onAllJobsChange(change: .update, jobs: fetchAllJobs())
        }
    }
    
    func removeListener(listener: any DatabaseListener) {
        <#code#>
    }
    
    func addJob(title: String, location: String, dateTime: Date, duration: String, description: String, parentEmail: String) -> Job {
        let job = NSEntityDescription.insertNewObject(forEntityName: "Job", into: persistentContainer.viewContext) as! Job
        job.title = title
        job.location = location
        job.dateTime = dateTime
        job.duration = duration
        job.desc = description
        job.parent = parentEmail
        
        return job
    }
    
    func deleteSuperhero(job: Job) {
        persistentContainer.viewContext.delete(job)
    }
    
    func fetchAllJobs() -> [Job] {
        var jobs = [Job]()
        let request: NSFetchRequest<Job> = Job.fetchRequest()
        do {
            try jobs = persistentContainer.viewContext.fetch(request)
        } catch {
            print("Fetch Request failed with error: \(error)")
        }
        return jobs
    }

}
