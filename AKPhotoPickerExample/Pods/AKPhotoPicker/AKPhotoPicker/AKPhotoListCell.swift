//
//  AKPhotoListCell.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 23/11/19.
//  Copyright © 2019 Karthi. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol  PhotoListCellProtocal {
    func removeItem(item : AKPhotoListCell)
}

class AKPhotoListCell : UICollectionViewCell {
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var removeImageButton: UIButton!
    @IBOutlet weak var selectedIndicatorView: UIView!
    
    var showBorder : Bool = false
    var delegate : PhotoListCellProtocal?
    
    @IBAction func removeImageBtnClicked(_ sender: Any) {
        delegate?.removeItem(item: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        previewImageView.layer.cornerRadius = 3
        selectedIndicatorView.backgroundColor = UIColor.blue
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedIndicatorView.isHidden =  true
    }
    func showAndHideBorder(show : Bool)  {
        showBorder = show
        selectedIndicatorView.isHidden = !show
    }
}
