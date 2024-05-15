//
//  profileViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 10/4/2024.
//

import UIKit
import FirebaseAuth

class profileViewController: UIViewController {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usertypeLabel: UILabel!
    
    @IBOutlet weak var profilepic: UIImageView!
    
    @IBOutlet weak var jobslider: UISegmentedControl!
    
    @IBOutlet weak var jobTable: UITableView!
    
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
        // Do any additional setup after loading the view.
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
