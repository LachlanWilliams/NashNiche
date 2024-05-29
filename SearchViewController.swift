//
//  searchViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 22/5/2024.
//

import UIKit

class searchViewController: UIViewController {

    @IBOutlet weak var textFeild: UITextField!
    
    @IBOutlet weak var responseLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let apiKey = "secret_here"
    
    var previousLabel: UILabel!
    
    override func viewDidLoad() {
        responseLabel.layer.cornerRadius = 10 // Adjust the corner radius as needed
        responseLabel.clipsToBounds = true
        previousLabel = responseLabel
        
        scrollView.isScrollEnabled = true
        scrollView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), // Align the top of the scroll view with the top of the safe area
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor), // Align the leading edge of the scroll view with the leading edge of the safe area
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor), // Align the trailing edge of the scroll view with the trailing edge of the safe area
            scrollView.bottomAnchor.constraint(equalTo: textFeild.bottomAnchor, constant: -30) // Align the bottom of the scroll view with the bottom of the safe area
        ])
        
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        guard let prompt = textFeild.text, !prompt.isEmpty else {
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
        
        
                
        let messages: [[String: Any]] = [
                    ["role": "system", "content": "Only give your answer in plain text. assume the role of a useful assistant for nannies."],
                    ["role": "user", "content": prompt]
        ]
                // Prepare the request
        let parameters = ["max_tokens": 50, "model": "gpt-4o", "temperature": 1, "messages": messages] as [String : Any] // Adjust max_tokens as needed
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Convert parameters to JSON and attach it to the request
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
                
            // Send the request
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Parse the response
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonDict = jsonResponse as? [String: Any], let choices = jsonDict["choices"] as? [[String: Any]], let firstChoice = choices.first {
                        if let messageDict = firstChoice["message"] as? [String: Any], let content = messageDict["content"] as? String {
                            DispatchQueue.main.async {
                                // Update UI on main thread with the message content
                                //self?.responseLabel.text = content
                                //self?.view.layoutIfNeeded() // Force layout update
                                self?.textFeild.text = ""
                                print(content)
                                
                                let newLabelResponse = UILabel()
                                newLabelResponse.text = content
                                newLabelResponse.numberOfLines = 0
                                newLabelResponse.textColor = .black
                                newLabelResponse.font = UIFont.systemFont(ofSize: 16)
                                newLabelResponse.backgroundColor = UIColor.link
                                newLabelResponse.textColor = UIColor.white
                                newLabelResponse.layer.cornerRadius = 10 // Adjust the corner radius as needed
                                newLabelResponse.clipsToBounds = true
                                // Set up constraints for the new label
                                newLabelResponse.translatesAutoresizingMaskIntoConstraints = false
                                self?.view.addSubview(newLabelResponse)

                                // Add constraints
                                NSLayoutConstraint.activate([
                                    newLabelResponse.topAnchor.constraint(equalTo: self!.previousLabel.bottomAnchor, constant: 16),
                                    newLabelResponse.leadingAnchor.constraint(equalTo: self!.view.leadingAnchor, constant: 16),
                                    newLabelResponse.trailingAnchor.constraint(equalTo: self!.view.trailingAnchor, constant: -16)
                                ])
                                self?.previousLabel = newLabelResponse
                            }
                        }  else {
                            print("Invalid JSON format")
                            print(jsonResponse)
                        }
                }
            } catch let error {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
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
 
