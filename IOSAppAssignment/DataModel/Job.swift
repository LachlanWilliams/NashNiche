//
//  Job.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 29/4/2024.
//

import UIKit
import FirebaseFirestoreSwift

class Job: NSObject, Codable {
    @DocumentID var id: String?
    var title: String?
    var location: String?
    var dateTime: String?
    var duration: String?
    var desc: String?
    
}

enum CodingKeys: String, CodingKey {
    case id
    case title
    case location
    case dateTime
    case duration
    case desc
}
