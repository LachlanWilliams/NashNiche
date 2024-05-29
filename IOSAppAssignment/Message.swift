//
//  Message.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 29/5/2024.
//

import UIKit
import FirebaseFirestoreSwift

public class Message: NSObject, Codable {
    @DocumentID var id: String?
    var parentID: String?
    var nannyID: String?
    var jobID: String?

}
