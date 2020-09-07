//
//  AKPhotoPicker.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 14/02/20.
//  Copyright © 2020 Karthi. All rights reserved.
//

import Foundation
import Photos
import UIKit

public enum PicketType {
    case photo
    case camara
}

public protocol FCAddAttachementHandlerDelegate : class {
    func selectedImageInfo(properties : [AttachmentProperties])
    func cancelSendAttachemnts()
}

public class AkPhotoPicker : NSObject{
    
    public var picketType : PicketType
    private  var picker: UIImagePickerController?
    private var presenter : UINavigationController
    private var photoPreviewer : AKAttachmentPreviewController?
    private weak var photoPicker : AKPhotoPickerViewController?
    weak var delegate : FCAddAttachementHandlerDelegate?
    
   public required init(type : PicketType, viewController : UINavigationController, delegate : FCAddAttachementHandlerDelegate) {
        self.picketType = type
        presenter = viewController
        self.delegate =  delegate
    }
    
    public func showPicker() {
        switch picketType {
        case .photo:
            PickerAuthorization.getPhotoPermission { success in
                DispatchQueue.main.async {
                    if success {
                        self.presentPhotoPicker()
                    }else{
                        self.showAlertViewController(messsage : "Message")
                    }
                }
            }
        case .camara:
            PickerAuthorization.checkCamera { success in
                DispatchQueue.main.async {
                    if success {
                        self.openCamara()
                    }else{
                        self.showAlertViewController(messsage : "Message")
                    }
                }
            }
        }
    }
    
   private func showAlertViewController(messsage : String)  {
         print("Access to the photo is restricted, please go to settings and enable it")
    }
}

extension AkPhotoPicker : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    private func openCamara(addMore : Bool = false){
            if picker ==  nil{
                picker = UIImagePickerController()
                picker?.delegate = self
            }
             
           if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
               picker!.allowsEditing = false
               picker!.sourceType = UIImagePickerController.SourceType.camera
               picker!.cameraCaptureMode = .photo
               
               guard let camaraPicker =  picker else {
                   return
               }
            if addMore {
                photoPreviewer?.present(camaraPicker, animated: true, completion: nil)
            }else{
                presenter.present(camaraPicker, animated: true, completion: nil)
            }
           }
       }

    

   // ImagePicker Delegates
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          if photoPreviewer?.photoModel.attachmentProperties.count ?? 0  > 0 {
              showImagePreview( mediaType: .camara)
          }
           picker.dismiss(animated: true, completion: nil)
      }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if(picker.sourceType == .camera){
            
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            addtoPreviewProperties(image: image,fileName: "IMG_" + Date.generateCurrentTimeStamp() + "_fcon.jpeg")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func addtoPreviewProperties(image : UIImage, fileName : String){
           
        if let data = image.jpegData(compressionQuality: 0.1) {
               let localData = Data(referencing: data as NSData)
               let property =  AttachmentProperties(fileName:fileName, fileSize: Float(localData.count), image: image, fileData: localData)
               showImagePreview(attachmentProperty: property, mediaType: .camara)
               
           }
       }
    
}


extension AkPhotoPicker {
    
    func showImagePreview(assets: [PHAsset]? = nil, attachmentProperty : AttachmentProperties? = nil, mediaType : MediaType)  {
        
        if photoPreviewer == nil{
            photoPreviewer = AKUtility.storyBoard.instantiateViewController(withIdentifier: "AKAttachmentPreviewController") as? AKAttachmentPreviewController
            photoPreviewer?.attachmentDelegate = self
        }
        photoPreviewer?.mediaType = mediaType
        if let assets = assets {
            photoPreviewer?.photoModel.photos = assets
        }else if let attachmentProperty = attachmentProperty {
            photoPreviewer?.photoModel.addAttachementProperties(properties: attachmentProperty)
        }
        photoPreviewer?.updateTitle()
        
        guard let photoPreviewer = photoPreviewer else {
            return
        }
        if  self.presenter.topViewController != photoPreviewer {
            self.presenter.pushViewController(photoPreviewer, animated: true)
            photoPreviewer.reloadImagesInPreviewAndList()
        }else{
            photoPreviewer.reloadImagesInPreviewAndList()
        }
    }
}

extension AkPhotoPicker {
    
    func presentPhotoPicker(selectedAssets: [PHAsset]? =  nil, addMore : Bool = false)   {
        if photoPicker == nil {
            photoPicker = AKUtility.storyBoard.instantiateViewController(withIdentifier: "AKPhotoPickerViewController") as? AKPhotoPickerViewController
            photoPicker?.delegate = self
            photoPicker?.allowedMediaTypes = [PHAssetMediaType.image]
            photoPicker?.maximumSelectionsAllowed = 10
        }
        if let selectedAssets = selectedAssets {
            photoPicker?.selectedAssets = selectedAssets
        }
        guard let photoPicker = photoPicker else {
            return
        }
        if addMore {
            let pickerNavi = UINavigationController(rootViewController: photoPicker)
            photoPreviewer?.present(pickerNavi, animated: true, completion: nil)
        }else {
            let pickerNavi = UINavigationController(rootViewController: photoPicker)
            presenter.present(pickerNavi, animated: true, completion: nil)
        }
    }
}

extension AkPhotoPicker : PickerControllerDelegate {
    
    public func imagePicker(didFinishPickingAssets assets: [PHAsset]) {
        if assets.count > 0 {
            showImagePreview(assets: assets, mediaType: .photo)
        }
        photoPicker?.dismiss(animated: true, completion: nil)
    }
    
    public func cancelPhotoPickAction(cancelAll : Bool) {
        
        if  photoPreviewer?.photoModel.photos?.count ?? 0 > 0 && !cancelAll{
            photoPicker?.dismiss(animated: true, completion: nil)
            showImagePreview(mediaType: .photo)
        }
        if cancelAll {
            photoPreviewer?.navigationController?.popViewController(animated: true)
            photoPicker?.dismiss(animated: false, completion: nil)
        }
    }
}

extension AkPhotoPicker :  AKSendAttachemntProtocal {
    
    func cancelAttachementSend() {
        delegate?.cancelSendAttachemnts()
    }
    
    func sendAttachemnets(properties : [AttachmentProperties]) {
        delegate?.selectedImageInfo(properties: properties)
    }
    
    func addMoreAttachmentWith(assets: [PHAsset]) {
        presentPhotoPicker(selectedAssets: assets, addMore: true)
    }
    func addMorePhotosFromCamara() {
        openCamara(addMore: true)
    }
    
}


fileprivate class PickerAuthorization  {
    
   class func getPhotoPermission(completion : @escaping (Bool)->Void)  {
        let permission = PHPhotoLibrary.authorizationStatus()
        if permission == .authorized {
            completion(true)
        } else if permission == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                   completion(true)
                }
            })
        } else if permission == .denied {
            completion(false)
        }
    }
    
   class func checkCamera(completion : @escaping (Bool)->Void) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
        case .notDetermined: AVCaptureDevice.requestAccess(for: AVMediaType.video) { status in
            if status == true {
                DispatchQueue.main.async {
                    completion(true)
                }
            }
            }
        case .denied:
            DispatchQueue.main.async {
                completion(false)
            }
        default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
}
