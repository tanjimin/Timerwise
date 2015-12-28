//
//  TaskTableViewCell.swift
//  Counter (July 23)
//
//  Created by Developer on 7/23/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskDurationLabel: UILabel!
    @IBOutlet weak var smallDot: UIImageView!
    @IBOutlet weak var hourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
