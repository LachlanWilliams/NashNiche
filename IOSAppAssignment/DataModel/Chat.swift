//
//  Chat.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 3/6/2024.
//
import UIKit
import FirebaseFirestoreSwift

public class Chat: NSObject, Codable {
    @DocumentID var id: String?
    var jobID: String?
    var messages: [String: Bool]?
}
