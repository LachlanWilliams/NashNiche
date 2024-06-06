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
    /// Called when there is a change in all jobs data.
    /// - Parameters:
    ///   - change: Type of database change.
    ///   - jobs: Array of all jobs.
    func onAllJobsChange(change: DatabaseChange, jobs: [Job]) {
        allJobs = jobs
    }
    // MARK: - Table view data source

    /// Called before the view appears.
    /// - Parameter animated: If true, the view is being added to the window using an animation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        refreshView()
    }
    
    /// Called before the view disappears.
    /// - Parameter animated: If true, the disappearance of the view is being animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
 
    /// Returns the number of sections in the table view.
    /// - Parameter tableView: The table view requesting this information.
    /// - Returns: The number of sections in the table view.
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    /// Returns the number of rows (jobs) in a given section of the table view.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - section: An index number identifying a section in the table view.
    /// - Returns: The number of rows in the section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredJobs.count
    }

    /// Provides a cell object for each row at a specific location in the table view.
    /// - Parameters:
    ///   - tableView: The table view requesting the cell.
    ///   - indexPath: An index path locating a row in the table view.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)

        // Configure the cell...
        let job = filteredJobs[indexPath.row]
        cell.textLabel?.text = job.title

        return cell
    }
    
    /// Refreshes the view by reloading the data.
    func refreshView() {
        _ = databaseController?.getCurrentPersonJobs()
        personJobs = databaseController?.currentPersonJobs ?? []
        filteredJobs = filter(personJobs: personJobs)
        self.tableView.reloadData()
        
    }
    
    /// Filters jobs that have messages.
    /// - Parameter personJobs: Array of jobs related to the person.
    /// - Returns: Array of filtered jobs.
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

    /// Prepares for navigation by passing the selected job to the destination view controller.
    /// - Parameters:
    ///   - segue: The segue object containing information about the view controllers involved in the segue.
    ///   - sender: The object that initiated the segue.
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
