//
//  AKPhotoPreviewCell.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 16/11/19.
//  Copyright © 2019 Karthi. All rights reserved.
//

import Foundation
import UIKit

class AKPhotoPreviewCell : UICollectionViewCell {
    
    @IBOutlet weak var previewImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
         self.previewImageView.clipsToBounds = true
        self.contentView.clipsToBounds = true
//        self.previewImageView.layer.cornerRadius = 25.0
        self.previewImageView.roundCorners(corners: [.topRight,.topLeft ], radius: 25.0)
    }
}


extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topRight,.topLeft ], cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
