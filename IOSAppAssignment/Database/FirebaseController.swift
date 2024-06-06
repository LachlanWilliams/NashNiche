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
    var messagesRef: CollectionReference?
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
    
    /// Cleans up and saves any changes to the Core Data context.
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    /// Adds a listener to the list of listeners.
    /// - Parameter listener: The listener to be added.
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
    
    /// Removes a listener from the list of listeners.
    /// - Parameter listener: The listener to be removed.
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    /// Adds a new job to Firestore.
    /// - Parameters:
    ///   - title: The title of the job.
    ///   - location: The location of the job.
    ///   - dateTime: The date and time of the job.
    ///   - duration: The duration of the job.
    ///   - desc: The description of the job.
    /// - Returns: The newly created job.
    func addJob(title: String, location: String, dateTime: String, duration: String, desc: String) -> Job {
        let job = Job()
        job.title = title
        job.location = location
        job.dateTime = dateTime
        job.duration = duration
        job.desc = desc
        job.parentID = currentPerson.uid
        job.messages = []
        
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
    
    /// Deletes a job from Firestore.
    /// - Parameter job: The job to be deleted.
    func deleteJob(job: Job) {
        if let jobID = job.id {
            jobsRef?.document(jobID).delete()
        }
    }
    
    /// Adds a new message to a job in Firestore.
    /// - Parameters:
    ///   - text: The text of the message.
    ///   - isNanny: Whether the message is from a nanny.
    ///   - job: The job to which the message belongs.
    /// - Returns: The newly created message.
    func addMessage(text: String, isNanny: Bool, job: Job) -> message{
        var newMessage = message()
        newMessage.text = text
        newMessage.isNanny = isNanny
        let messagesRef = jobsRef?.document(job.id!).collection("messages")

        do {
            if let messageRef = try messagesRef?.addDocument(from: newMessage) {
                newMessage.id = messageRef.documentID
            }
        } catch {
            print("Failed to add message to job: \(error)")
        }
        
        job.messages?.append(newMessage.id ?? "")
        jobsRef?.document(job.id!).updateData(["messages": FieldValue.arrayUnion([newMessage.id ?? ""])])
        
        return newMessage
    }
    
    /// Deletes a message from Firestore.
    /// - Parameter message: The message to be deleted.
    func deleteMessage(message: message){
        if let messageID = message.id {
            messagesRef?.document(messageID).delete()
        }
    }
    
    /// Adds a new person to Firestore.
    /// - Parameters:
    ///   - fName: The first name of the person.
    ///   - lName: The last name of the person.
    ///   - email: The email of the person.
    ///   - isNanny: Whether the person is a nanny.
    ///   - uid: The unique identifier of the person.
    /// - Returns: The newly created person.
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
            print("Failed to serialize Person")
        }
        
        return person
    }
    
    /// Deletes a person from Firestore.
    /// - Parameter person: The person to be deleted.
    func deletePerson(person: Person) {
        if let personID = person.id {
            personsRef?.document(personID).delete()
        }
    }
    
    /// Adds a job to a person in Firestore.
    /// - Parameters:
    ///   - job: The job to be added.
    ///   - person: The person to whom the job is to be added.
    /// - Returns: Whether the job was successfully added to the person.
    func addJobtoPerson(job: Job, person: Person) -> Bool {
        guard let jobID = job.id, let personID = person.id else{
            return false
        }
        personsRef?.document(personID).updateData( ["jobs" : FieldValue.arrayUnion([jobID])] )
        return true
    }
    
    /// Removes a job from a person in Firestore.
    /// - Parameters:
    ///   - job: The job to be removed.
    ///   - person: The person from whom the job is to be removed.
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
    
    /// Sets the current person using their ID.
    /// - Parameter id: The ID of the person to be set as the current person.
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
    
    /// Gets the current person's jobs.
    /// - Returns: A list of jobs belonging to the current person.
    func getCurrentPersonJobs() -> [Job]{
        let defaultJob = Job()
        var temp: [Job]
        temp = []
        for jobID in currentPerson.jobs{
            temp.append(getJobByID(jobID) ?? defaultJob)
        }
        currentPersonJobs = temp
        
        return currentPersonJobs
        
    }
    
    // FIREBASE SPECIFIC FUNCTIONS BELOW
    
    /// Retrieves a job by its ID.
    /// - Parameter id: The ID of the job.
    /// - Returns: The job with the specified ID, or nil if not found.
    func getJobByID(_ id: String) -> Job?{
        for job in jobList {
            if job.id == id {
                return job
            }
        }
        return nil
        
    }
    
    /// Sets up a snapshot listener for job changes in Firestore.
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
    
    /// Sets up a snapshot listener for person changes in Firestore.
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
    
    /// Parses job changes from a Firestore snapshot.
    /// - Parameter snapshot: The Firestore snapshot containing job changes.
    func parseJobsSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var job: Job
            do {
                job = try change.document.data(as: Job.self)
            } catch {
                fatalError("Unable to decode Job: \(error.localizedDescription)")
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
    
    /// Parses person changes from a Firestore snapshot.
    /// - Parameter snapshot: The Firestore snapshot containing person data.
    func parsePersonSnapshot(snapshot: QueryDocumentSnapshot){
        defaultPerson = Person()
        defaultPerson.email = snapshot.data()["email"] as? String
        defaultPerson.id = snapshot.documentID
        
        if let jobReferences = snapshot.data()["jobs"] as? [DocumentReference] {
            for reference in jobReferences {
                
                if let _ = getJobByID(reference.documentID) {
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
    
    /// Deletes a CorePerson from Core Data.
    /// - Parameter corePerson: The CorePerson to be deleted.
    func deleteSuperhero(corePerson: CorePerson) {
        persistentContainer.viewContext.delete(corePerson)
        cleanup()
    }

    /// Fetches all CorePersons from Core Data.
    /// - Returns: A list of CorePersons.
    func fetchCorePersons() -> [CorePerson] {
        var corePersons = [CorePerson]()
        let request: NSFetchRequest<CorePerson> = CorePerson.fetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            try corePersons = persistentContainer.viewContext.fetch(request)
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
    
    /// Sets the CorePerson in Core Data.
    /// - Parameters:
    ///   - email: The email of the CorePerson.
    ///   - password: The password of the CorePerson.
    ///   - uid: The unique identifier of the CorePerson.
    ///   - isNanny: Whether the CorePerson is a nanny.
    func setCorePerson(email: String, password: String, uid: String, isNanny: Bool){
        
        self.corePerson = NSEntityDescription.insertNewObject(forEntityName: "CorePerson", into: persistentContainer.viewContext) as! CorePerson
    
        self.corePerson.email = email
        self.corePerson.password = password
        self.corePerson.uid = uid
        self.corePerson.inNanny = isNanny
        cleanup()
    }

    ///Signs out the current user from Firebase and clears Core Data.
    func signout() {
        // sign out of firebase
        do{
            try Auth.auth().signOut()

        } catch {
            print("Sign out failed with error: \(error)")
        }
        // get rid of persistant storage
        var corePersons = [CorePerson]()
        let request: NSFetchRequest<CorePerson> = CorePerson.fetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            try corePersons = persistentContainer.viewContext.fetch(request)
        } catch {
            print("Fetch Request failed with error: \(error)")
        }
        // using this for testing
        for coreerson in corePersons {
            deleteSuperhero(corePerson: coreerson)
        }
        
    }
    
    ///Fetches messages associated with a job from Firestore.
    ///- Parameter job: The `Job` whose messages will be fetched.
    ///- Returns: An array of `message` objects.
    func getJobMessages(job: Job) async -> [message]{
        let messagesRef = jobsRef?.document(job.id!).collection("messages")
        var messages: [message] = []
        

        do {
            let snapshot = try await messagesRef?.getDocuments()
            for documents in snapshot!.documents {
                do{
                    let newMessageData = try documents.data(as: message.self)
                    var newMessage = message()
                    newMessage.id = newMessageData.id!
                    newMessage.text = newMessageData.text!
                    newMessage.isNanny = newMessageData.isNanny!
                    messages.append(newMessage)
                } catch {
                    print("Failed to serialise message")
                }
            }
        } catch {
            print("Failed to get messages")
        }
        //this might need to be ordered
        let sortedMessages = job.messages!.compactMap { id in
                messages.first(where: { $0.id == id })
        }
        return sortedMessages
    }

    /// Registers a new user with Firebase Authentication.
    ///- Parameters:
    ///   - email: The email of the new user.
    ///   - password: The password of the new user.
    ///   - completion: The completion handler to call when the registration is complete.
    func registerUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        authController.createUser(withEmail: email, password: password, completion: completion)
    }
}
