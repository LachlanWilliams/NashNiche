//
//  profileViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 10/4/2024.
//

import UIKit
import FirebaseAuth

class profileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usertypeLabel: UILabel!
    
    @IBOutlet weak var profilepic: UIImageView!
    
    @IBOutlet weak var jobslider: UISegmentedControl!
    
    @IBOutlet weak var jobTable: UITableView!
    
    var allJobs: [Job] = []
    var personJobs: [Job] = []
    var currentJobs: [Job] = []
    var pastJobs: [Job] = []
    
    var listenerType = ListenerType.jobs
    weak var databaseController: DatabaseProtocol?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        _ = Auth.auth().currentUser?.uid
        
        nameLabel.text = databaseController?.currentPerson.fName
        
        if let isNanny = databaseController?.currentPerson.isNanny {
                usertypeLabel.text = isNanny ? "Nanny" : "Parent"
        } else {
            // Handle the case where isNanny is nil
        }
        //print("currentPeronsjobs: \(databaseController?.currentPersonJobs ?? [])")
        //print("currentPeronsjobs: \(databaseController?.currentPersonJobs ?? [])")

        // Do any additional setup after loading the view.
        
        jobTable.dataSource = self
                jobTable.delegate = self
                
                // Register custom cell if needed
                // jobTable.register(UINib(nibName: "CustomJobCell", bundle: nil), forCellReuseIdentifier: "CustomJobCell")
                
                // Reload table data
        jobTable.reloadData()
        
        jobslider.addTarget(self, action: #selector(jobSliderChanged(_:)), for: .valueChanged)

        
    }
    
    @objc func jobSliderChanged(_ sender: UISegmentedControl) {
            jobTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            databaseController?.addListener(listener: self)
            refreshView()
        }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
        
    func refreshView() {
        _ = databaseController?.getCurrentPersonJobs()
        personJobs = databaseController?.currentPersonJobs ?? []
        print("test to see if personJobs: \(personJobs)")
        filterJobs()
        jobTable.reloadData()
        // If there are other UI elements to refresh, update them here
        nameLabel.text = databaseController?.currentPerson.fName
        if let isNanny = databaseController?.currentPerson.isNanny {
            usertypeLabel.text = isNanny ? "Nanny" : "Parent"
        }
        
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onParentJobChange(change: DatabaseChange, parentJobs: [Job]) {
        //nothing
    }
    
    func onAllJobsChange(change: DatabaseChange, jobs: [Job]) {
        allJobs = jobs
    }
    
    func onPersonChange(change: DatabaseChange, personJobs: [Job]) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of jobs associated with the current person
        if jobslider.selectedSegmentIndex == 0 {
            return currentJobs.count
        } else {
            return pastJobs.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath)
        
        //_ = databaseController?.getCurrentPersonJobs()
        // Configure the cell...
        let job: Job
        if jobslider.selectedSegmentIndex == 0 {
            job = currentJobs[indexPath.row]
        } else {
            job = pastJobs[indexPath.row]
        }
        cell.textLabel?.text = job.title

//        if let job = databaseController?.currentPersonJobs[indexPath.row] {
//            // Populate cell with job information
//            cell.textLabel?.text = job.title
//            // Set other properties as needed
//        } else {
//
//            cell.textLabel?.text = "Not working"
//
//        }

        return cell
    }
    
    func filterJobs() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust the format as needed
        let stringCurrentDate = dateFormatter.string(from: currentDate)
        pastJobs = []
        currentJobs = []
        
        
        for job in personJobs {
            if job.dateTime! < stringCurrentDate {
                pastJobs.append(job)
            }else{
                currentJobs.append(job)
            }
        }
        print("person jobs: \(personJobs)")
        print("Current Jobs: \(currentJobs)")
        print("Past Jobs: \(pastJobs)")
        jobTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileJobSegue" {
            if let indexPath = jobTable.indexPathForSelectedRow {
                let selectedJob = databaseController?.currentPersonJobs[indexPath.row]
                if let destinationVC = segue.destination as? ParentPreviewJobViewController {
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
