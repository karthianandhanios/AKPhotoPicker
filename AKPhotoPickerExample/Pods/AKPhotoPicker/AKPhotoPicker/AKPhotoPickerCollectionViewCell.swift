//
//  AKPhotoPickerCollectionViewCell.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 17/12/19.
//  Copyright © 2019 Karthi. All rights reserved.
//

import Foundation
import Photos
import UIKit

class AKPhotoPickerCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectedBgView: UIView!
    static let scale: CGFloat = 3
    var photoAsset: PHAsset? {
        didSet {
            photoImageView.loadPhotoAssetIfNeeded(photoAsset: photoAsset, size: size, contentMode: .aspectFill)
        }
    }
    
    var size: CGSize? {
        didSet {
            photoImageView.loadPhotoAssetIfNeeded(photoAsset: photoAsset, size: size, contentMode: .aspectFill)
        }
    }
    
    var photoSelected : Bool?{
        didSet{
            if photoSelected ?? false {                selectedBgView.superview?.bringSubviewToFront(selectedBgView)
            }
            selectedBgView.isHidden = !(photoSelected ?? false)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
         selectedBgView.alpha = 0.7
        selectedBgView.backgroundColor = UIColor.black
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoSelected = false
    }
}


extension UIImageView {
    func loadPhotoAssetIfNeeded(photoAsset : PHAsset?, size : CGSize?,contentMode : PHImageContentMode) {
        guard let asset = photoAsset, let size = size else { return }
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        let newSize = CGSize(width: size.width * 3,
                             height: size.height * 3)
        
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: newSize, contentMode: contentMode, options: options, resultHandler: { [weak self] (result, _) in
            DispatchQueue.main.async {
                self?.image = result
                self?.layoutIfNeeded()
            }
        })
    }
}

