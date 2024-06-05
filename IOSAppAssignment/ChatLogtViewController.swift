//
//  ChatLogtViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 4/6/2024.
//

//TODO: segue the messages
// - print out the messages on load
// 

import UIKit

class ChatLogtViewController: UIViewController {

    @IBOutlet weak var textBox: UITextField!
    
    @IBOutlet weak var initalLabel: UILabel!
    
    var previousLabel: UILabel!
    
    var job = Job()
    
    var listenerType = ListenerType.jobs
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
                
        initalLabel.layer.cornerRadius = 10 // Adjust the corner radius as needed
        initalLabel.clipsToBounds = true
        previousLabel = initalLabel
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            print(await getMessages())
        }
    }
    
    func getMessages() async -> [message]{
        return await databaseController?.getJobMessages(job: job) ?? []
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        guard let prompt = textBox.text, !prompt.isEmpty else {
                    // Handle empty prompt case
                    return
                }
        let newLabel = UILabel()
        newLabel.text = "\(prompt)"
        newLabel.numberOfLines = 0
        newLabel.textColor = .black
        newLabel.font = UIFont.systemFont(ofSize: 16)
        newLabel.backgroundColor = UIColor.separator
        newLabel.layer.cornerRadius = 10 // Adjust the corner radius as needed
        newLabel.clipsToBounds = true
        newLabel.textAlignment = .right
        // Set up constraints for the new label
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(newLabel)

        // Add constraints
        NSLayoutConstraint.activate([
            newLabel.topAnchor.constraint(equalTo: self.previousLabel.bottomAnchor, constant: 16),
            //newLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            newLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])
        previousLabel = newLabel
        self.textBox.text = ""
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
