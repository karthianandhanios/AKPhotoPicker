//
//  AKUtility.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 16/02/20.
//  Copyright © 2020 Karthi. All rights reserved.
//

import Foundation
import UIKit
import Photos

class AKUtility {
    static var storyBoard : UIStoryboard {
        let storyboard = UIStoryboard (
            name: "AKPhotoPickerMain", bundle: AKUtility.bundle
        )
        return storyboard
    }
    static var bundle : Bundle {
        return Bundle(for: AkPhotoPicker.self)
    }
}


extension Date {
    static func generateCurrentTimeStamp() -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss.SSS"
           return (formatter.string(from: Date()) as NSString) as String
       }
}

extension String {
    func isEndWithGif() -> Bool {
        return self.lowercased().hasSuffix(".gif")
    }
}

extension UIView{
    func shake() {
        self.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}


extension UIBarButtonItem {
    
    class func addLeftBarButton(title:String,imgColor: UIColor = UIColor.blue,image:UIImage? = nil,_ target: Any, action: Selector) -> UIBarButtonItem{
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x:0, y: 0, width: 44, height: 44)
        button.setTitle(title, for: .normal)
        if let image = image {
            button.setImage(image, for: .normal)
        }
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15.0, bottom: 0, right: 13.0)
        button.imageView?.setImageColor(color: imgColor)
        button.addTarget(target, action: action, for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: button)
        return barBtn
    }
    class func addRightBarButton(title:String,titleColor: UIColor = UIColor.blue,image:UIImage,_ target: Any, action: Selector) -> UIBarButtonItem{
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x:0, y: 0, width: 44, height: 44)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left:0, bottom: 0, right: -15)
        button.imageView?.setImageColor(color: UIColor.blue)
        button.addTarget(target, action: action, for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: button)
        return barBtn
    }
    
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

