//
//  ContactsTableViewCell.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 5/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var isTrustedImageView: UIImageView!
    @IBOutlet weak var lastTxt: UILabel!
    @IBOutlet weak var nameTxt: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
