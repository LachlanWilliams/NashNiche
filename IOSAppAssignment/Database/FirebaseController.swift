//
//  FirebaseController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 29/4/2024.
//
//TODO: redo the whole thing

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    let DEFAULT_PERSON_EMAIL = "DefaultPerson@email"
    var listeners = MulticastDelegate<DatabaseListener>()
    var jobList: [Job]
    var defaultPerson: Person
    
    var authController: Auth
    var database: Firestore
    var jobsRef: CollectionReference?
    var personsRef: CollectionReference?
    var currentUser: FirebaseAuth.User?

    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        jobList = [Job]()
        defaultPerson = Person()
        super.init()
        
        Task {
            do {
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user
            } catch {
                fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
            }
            self.setupJobListener()
        }
    }
    
    func cleanup() {}
    
    func addListener(listener: any DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .jobs || listener.listenerType == .all {
            listener.onAllJobsChange(change: .update, jobs: jobList)
        }
        // TODO: get the listener 
        if listener.listenerType == .person || listener.listenerType == .all {
            listener.onPersonChange(change: .update, personJobs: defaultPerson.jobs)
        }
    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addJob(title: String, location: String, dateTime: String, duration: String, desc: String) -> Job {
        let job = Job()
        job.title = title
        job.location = location
        job.dateTime = dateTime
        job.desc = desc
        
        do {
            if let jobRef = try jobsRef?.addDocument(from: job) {
                job.id = jobRef.documentID
            }
        } catch {
            print("Failed to serialize job")
        }
        
        return job
    }
    
    func deleteJob(job: Job) {
        if let jobID = job.id {
            jobsRef?.document(jobID).delete()
        }
    }
    
    func addPerson(fName: String, lName: String, email: String, password: String ) -> Person {
        let person = Person()
        person.fName = fName
        person.lName = lName
        person.email = email
        person.password = password
        if let personRef = personsRef?.addDocument(data: ["email" : email]) {
            person.id = personRef.documentID
        }
        return person
    }
    
    func deletePerson(person: Person) {
        if let personID = person.id {
            personsRef?.document(personID).delete()
        }
    }
    
    func addJobtoPerson(job: Job, person: Person) -> Bool {
        guard let jobID = job.id, let personID = person.id else{
            return false
        }
        if let newJobRef = jobsRef?.document(jobID) {
            personsRef?.document(personID).updateData( ["jobs" : FieldValue.arrayUnion([newJobRef])] )
        }
        return true
    }
    
    func removeJobfromPerson(job: Job, person: Person) {
        if person.jobs.contains(job), let personID = person.id, let jobID = job.id {
            if let removedJobRef = jobsRef?.document(jobID) {
                personsRef?.document(personID).updateData(["jobs": FieldValue.arrayRemove([removedJobRef])])
            }
        }
    }
    
    // FIREBASE SPECIFIC FUNCTIONS BELOW
    
    func getJobByID(_ id: String) -> Job?{
        for job in jobList {
            if job.id == id {
                return job
            }
        }
        return nil
        
    }
    
    func setupJobListener(){
        jobsRef = database.collection("job")
        
        jobsRef?.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self?.parseJobsSnapshot(snapshot: querySnapshot)
            
            if self?.personsRef == nil {
                self?.setupPersonListener()
            }
        }
    }
    
    func setupPersonListener(){
        personsRef = database.collection("peron")
        
        personsRef?.whereField("email", isEqualTo: DEFAULT_PERSON_EMAIL).addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let personSnapshot = querySnapshot.documents.first else {
                print("Error fetching teams: \(String(describing: error))")
                return
            }
            
            self?.parsePersonSnapshot(snapshot: personSnapshot)
        }
        
    }
    
    func parseJobsSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var job: Job
            do {
                job = try change.document.data(as: Job.self)
            } catch {
                fatalError("Unable to decode hero: \(error.localizedDescription)")
            }
            
            if change.type == .added {
                jobList.insert(job, at: Int(change.newIndex))
            } else if change.type == .modified {
                jobList.remove(at: Int(change.oldIndex))
                jobList.insert(job, at: Int(change.newIndex))
            } else if change.type == .removed {
                jobList.remove(at: Int(change.oldIndex))
            }
            
            listeners.invoke { (listener) in
                if listener.listenerType == .jobs || listener.listenerType == .all {
                    listener.onAllJobsChange(change: .update, jobs: jobList)
                }
            }
        }
        
    }
    
    func parsePersonSnapshot(snapshot: QueryDocumentSnapshot){
        defaultPerson = Person()
        defaultPerson.email = snapshot.data()["email"] as? String
        defaultPerson.id = snapshot.documentID
        
        if let jobReferences = snapshot.data()["job"] as? [DocumentReference] {
            for reference in jobReferences {
                if let job = getJobByID(reference.documentID) {
                    defaultPerson.jobs.append(job)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == .person || listener.listenerType == .all {
                listener.onPersonChange(change: .update, personJobs:  defaultPerson.jobs)
            }
        }
        
    }
    

}

/*
 //
 //  FirebaseController.swift
 //  FIT3178-W04-Lab
 //
 //  Created by Lachlan J Williams on 18/4/2024.
 //

 import UIKit
 import Firebase
 import FirebaseFirestoreSwift

 class FirebaseController: NSObject, DatabaseProtocol {
     let DEFAULT_TEAM_NAME = "Default Team"
     var listeners = MulticastDelegate<DatabaseListener>()
     var heroList: [Superhero]
     var defaultTeam: Team
     
     var authController: Auth
     var database: Firestore
     var heroesRef: CollectionReference?
     var teamsRef: CollectionReference?
     var currentUser: FirebaseAuth.User?
     
     override init() {
         FirebaseApp.configure()
         authController = Auth.auth()
         database = Firestore.firestore()
         heroList = [Superhero]()
         defaultTeam = Team()
         super.init()
         
         Task {
             do {
                 let authDataResult = try await authController.signInAnonymously()
                 currentUser = authDataResult.user
             } catch {
                 fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
             }
             self.setupHeroListener()
         }
     }
     
     func addListener(listener: any DatabaseListener) {
         listeners.addDelegate(listener)
         if listener.listenerType == .heroes || listener.listenerType == .all {
             listener.onAllHeroesChange(change: .update, heroes: heroList)
         }
         if listener.listenerType == .team || listener.listenerType == .all {
             listener.onTeamChange(change: .update, teamHeroes: defaultTeam.heroes)
         }
     }

     
     func removeListener(listener: DatabaseListener) {
         listeners.removeDelegate(listener)
     }
     
     func addSuperhero(name: String, abilities: String, universe: Universe) -> Superhero {
         let hero = Superhero()
         hero.name = name
         hero.abilities = abilities
         hero.universe = universe.rawValue
         
         do {
             if let heroRef = try heroesRef?.addDocument(from: hero) {
                 hero.id = heroRef.documentID
             }
         } catch {
             print("Failed to serialize hero")
         }
         
         return hero
     }
     
     func addTeam(teamName: String) -> Team {
         let team = Team()
         team.name = teamName
         
         if let teamRef = teamsRef?.addDocument(data: ["name" : teamName]) {
             team.id = teamRef.documentID
         }
         
         return team
     }
     
     func addHeroToTeam(hero: Superhero, team: Team) -> Bool {
         guard let heroID = hero.id, let teamID = team.id, team.heroes.count < 6 else {
             return false
         }
         
         if let newHeroRef = heroesRef?.document(heroID) {
             teamsRef?.document(teamID).updateData(
                 ["heroes" : FieldValue.arrayUnion([newHeroRef])]
             )
         }
         return true
     }
     
     func deleteSuperhero(hero: Superhero) {
         if let heroID = hero.id {
             heroesRef?.document(heroID).delete()
         }
     }
     
     func deleteTeam(team: Team) {
         if let teamID = team.id {
             teamsRef?.document(teamID).delete()
         }
     }
     
     func removeHeroFromTeam(hero: Superhero, team: Team) {
         guard team.heroes.contains(hero), let teamID = team.id, let heroID = hero.id else {
             return
         }
         
         if let removedHeroRef = heroesRef?.document(heroID) {
             teamsRef?.document(teamID).updateData(
                 ["heroes": FieldValue.arrayRemove([removedHeroRef])]
             )
         }
     }
     
     func cleanup() {}
     
     // MARK: - Firebase Controller Specific Methods
     
     func getHeroByID(_ id: String) -> Superhero? {
         for hero in heroList {
             if hero.id == id {
                 return hero
             }
         }
         return nil
     }
     
     func setupHeroListener() {
         heroesRef = database.collection("superheroes")
         
         heroesRef?.addSnapshotListener { [weak self] (querySnapshot, error) in
             guard let querySnapshot = querySnapshot else {
                 print("Failed to fetch documents with error: \(String(describing: error))")
                 return
             }
             
             self?.parseHeroesSnapshot(snapshot: querySnapshot)
             
             if self?.teamsRef == nil {
                 self?.setupTeamListener()
             }
         }
     }
     
     func setupTeamListener() {
         teamsRef = database.collection("teams")
         
         teamsRef?.whereField("name", isEqualTo: DEFAULT_TEAM_NAME).addSnapshotListener { [weak self] (querySnapshot, error) in
             guard let querySnapshot = querySnapshot, let teamSnapshot = querySnapshot.documents.first else {
                 print("Error fetching teams: \(String(describing: error))")
                 return
             }
             
             self?.parseTeamSnapshot(snapshot: teamSnapshot)
         }
     }
     
     func parseHeroesSnapshot(snapshot: QuerySnapshot) {
         snapshot.documentChanges.forEach { (change) in
             var hero: Superhero
             do {
                 hero = try change.document.data(as: Superhero.self)
             } catch {
                 fatalError("Unable to decode hero: \(error.localizedDescription)")
             }
             
             if change.type == .added {
                 heroList.insert(hero, at: Int(change.newIndex))
             } else if change.type == .modified {
                 heroList.remove(at: Int(change.oldIndex))
                 heroList.insert(hero, at: Int(change.newIndex))
             } else if change.type == .removed {
                 heroList.remove(at: Int(change.oldIndex))
             }
             
             listeners.invoke { (listener) in
                 if listener.listenerType == .heroes || listener.listenerType == .all {
                     listener.onAllHeroesChange(change: .update, heroes: heroList)
                 }
             }
         }
     }
     
     func parseTeamSnapshot(snapshot: QueryDocumentSnapshot) {
         defaultTeam = Team()
         defaultTeam.name = snapshot.data()["name"] as? String
         defaultTeam.id = snapshot.documentID
         
         if let heroReferences = snapshot.data()["heroes"] as? [DocumentReference] {
             for reference in heroReferences {
                 if let hero = getHeroByID(reference.documentID) {
                     defaultTeam.heroes.append(hero)
                 }
             }
         }
         
         listeners.invoke { (listener) in
             if listener.listenerType == .team || listener.listenerType == .all {
                 listener.onTeamChange(change: .update, teamHeroes: defaultTeam.heroes)
             }
         }
     }
 }

 
 */
