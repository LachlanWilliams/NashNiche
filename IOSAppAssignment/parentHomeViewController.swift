//
//  parentHomeViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 10/4/2024.
//

import UIKit

class parentHomeViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var timeDateTextField: UITextField!
    
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var descTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func postJob(_ sender: Any) {
        guard let title = titleTextField.text, let location = locationTextField.text, let dateTime = timeDateTextField.text, let duration = durationTextField.text, let desc = descTextField.text else{
            return
        }
        if title.isEmpty || location.isEmpty || dateTime.isEmpty || duration.isEmpty || desc.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if title.isEmpty {
                errorMsg += "- provide a title\n"
            }
            if location.isEmpty {
                errorMsg += "- provide a location\n"
            }
            if dateTime.isEmpty {
                errorMsg += "- provide a dateTime\n"
            }
            if duration.isEmpty {
                errorMsg += "- provide a duration\n"
            }
            if desc.isEmpty {
                errorMsg += "- provide a desc\n"
            }
            
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        // Display confirmation alert
        let confirmAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to post this job?", preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            // Add job to the database
            let _ = self.databaseController?.addJob(title: title, location: location, dateTime: dateTime, duration: duration, desc: desc)
            
            // Clear text fields
            self.titleTextField.text = ""
            self.locationTextField.text = ""
            self.timeDateTextField.text = ""
            self.durationTextField.text = ""
            self.descTextField.text = ""
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(confirmAlert, animated: true, completion: nil)
        //let _ = databaseController?.addJob(title: title, location: location, dateTime: dateTime, duration: duration, desc: desc)
        
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
