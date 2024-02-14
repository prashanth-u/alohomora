//
//  HistoryTableViewCell.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 7/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addPerson: UIButton!
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var timeTxt: UILabel!
    @IBOutlet weak var nameTxt: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
