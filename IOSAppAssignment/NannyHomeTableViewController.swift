//
//  NannyHomeTableViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 17/4/2024.
//

import UIKit

class NannyHomeTableViewController: UITableViewController, DatabaseListener {
    
    let SECTION_JOB = 0
    let SECTION_INFO = 1
    let CELL_HERO = "jobCell"
    let CELL_INFO = "totalCell"
    
    var allJobs: [Job] = []
    
    var listenerType = ListenerType.jobs
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onParentJobChange(change: DatabaseChange, parentJobs: [Job]) {
        //nothing
    }
    
    func onAllJobsChange(change: DatabaseChange, jobs: [Job]) {
        allJobs = jobs
    }
    
    func onPersonChange(change: DatabaseChange, personJobs: [Job]) {
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allJobs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let jobCell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath)
        
        let job = allJobs[indexPath.row]
        jobCell.textLabel?.text = job.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a" // Customize the date format as per your preference

        // Convert the Date to a formatted string
        //let dateString = dateFormatter.string(from: job.dateTime!)

        // Assign the formatted string to the detail text label of your jobCell
        jobCell.detailTextLabel?.text = job.dateTime

        
        return jobCell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nannyPreviewSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedJob = allJobs[indexPath.row]
                if let destinationVC = segue.destination as? NannyPreviewJobViewController {
                    destinationVC.job = selectedJob
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
