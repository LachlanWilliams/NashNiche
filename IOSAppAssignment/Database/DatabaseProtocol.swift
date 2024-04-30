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
    func addPerson(fName: String, lName: String, email: String, password: String ) -> Person
    func deletePerson(person: Person)
    func addJobtoPerson(job: Job, person: Person) -> Bool
    func removeJobfromPerson(job: Job, person: Person)
    
}

import Foundation

//enum DatabaseChange{
//    case add
//    case remove
//    case update
//}
//
//enum ListenerType {
//    case team
//    case heroes
//    case all
//}
//
//protocol DatabaseListener: AnyObject {
//    var listenerType: ListenerType {get set}
//    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero])
//    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero])
//}
//
//protocol DatabaseProtocol: AnyObject {
//    func cleanup()
//    
//    func addListener(listener: DatabaseListener)
//    func removeListener(listener: DatabaseListener)
//    
//    func addSuperhero(name: String, abilities:String, universe: Universe) -> Superhero
//    func deleteSuperhero(hero: Superhero)
//    
//    var defaultTeam: Team {get}
//    func addTeam(teamName: String) -> Team
//    func deleteTeam(team: Team)
//    func addHeroToTeam(hero: Superhero, team: Team) -> Bool
//    func removeHeroFromTeam(hero: Superhero, team: Team)
//}
