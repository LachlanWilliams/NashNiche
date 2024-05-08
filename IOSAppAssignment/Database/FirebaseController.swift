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
        job.duration = duration
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
    
    func addPerson(fName: String, lName: String, email: String, isNanny: Bool, uid: String ) -> Person {
        let person = Person()
        person.fName = fName
        person.lName = lName
        person.email = email
        person.isNanny = isNanny
        person.uid = uid
        do{
            if let personRef = try personsRef?.addDocument(from: person) {
                person.id = personRef.documentID
            }
        } catch {
            print("Failed to serialize job")
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
        personsRef = database.collection("person")
        
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
    
    func loginUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        authController.signIn(withEmail: email, password: password, completion: completion)
    }

    func registerUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        authController.createUser(withEmail: email, password: password, completion: completion)
    }

}
