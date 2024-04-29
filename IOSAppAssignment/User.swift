//
//  User.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 29/4/2024.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    @DocumentID var id: String?
    var fName: String?
    var lName: String?
    var email: String?
    var password: String?
    var jobs: [Job] = []

}
