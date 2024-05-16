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
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                // Handle sign-in failure
                strongSelf.showAlert(message: "Failed to sign in: \(error.localizedDescription)")
            } else {
                // Sign-in successful
                // segue to the home page
                let userInfo = "Email: \(strongSelf.databaseController?.currentPerson.email ?? "no email")"
                // TODO: firgure out how to set currentPerson in firebaseController
                //let id = Auth.auth().currentUser?.uid ?? ""
//                strongSelf.showAlert(message: "finished task: \(Auth.auth().currentUser?.uid ?? "")")
                Task{
                    let _ = await strongSelf.databaseController?.setCurrentPerson(id: Auth.auth().currentUser?.uid ?? "");
                }

                //strongSelf.showAlert(message: "\(strongSelf.databaseController?.currentPerson.lName ?? "cant find")")
                let alert = UIAlertController(title: "Signup Successful", message: userInfo, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    if strongSelf.userType == UserType.nanny {
                        strongSelf.performSegue(withIdentifier: "segueNannyHome", sender: strongSelf.userType)
                    } else {
                        strongSelf.performSegue(withIdentifier: "segueParentHome", sender: strongSelf.userType)
                    }
                }))
                strongSelf.present(alert, animated: true, completion: nil)

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
