//
//  Person.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 30/4/2024.
//

import UIKit
import FirebaseFirestoreSwift

public class Person: NSObject, Codable {
    @DocumentID var id: String?
    var fName: String?
    var lName: String?
    var email: String?
    var uid: String?
    var isNanny: Bool?
    var jobs: [String] = []

}
