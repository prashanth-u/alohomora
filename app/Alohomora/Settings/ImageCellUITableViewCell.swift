//
//  ImageCellUITableViewCell.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 7/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit

class ImageCellUITableViewCell: UITableViewCell {
   
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
