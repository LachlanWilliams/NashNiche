//
//  preSignUpViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 10/4/2024.
//

import UIKit

enum UserType {
    case parent
    case nanny
}

class preSignUpViewController: UIViewController {

    var userType: UserType?
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        if databaseController?.fetchCorePersons().count != 0 {
            print("This is corePerson : \(databaseController!.corePerson)")
            if ((databaseController?.corePerson.inNanny) != nil) {
                if databaseController!.corePerson.inNanny {
                    self.performSegue(withIdentifier: "skipNannySignInSegue", sender: self.userType)
                }else{
                    self.performSegue(withIdentifier: "skipParentSignInSegue", sender: self.userType)
                }
            }
        }

        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueParentSignUp" {
            if let signUpVC = segue.destination as? signUpViewController {
                signUpVC.userType = UserType.parent
            }
        } else if segue.identifier == "segueNannySignUp" {
            if let signUpVC = segue.destination as? signUpViewController {
                signUpVC.userType = UserType.nanny
            }
        } else if segue.identifier == "skipNannySignInSegue" {
            
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
