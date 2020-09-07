//
//  ClientViewController.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 14/02/20.
//  Copyright © 2020 Karthi. All rights reserved.
//

import UIKit
import AKPhotoPicker

class ClientViewController: UIViewController {

    var picker : AkPhotoPicker?
    @IBAction func openFromPhotosClicked(_ sender: Any) {
        showPicker(type: .photo)
    }
    
    @IBAction func openFromCamaraClicked(_ sender: Any) {
        showPicker(type: .camara)
    }
    
    func showPicker(type : PicketType)  {
        if picker == nil
        {
            picker  = AkPhotoPicker.init(type: type, viewController: self.navigationController!, delegate: self)
        }else{
            picker?.picketType = type
        }
        picker?.showPicker()
    }
}

extension ClientViewController : AKAddAttachementHandlerDelegate {
    func selectedImageInfo(properties: [AttachmentProperties]) {
        print("selected image info", properties)
    }
    
    func cancelSendAttachemnts() {
         print("cancelSendAttachemnts")
    }
}
