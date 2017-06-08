//
//  Users.swift
//  MySampleApp
//
//  Created by Thomas Gales on 4/20/17.
//
//

import Foundation
import AWSDynamoDB

class Users: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _username: String?
    var _userId: String?
    
    class func dynamoDBTableName() -> String {
        
        return "jogarun-mobilehub-2062646821-Users"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_username" : "username",
        ]
    }
}
