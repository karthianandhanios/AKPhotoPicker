//
//  AKPhotoViewModel.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 15/11/19.
//  Copyright © 2019 Karthi. All rights reserved.
//

import Foundation
import Photos
import UIKit

struct PhotoData  {
     let id : String
     let imageUrl : String
     let image : Data
     let name : String
}


class PhotosViewModel  {

    var attachmentProperties : [AttachmentProperties] = []
    var currentVisibleRow = 0
    
    var photos:[PHAsset]?{
           didSet {
               populateAttachemnetProperties()
           }
       }
    
    func populateAttachemnetProperties() {
        var attachments : [AttachmentProperties] = []
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        for asset in photos ?? [] {
            manager.requestImageData(for: asset, options: options) { (result, string, orientation, info) -> Void in
                if let data = result,  let image = UIImage(data: data), let filename = string{
                    
                    var fileName = filename
                    if filename.split(separator: ".").first ==  "public" { // default file name in iOS
                        fileName = "IMG_" + Date.generateCurrentTimeStamp() + "_fcon.jpeg"
                    }
                    
                    if  string?.lowercased().isEndWithGif() ?? false{
                        let property =  AttachmentProperties(fileName:fileName, fileSize: Float(data.count), image: image, fileData: data)
                        attachments.append(property)
                    }else{
                        if let data = image.jpegData(compressionQuality: 0.1) {
                            let localData = Data(referencing: data as NSData)
                            let property =  AttachmentProperties(fileName:fileName, fileSize: Float(localData.count), image: image, fileData: localData)
                            attachments.append(property)
                        }
                    }
                }
            }
        }
        attachmentProperties = attachments
    }
    
    func addAttachementProperties(properties : AttachmentProperties)  {
        attachmentProperties.append(properties)
    }
    
    
    func removeAssetAtIndex(index : Int)  {
        photos?.remove(at: index)
    }
    
    func removepropertyAtIndex(index : Int)  {
        attachmentProperties.remove(at: index)
    }
    
    func resetAttachmentProperies()  {
        attachmentProperties = []
    }
}

