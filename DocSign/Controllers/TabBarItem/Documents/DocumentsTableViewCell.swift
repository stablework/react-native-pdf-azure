//
//  DocumentsTableViewCell.swift
//  DocSign
//
//  Created by MAC on 04/02/23.
//

import UIKit

class DocumentsTableViewCell: UITableViewCell {

    @IBOutlet weak var view_imgProfile: UIView!
    @IBOutlet weak var img_profile: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
  
    @IBOutlet weak var lbl_fileNum: UILabel!
    @IBOutlet weak var btn_editPdf: UIButton!
    
    var editCallBack:(() -> ())?
    var deleteCallBack:(() -> ())?
    var renameCallBack:(() -> ())?
//    var CallBack:(Void -> {})?
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.img_profile.applyCornerRadius(10)//applyshadowWithCorner(containerView: view_imgProfile, cornerRadious: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func btnShowMenuOptionClick(_ sender: Any) {
        self.btn_editPdf.showsMenuAsPrimaryAction = true
//        self.btn_editPdf.menu = menu()
    }
    
}
