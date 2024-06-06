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
    var messages: [message] = []
    var currentPersonIsNanny: Bool = true
    
    var listenerType = ListenerType.jobs
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        currentPersonIsNanny = databaseController?.currentPerson.isNanny ?? true
        initalLabel.layer.cornerRadius = 10 // Adjust the corner radius as needed
        initalLabel.clipsToBounds = true
        previousLabel = initalLabel
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            messages = await getMessages()
            showMessages()
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
        newLabel.backgroundColor = UIColor.link
        newLabel.textColor = UIColor.white
        newLabel.font = UIFont.systemFont(ofSize: 16)
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
        
        let _ = databaseController?.addMessage(text: self.textBox.text!, isNanny: databaseController?.currentPerson.isNanny ?? true, job: self.job)

        previousLabel = newLabel
        self.textBox.text = ""
        
    }
    
    func showMessages() {
            for message in messages {
                let newLabel = UILabel()
                newLabel.text = message.text
                newLabel.numberOfLines = 0
                newLabel.textColor = .black
                newLabel.font = UIFont.systemFont(ofSize: 16)
                newLabel.backgroundColor = UIColor.separator
                newLabel.layer.cornerRadius = 10
                newLabel.clipsToBounds = true
                newLabel.translatesAutoresizingMaskIntoConstraints = false
                
                self.view.addSubview(newLabel)

                // Add constraints based on the sender
                if message.isNanny == currentPersonIsNanny {
                    newLabel.backgroundColor = UIColor.link
                    newLabel.textColor = UIColor.white
                    newLabel.textAlignment = .right
                    NSLayoutConstraint.activate([
                        newLabel.topAnchor.constraint(equalTo: self.previousLabel.bottomAnchor, constant: 16),
                        newLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                        newLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 16)
                    ])
                } else {
                    newLabel.textAlignment = .left
                    NSLayoutConstraint.activate([
                        newLabel.topAnchor.constraint(equalTo: self.previousLabel.bottomAnchor, constant: 16),
                        newLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                        newLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -16)
                    ])
                }

                previousLabel = newLabel
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
