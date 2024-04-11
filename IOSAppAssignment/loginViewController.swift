//
//  loginViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 10/4/2024.
//

import UIKit

class loginViewController: UIViewController {

    var userType: UserType?
    
    @IBOutlet weak var loginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userType = userType {
            switch userType {
            case .parent:
                loginLabel.text = "Login As: Parent"
            case .nanny:
                loginLabel.text = "Login As: Nanny"
            }
        }
    }
    
    @IBAction func performLogin(_ sender: Any) {
        if userType == UserType.nanny {
            performSegue(withIdentifier: "segueNannyHome", sender: userType)
        }else{
            performSegue(withIdentifier: "segueParentHome", sender: userType)
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
