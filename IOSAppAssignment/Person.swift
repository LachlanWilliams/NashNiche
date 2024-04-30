//
//  Person.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 30/4/2024.
//

import UIKit
import FirebaseFirestoreSwift

class Person: NSObject, Codable {
    @DocumentID var id: String?
    var fName: String?
    var lName: String?
    var email: String?
    var password: String?
    var jobs: [Job] = []

}
