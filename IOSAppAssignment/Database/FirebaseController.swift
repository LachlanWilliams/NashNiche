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
import CoreData

class FirebaseController: NSObject, DatabaseProtocol {
        
    let DEFAULT_PERSON_EMAIL = "DefaultPerson@email"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var allHeroesFetchedResultsController: NSFetchedResultsController<CorePerson>?
    var jobList: [Job]
    var currentPersonJobs: [Job]
    var defaultPerson: Person
    var currentPerson: Person
    var corePerson: CorePerson
    
    var authController: Auth
    var database: Firestore
    var jobsRef: CollectionReference?
    var personsRef: CollectionReference?
    var currentUser: FirebaseAuth.User?

    override init() {
        jobList = [Job]()
        currentPersonJobs = [Job]()
        defaultPerson = Person()
        currentPerson = Person()
        corePerson = CorePerson()
        
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        
        
        persistentContainer = NSPersistentContainer(name: "NashNicheDataModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        
        
        super.init()
        
        let _ = fetchCorePersons()
        
        Task {
            self.setupJobListener()
        }
    }
    
    func cleanup() {
        print("THIS IS CLEAN UP")
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: any DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .jobs || listener.listenerType == .all {
            listener.onAllJobsChange(change: .update, jobs: jobList)
        }
        // TODO: get the listener
        if listener.listenerType == .person || listener.listenerType == .all {
            listener.onPersonChange(change: .update, personJobs: currentPersonJobs)
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
        
        let _ = addJobtoPerson(job: job, person: currentPerson)
        
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
        person.id = uid
        do{
            // here we are setting the new Person doc to have the same ID as the User
            if let _ = try personsRef?.document(uid).setData(from: person){
                
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
        personsRef?.document(personID).updateData( ["jobs" : FieldValue.arrayUnion([jobID])] )
        return true
    }
    
    func removeJobfromPerson(job: Job, person: Person) {
        guard let jobID = job.id, let _ = person.id else{
            return
        }
        if person.jobs.contains(jobID), let personID = person.id, let jobID = job.id {
            if let removedJobRef = jobsRef?.document(jobID) {
                personsRef?.document(personID).updateData(["jobs": FieldValue.arrayRemove([removedJobRef])])
            }
        }
    }
    
    func setCurrentPerson(id: String) async {
        //let ref = personsRef?.document(id)
        
        Task{
            do {
                let person = try await personsRef?.document(id).getDocument(as: Person.self)
                currentPerson = person!
            } catch {
                print("Error decoding person: \(error)")
            }
        }
        let defaultJob = Job()
        for jobID in currentPerson.jobs{
            
            currentPersonJobs.append(getJobByID(jobID) ?? defaultJob)
        }
        return
    }
    
    func getCurrentPersonJobs() -> [Job]{
        let defaultJob = Job()
        for jobID in currentPerson.jobs{
            
            currentPersonJobs.append(getJobByID(jobID) ?? defaultJob)
        }
        return currentPersonJobs
        
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
        
        if let jobReferences = snapshot.data()["jobs"] as? [DocumentReference] {
            for reference in jobReferences {
                
                if let job = getJobByID(reference.documentID) {
                    defaultPerson.jobs.append(reference.documentID)
                }
                
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == .person || listener.listenerType == .all {
                listener.onPersonChange(change: .update, personJobs:  currentPersonJobs)
            }
        }
        
    }
    
    func deleteSuperhero(corePerson: CorePerson) {
        persistentContainer.viewContext.delete(corePerson)
        cleanup()
    }

    func fetchCorePersons() -> [CorePerson] {
        var corePersons = [CorePerson]()
        let request: NSFetchRequest<CorePerson> = CorePerson.fetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            try corePersons = persistentContainer.viewContext.fetch(request)
            print("This is corePersons: \(corePersons)")
        } catch {
            print("Fetch Request failed with error: \(error)")
        }
        // using this for testing
//        for coreerson in corePersons {
//            deleteSuperhero(corePerson: coreerson)
//        }
        if corePersons.count != 0 {
            self.corePerson = corePersons[0]
            //deleteSuperhero(corePerson: corePersons[0])
            let email = corePersons[0].email!
            let password = corePersons[0].password!
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                //guard let strongSelf = self else { return }
                if let error = error {
                    // Handle sign-in failure
                    print("Failed to sign in: \(error.localizedDescription)")
                } else {

                    //let uid =  Auth.auth().currentUser?.uid ?? "no UID"
                    Task{
                        let _ = await self.setCurrentPerson(id: Auth.auth().currentUser?.uid ?? "")
                    }
                }
            }
            //currentPerson = fetchAllJobs()[0] ?? Person()
        }else {
        }
        return corePersons
    }
    
    func setCorePerson(email: String, password: String, uid: String, isNanny: Bool){
        
        print("--------- set person ---------")
        self.corePerson = NSEntityDescription.insertNewObject(forEntityName: "CorePerson", into: persistentContainer.viewContext) as! CorePerson
    
        self.corePerson.email = email
        self.corePerson.password = password
        self.corePerson.uid = uid
        self.corePerson.inNanny = isNanny
        cleanup()
    }


    func registerUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        authController.createUser(withEmail: email, password: password, completion: completion)
    }
}
