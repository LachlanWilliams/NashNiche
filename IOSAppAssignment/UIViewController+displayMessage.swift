//
//  UIViewController+displayMessage.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 30/4/2024.
//

import UIKit
 
extension UIViewController {
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
}

