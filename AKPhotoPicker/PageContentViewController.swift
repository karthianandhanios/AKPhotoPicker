//
//  PageContentViewController.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 16/12/19.
//  Copyright © 2019 Karthi. All rights reserved.
//

import Foundation
import UIKit


class  PageContentViewController : UIViewController  {
    @IBOutlet weak var previewImageView: UIImageView!
    
    var  pageIndex : Int?
    var  imageName : String?
    
    var attachmentProperties : AttachmentProperties? {
        didSet{
            setImageForPreview()
        }
    }
    
    func setImageForPreview()  {
        if previewImageView != nil, let image = attachmentProperties?.image {
            previewImageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageForPreview()
    }
    
}
