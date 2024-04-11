//
//  signUpViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 10/4/2024.
//

import UIKit

class signUpViewController: UIViewController {

    @IBOutlet weak var signUpAs: UILabel!
    
    @IBOutlet weak var firstNameText: UITextField!
    
    @IBOutlet weak var lastNameText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var alreadyButton: UIButton!
    
    var userType: UserType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userType = userType {
            switch userType {
            case .parent:
                signUpAs.text = "Sign Up As: Parent"
            case .nanny:
                signUpAs.text = "Sign Up As: Nanny"
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLogin" {
            if let signUpVC = segue.destination as? loginViewController {
                signUpVC.userType = userType
            }
        }else if segue.identifier == "segueNannyHome" {
            if let signUpVC = segue.destination as? loginViewController {
                signUpVC.userType = userType
            }
            
        }else if segue.identifier == "segueParentHome" {
            
        }
    }
    
    
    @IBAction func performSignUp(_ sender: Any) {
        if userType == UserType.nanny {
            performSegue(withIdentifier: "segueNannyHome", sender: userType)
        } else {
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
