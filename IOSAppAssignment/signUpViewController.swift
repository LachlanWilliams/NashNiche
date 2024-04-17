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
        guard let firstName = firstNameText.text, !firstName.isEmpty,
              let lastName = lastNameText.text, !lastName.isEmpty,
              let email = emailText.text, !email.isEmpty,
              let password = passwordText.text, !password.isEmpty else {
            // If any field is empty, display an alert
            let alert = UIAlertController(title: "Error", message: "Please fill in all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // If all fields are completed, create an alert with the user's information
        let userInfo = "First Name: \(firstName)\nLast Name: \(lastName)\nEmail: \(email)\nPassword: \(password)"
        let alert = UIAlertController(title: "User Information", message: userInfo, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Perform segue based on user type after dismissing the alert
            if self.userType == UserType.nanny {
                self.performSegue(withIdentifier: "segueNannyHome", sender: self.userType)
            } else {
                self.performSegue(withIdentifier: "segueParentHome", sender: self.userType)
            }
        }))
        present(alert, animated: true, completion: nil)
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
