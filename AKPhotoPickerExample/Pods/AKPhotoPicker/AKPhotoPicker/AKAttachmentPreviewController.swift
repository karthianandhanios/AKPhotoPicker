//
//  AKAttachmentPreviewController.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 16/12/19.
//  Copyright © 2019 Karthi. All rights reserved.
//

import Foundation
import UIKit
import Photos


enum MediaType {
    case photo
    case camara
}

public struct AttachmentProperties {
    var fileName : String
    var fileSize : Float
    var image : UIImage
    var fileData : Data
}

protocol AKSendAttachemntProtocal : class {
    func cancelAttachementSend()
    func sendAttachemnets(properties : [AttachmentProperties])
    func addMoreAttachmentWith(assets : [PHAsset])
    func addMorePhotosFromCamara()
}

class  AKAttachmentPreviewController : UIViewController {
    var  photoModel = PhotosViewModel()
    var pageViewController : UIPageViewController?
    
    @IBOutlet weak var attachmentListCollectionView: UICollectionView!
    
    @IBOutlet weak var attachmentBtn: UIButton!
    @IBOutlet weak var sendAttachmentBtn: UIButton!
    let leftTitlelabel = UILabel()
    let maxAttachemntAllowed = 10
    weak var attachmentDelegate : AKSendAttachemntProtocal?
    var mediaType : MediaType = .photo{
        didSet{
            updatePictureIcon()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPageViewController()
        collectionViewSetup()
        setupUI()
        updatePictureIcon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func reloadImagesInPreviewAndList()  {
        if self.attachmentListCollectionView != nil {
            handleMoreAttachemnt(updatePreviewer: true)
            self.attachmentListCollectionView.reloadData()
        }
    }
    
    func handleMoreAttachemnt(updatePreviewer : Bool =  false)  {
        let canEnable = (mediaType == .photo && photoModel.photos?.count ?? 0 < 10) ||  (mediaType == .camara && photoModel.attachmentProperties.count < 10)
        
        if canEnable {
            attachmentBtn.alpha = 1.0
        }else{
            attachmentBtn.alpha = 0.4
        }
        
        if updatePreviewer {
            let index =  photoModel.currentVisibleRow < photoModel.attachmentProperties.count ? photoModel.currentVisibleRow : photoModel.attachmentProperties.count - 1
            
            presentViewController(at: index)
        }
    }
    
    func updatePictureIcon() {
        var attachmentTitle = "Add photos"
        if attachmentBtn != nil {
            var imageName = "add_picture"
            if mediaType == .photo {
                imageName = "add_picture"
                attachmentTitle = Attachements.addMorePhoto
            }else{
                imageName = "add_photo"
                attachmentTitle = Attachements.takePhoto
            }
            attachmentBtn.setTitle(attachmentTitle, for: .normal)
            let image = UIImage.init(named: imageName, in: AKUtility.bundle, compatibleWith: nil)
            attachmentBtn.setImage(image, for: .normal)
        }
    }
    
    func setUpPageViewController()  {
        pageViewController = AKUtility.storyBoard.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        pageViewController?.dataSource = self
        pageViewController?.delegate = self
        let frame = self.view.bounds
        var bottomPadding : CGFloat = 0
        if #available(iOS 11.0, *) {
             bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        
        let top : CGFloat = 44 + 48
        let bottom : CGFloat = 106 + 14 + 15 + 48 + bottomPadding
        let hight = frame.height - (top + bottom)
    
        pageViewController?.view.frame = CGRect.init(x : 0, y: top, width: frame.width, height:hight)
        if let pageViewController = pageViewController {
            self.addChild(pageViewController)
            self.view.addSubview(pageViewController.view)
            self.pageViewController?.didMove(toParent: self)
        }
        presentViewController(at: 0)
    }
    
    func collectionViewSetup() {
        attachmentListCollectionView.delegate = self
        attachmentListCollectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.attachmentListCollectionView.collectionViewLayout = layout
        attachmentListCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
   
    func setupUI()  {
        
         setupNavigationItems()
        let image1 = UIImage.init(named: "Send Icon", in: AKUtility.bundle, compatibleWith: nil)
        let image = image1?.withRenderingMode(.alwaysTemplate)
        sendAttachmentBtn.setImage(image, for: .normal)
        sendAttachmentBtn.tintColor = UIColor.white
        
        sendAttachmentBtn.backgroundColor = UIColor.blue
        sendAttachmentBtn.layer.cornerRadius = sendAttachmentBtn.frame.width/2
    }
    
    func setupNavigationItems()  {
        
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Close" , style: UIBarButtonItem.Style.done, target: self, action: #selector(closeTapped))
        self.navigationItem.rightBarButtonItem = doneButton
        
        leftTitlelabel.textColor = UIColor.black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftTitlelabel)
    }
    
    @objc func closeTapped()  {
        photoModel.resetAttachmentProperies()
        attachmentListCollectionView.reloadData()
        attachmentDelegate?.cancelAttachementSend()
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateTitle()  {
          let attachementText = photoModel.attachmentProperties.count > 1 ? Attachements.Attachements : Attachements.Attachement
        leftTitlelabel.text = attachementText + " (\(photoModel.attachmentProperties.count))"
    }
    
    func presentViewController(at index : Int)  {
        
        guard let viewControllers = [viewControllerAtIndex(index: index)] as? [UIViewController] else {
            return
        }
        if pageViewController?.viewControllers?.count ?? 0 > 0 , let pageviewcontroller  =  pageViewController?.viewControllers?[0] as? PageContentViewController, pageviewcontroller.pageIndex ?? 0 > index {
            pageViewController?.setViewControllers(viewControllers, direction: .reverse, animated: true, completion: { _ in})
        }else{
            pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: true, completion: { _ in})
        }
        
        updateCurrentSelectedCell(row: index)
    }
    
    
    @IBAction func sendBtnClicked(_ sender: Any) {
        
        attachmentDelegate?.sendAttachemnets(properties: photoModel.attachmentProperties)
         self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addAttachmentClicked(_ sender: Any) {
        if mediaType == .photo {
            if photoModel.photos?.count ?? 0 >= maxAttachemntAllowed {
                showMaximumSelectedAlert()
                return
            }
            attachmentDelegate?.addMoreAttachmentWith(assets: photoModel.photos ?? [])
        }else if mediaType == .camara {
            if photoModel.attachmentProperties.count  >= maxAttachemntAllowed {
                showMaximumSelectedAlert()
                return
            }
            attachmentDelegate?.addMorePhotosFromCamara()
        }
    }
    
    func showMaximumSelectedAlert()  {
//        Alerts.showAlertView(with: Alerts.AlertMessage(title: Attachements.maximumPhotosError, message: "", done:CommonText.ok), controller: self)
    }
    
    deinit {
        print("deinit is getting called AKAttachmentPreviewController")
    }
}

extension AKAttachmentPreviewController :  UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let pageviewcontroller  = viewController as? PageContentViewController else {
            return nil
        }
        
        if var index = pageviewcontroller.pageIndex, index > 0 {
            index = index - 1
            return viewControllerAtIndex(index: index)
        }
        return nil
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageviewcontroller  = viewController as? PageContentViewController else {
            return nil
        }
        if var index = pageviewcontroller.pageIndex, index < photoModel.attachmentProperties.count  {
            index = index + 1
            return viewControllerAtIndex(index: index)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished,pageViewController.viewControllers?.count ?? 0 > 0 , let contentController = pageViewController.viewControllers?[0] as? PageContentViewController,let index = contentController.pageIndex {
            updateCurrentSelectedCell(row: index)
        }
        
    }
    
    func viewControllerAtIndex(index : Int) -> PageContentViewController? {
        if index >= 0 && index < photoModel.attachmentProperties.count  {
            
            let pageContentController = AKUtility.storyBoard.instantiateViewController(withIdentifier: "PageContentController") as! PageContentViewController
            pageContentController.attachmentProperties = photoModel.attachmentProperties[index]
            pageContentController.pageIndex = index
            return pageContentController
        }
        return nil
    }
    
}


extension AKAttachmentPreviewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModel.attachmentProperties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == attachmentListCollectionView {
            if  let collectionViewCell = attachmentListCollectionView.dequeueReusableCell(withReuseIdentifier: "AKPhotoListCell", for: indexPath) as? AKPhotoListCell {
                collectionViewCell.delegate = self
                let image = photoModel.attachmentProperties[indexPath.row].image
                collectionViewCell.previewImageView.image = image
                
                collectionViewCell.showAndHideBorder(show: indexPath.row == photoModel.currentVisibleRow )
                return collectionViewCell
            }
        }
        
        return UICollectionViewCell.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == attachmentListCollectionView{
            return CGSize(width: 100, height: 100)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == attachmentListCollectionView, photoModel.currentVisibleRow != indexPath.row {
            presentViewController(at: indexPath.row)
        }
    }
    
    func updateCurrentSelectedCell(row : Int)  {
        
        let previousCell = attachmentListCollectionView.cellForItem(at: IndexPath.init(row: photoModel.currentVisibleRow, section: 0)) as? AKPhotoListCell
        previousCell?.showAndHideBorder(show: false)
        
        if  attachmentListCollectionView.numberOfItems(inSection: 0) > row {
             attachmentListCollectionView.scrollToItem(at: IndexPath.init(row: row, section: 0), at: .right, animated: true)
        }
    
        let cell = attachmentListCollectionView.cellForItem(at: IndexPath.init(row: row, section: 0)) as? AKPhotoListCell
        cell?.showAndHideBorder(show: true)
        photoModel.currentVisibleRow = row
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let cell = attachmentListCollectionView.cellForItem(at: IndexPath.init(row: photoModel.currentVisibleRow, section: 0)) as? AKPhotoListCell
        cell?.showAndHideBorder(show: true)
    }
    
}

extension AKAttachmentPreviewController : PhotoListCellProtocal{
    func removeItem(item: AKPhotoListCell) {
        if  let index = self.attachmentListCollectionView.indexPath(for: item)?.row{
            
            if mediaType == .camara {
                photoModel.removepropertyAtIndex(index: index)
            }else{
                photoModel.removeAssetAtIndex(index: index)
            }
            
            if photoModel.attachmentProperties.count == 0 {
                attachmentDelegate?.cancelAttachementSend()
                self.navigationController?.popViewController(animated: true)
            }
            
            if index == photoModel.currentVisibleRow {
                var row = photoModel.currentVisibleRow
                if row >= photoModel.attachmentProperties.count {
                    row = photoModel.currentVisibleRow - 1
                }
                presentViewController(at: row)
            }else if index < photoModel.currentVisibleRow  {
                photoModel.currentVisibleRow = photoModel.currentVisibleRow - 1  >= 0 ? photoModel.currentVisibleRow - 1 : 0
            }
            updateTitle()
            handleMoreAttachemnt()
            self.attachmentListCollectionView.reloadData()
        }
        
    }
}

