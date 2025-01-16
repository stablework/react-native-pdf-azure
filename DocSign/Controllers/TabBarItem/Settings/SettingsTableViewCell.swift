//
//  SettingsTableViewCell.swift
//  DocSign
//
//  Created by MAC on 16/02/23.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

//MARK: - Outlets
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    
//MARK: - ViewController life cycle method
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
