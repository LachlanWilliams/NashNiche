//
//  profileViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 10/4/2024.
//

import UIKit

class profileViewController: UIViewController {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usertypeLabel: UILabel!
    
    @IBOutlet weak var profilepic: UIImageView!
    
    @IBOutlet weak var jobslider: UISegmentedControl!
    
    @IBOutlet weak var jobTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
