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
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



//
//  MyCardsTableViewController.swift
//  Lab05Alternative
//
//  Created by Lachlan J Williams on 4/4/2024.
//

//import UIKit
//
//class MyCardsTableViewController: UITableViewController, DatabaseListener {
//    
//    let CELL_CARD = "cardCell"
//    
//    var allCards: [MTGCard] = []
//    
//    weak var databaseController: DatabaseProtocol?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        databaseController = appDelegate.databaseController
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        databaseController?.addListener(listener: self)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        databaseController?.removeListener(listener: self)
//    }
//    
//    // MARK: - Table view data source
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return allCards.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CARD, for: indexPath)
//        let card = allCards[indexPath.row]
//
//        cell.textLabel?.text = card.name
//        cell.detailTextLabel?.text = card.setname
//        
//        guard let url = URL(string: card.imageURL ?? "") else {
//            return cell
//        }
//        
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            guard let data = data, error == nil else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                let originalImage = UIImage(data: data)
//                let thumbnailImage = self.createThumbnailImage(image: originalImage!, size: CGSize(width: 20, height: 20))
//                cell.imageView?.image = thumbnailImage
//                cell.setNeedsLayout()
//            }
//        }
//        task.resume()
//        
//        return cell
//    }
//    
//    func createThumbnailImage(image: UIImage, size: CGSize) -> UIImage? {
//            // Resize the image while maintaining the aspect ratio
//            let scale = max(size.width/image.size.width, size.height/image.size.height)
//            let width = image.size.width * scale
//            let height = image.size.height * scale
//            let newSize = CGSize(width: width, height: height)
//            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//            image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
//            let newImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            
//            // Compress the image
//            if let jpegData = newImage?.jpegData(compressionQuality: 0.8) {
//                return UIImage(data: jpegData)
//            } else {
//                return nil
//            }
//    }
//    
//    // MARK: - Database Listener Functions
//    func onCardListChange(cardList: [MTGCard]) {
//        allCards = cardList
//        tableView.reloadData()
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showCardDetails" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let selectedCard = allCards[indexPath.row]
//                if let destinationVC = segue.destination as? CardDetailsViewController {
//                    destinationVC.card = selectedCard
//                }
//            }
//        }
//    }
//}
//
