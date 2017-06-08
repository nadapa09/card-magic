//
//  Shoes.swift
//  MySampleApp
//
//  Created by Thomas Gales on 4/23/17.
//
//

import Foundation
import UIKit
import AWSDynamoDB

class Shoes: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _shoe: String?
    var _mileage: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "jogarun-mobilehub-2062646821-Shoes"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_shoe"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_shoe" : "shoe",
            "_mileage" : "mileage",
        ]
    }
}
