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
        
        if fetchAllJobs().count == 0 {
            createTestJobs()
        }
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
        listeners.removeDelegate(listener)
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
    
    func createTestJobs(){
        let _ = addJob(title: "Babysitting for 2 children",
                       location: "123 Main St, Anytown, USA",
                       dateTime: Date(),
                       duration: "6:00 PM to 10:00 PM",
                       description: "Duties include bedtime routine and light meal prep.",
                       parentEmail: "parent1@email.com")

        let _ = addJob(title: "After-school care",
                       location: "456 Elm St, Cityville",
                       dateTime: Date(),
                       duration: "3:00 PM to 6:00 PM on weekdays",
                       description: "Help with homework and light housekeeping required.",
                       parentEmail: "parent2@email.com")

        let _ = addJob(title: "Weekend nanny",
                       location: "789 Oak St, Townsville",
                       dateTime: Date(),
                       duration: "9:00 AM to 3:00 PM on Saturdays and Sundays",
                       description: "Experience with toddlers and meal preparation necessary.",
                       parentEmail: "parent3@email.com")

        let _ = addJob(title: "Part-time nanny",
                       location: "101 Pine St, Villageton",
                       dateTime: Date(),
                       duration: "10:00 AM to 2:00 PM on Mondays, Wednesdays, and Fridays",
                       description: "Must be comfortable with infant care and diaper changes.",
                       parentEmail: "parent4@email.com")

        let _ = addJob(title: "Date night babysitter",
                       location: "789 Maple St, Hamletown",
                       dateTime: Date(),
                       duration: "7:00 PM to 11:00 PM on Fridays and Saturdays",
                       description: "Bedtime routine and light meal prep for 2 children.",
                       parentEmail: "parent5@email.com")
        // Same parent emails
        let _ = addJob(title: "Full-time nanny",
                           location: "222 Cedar Ave, Suburbia",
                           dateTime: Date(),
                           duration: "8:00 AM to 5:00 PM, Monday to Friday",
                           description: "Care for 3 children (ages 2, 4, and 6), including educational activities and light housekeeping.",
                           parentEmail: "parent@email.com")

            let _ = addJob(title: "Overnight nanny",
                           location: "555 Oakwood Dr, Countryside",
                           dateTime: Date(),
                           duration: "10:00 PM to 7:00 AM, Saturdays",
                           description: "Supervise 1 infant and assist with feeding and diaper changes.",
                           parentEmail: "parent@email.com")

            let _ = addJob(title: "Summer nanny",
                           location: "777 Beach Blvd, Seaside",
                           dateTime: Date(),
                           duration: "9:00 AM to 3:00 PM, Monday to Friday, June to August",
                           description: "Engage with 2 school-aged children in outdoor activities and crafts.",
                           parentEmail: "parent@email.com")

            let _ = addJob(title: "Afternoon babysitter",
                           location: "888 Willow Ln, Riverside",
                           dateTime: Date(),
                           duration: "3:30 PM to 6:30 PM on weekdays",
                           description: "Pick up 2 children from school and assist with homework.",
                           parentEmail: "parent@email.com")

            let _ = addJob(title: "Occasional nanny",
                           location: "999 Pinecrest Dr, Mountainview",
                           dateTime: Date(),
                           duration: "Flexible hours as needed",
                           description: "Care for 1 toddler during parent's appointments and errands.",
                           parentEmail: "parent@email.com")
    }


//    func createDefaultHeroes() {
//    let _ = addSuperhero(name: "Bruce Wayne", abilities: "Money", universe:
//    .dc)
//    let _ = addSuperhero(name: "Superman", abilities: "Super Powered
//    Alien", universe: .dc)
//    let _ = addSuperhero(name: "Wonder Woman", abilities: "Goddess",
//    universe: .dc)
//    let _ = addSuperhero(name: "The Flash", abilities: "Speed", universe:
//    .dc)
//    let _ = addSuperhero(name: "Green Lantern", abilities: "Power Ring",
//    universe: .dc)
//    let _ = addSuperhero(name: "Cyborg", abilities: "Robot Beep Beep",
//    universe: .dc)
//    let _ = addSuperhero(name: "Aquaman", abilities: "Atlantian", universe:
//    .dc)
//    let _ = addSuperhero(name: "Captain Marvel", abilities: "Superhuman
//    Strength", universe: .marvel)
//    let _ = addSuperhero(name: "Spider-Man", abilities: "Spider Sense",
//    universe: .marvel)
//    cleanup()
//    }
}
