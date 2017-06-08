//
//  CustomCollectionCell.swift
//  MySampleApp
//
//  Created by Matt Hibshman on 4/10/17.
//
//

import Foundation
import UIKit

class CustomCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var miles: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var number: Int = -1
}
