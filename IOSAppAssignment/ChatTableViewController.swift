//
//  ChatTableViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 3/6/2024.
//

import UIKit

class ChatTableViewController: UITableViewController, DatabaseListener {

    var allJobs: [Job] = []
    var personJobs: [Job] = []
    var filteredJobs: [Job] = []

    // database items
    var listenerType = ListenerType.jobs
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        _ = databaseController?.getCurrentPersonJobs()
        personJobs = databaseController?.currentPersonJobs ?? []
        filteredJobs = filter(personJobs: personJobs)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func onPersonChange(change: DatabaseChange, personJobs: [Job]) {
        // Do nothing
    }
    
    func onAllJobsChange(change: DatabaseChange, jobs: [Job]) {
        allJobs = jobs
    }
    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        refreshView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredJobs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)

        // Configure the cell...
        let job = filteredJobs[indexPath.row]
        cell.textLabel?.text = job.title

        return cell
    }
    func refreshView() {
        _ = databaseController?.getCurrentPersonJobs()
        personJobs = databaseController?.currentPersonJobs ?? []
        filteredJobs = filter(personJobs: personJobs)
        self.tableView.reloadData()
        
    }
    
    func filter(personJobs: [Job])-> [Job]{
        var filteredJobs = [Job]()
        filteredJobs = []
        for job in personJobs {
            if job.messages != nil && !(job.messages!.isEmpty){
                filteredJobs.append(job)
            }
        }
        
        return filteredJobs
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "chatLogSegue" {
            if let signUpVC = segue.destination as? ChatLogtViewController {
                signUpVC.job = filteredJobs[self.tableView.indexPathForSelectedRow?.row ?? 0]
            }
        }
    }


}
