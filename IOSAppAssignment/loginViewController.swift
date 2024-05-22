//
//  loginViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 10/4/2024.
//

import UIKit
import FirebaseAuth

class loginViewController: UIViewController {

    var userType: UserType?
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var emailTextInput: UITextField!
    
    @IBOutlet weak var passwordTextInput: UITextField!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
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
        
        // Check if email and password are not empty
        guard let email = emailTextInput.text, !email.isEmpty,
              let password = passwordTextInput.text, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }
        
        // Perform Firebase sign-in
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            //guard let strongSelf = self else { return }
            if let error = error {
                // Handle sign-in failure
                self.showAlert(message: "Failed to sign in: \(error.localizedDescription)")
            } else {
                
                //let uid =  Auth.auth().currentUser?.uid ?? "no UID"
                print("where is this ")
                Task{
                    let _ = await self.databaseController?.setCurrentPerson(id: Auth.auth().currentUser?.uid ?? "")
                }
                
                var isNanny = true
                if self.userType == UserType.parent{
                    isNanny = false
                }
                
                self.databaseController?.setCorePerson(email: email, password: password, uid: Auth.auth().currentUser?.uid ?? "", isNanny: isNanny)
                
                print("login CorePerson: \(self.databaseController?.corePerson ?? CorePerson())")
                
                let userInfo = "CurrentPerson: \(Auth.auth().currentUser?.uid ?? "didn't work")"

                let alert = UIAlertController(title: "Signup Successful", message: userInfo, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    if self.userType == UserType.nanny {
                        self.performSegue(withIdentifier: "segueNannyHome", sender: self.userType)
                    } else {
                        self.performSegue(withIdentifier: "segueParentHome", sender: self.userType)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass user type to the destination view controller if needed
    }

}
