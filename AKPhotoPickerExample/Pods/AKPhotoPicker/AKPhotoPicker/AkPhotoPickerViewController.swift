//
//  AKPhotoPickerViewController.swift
//  AKPhotoLibrary
//
//  Created by Karthi Anandhan on 17/12/19.
//  Copyright © 2019 Karthi. All rights reserved.
//

import Foundation
import Photos
import UIKit

public protocol PickerControllerDelegate : class {
    func cancelPhotoPickAction(cancelAll : Bool)
    func imagePicker(didFinishPickingAssets assets: [PHAsset])
}

public class  AKPhotoPickerViewController : UICollectionViewController {
    
    /// Allowed Media Types that can be fetched. See `PHAssetMediaType`
    open var allowedMediaTypes: Set<PHAssetMediaType>? {
        didSet {
            updateFetchOptionPredicate()
        }
    }
    
    /// Allowed MediaSubtype that can be fetched. Can be applied as `OptionSet`. See `PHAssetMediaSubtype`
    open var allowedMediaSubtypes: PHAssetMediaSubtype? {
        didSet {
            updateFetchOptionPredicate()
        }
    }
    
    /// Maximum photo selections allowed in picker (zero or fewer means unlimited).
    open var maximumSelectionsAllowed: Int = -1
    var photoAssets: PHFetchResult<PHAsset> = PHFetchResult()
    private var selectedIndexPaths: [IndexPath] = []
    
    var selectedAssets : [PHAsset] = []
    
    let deselectButton = UIButton.init(type: .custom)
    let doneButton = UIButton.init(type: .custom)
    let leftTitleLabel = UILabel.init()
    
    internal lazy var fetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }()
    
    
    @available(iOS 9.0, *)
    internal var fetchLimit: Int {
        get {
            return fetchOptions.fetchLimit
        }
        set {
            fetchOptions.fetchLimit = newValue
        }
    }
    
    private func fetchPhotos() {
        requestPhotoAccessIfNeeded(PHPhotoLibrary.authorizationStatus())
        updateFetchPhotos()
    }
    
    
    
    private func updateFetchPhotos() {
        photoAssets = PHAsset.fetchAssets(with: fetchOptions)
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
    private func requestPhotoAccessIfNeeded(_ status: PHAuthorizationStatus) {
        guard status == .notDetermined else { return }
        PHPhotoLibrary.requestAuthorization { [weak self] (_) in
            self?.updateFetchPhotos()
        }
    }
    
    weak var delegate: PickerControllerDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDeselectStatus()
    }
    
    func  setupUI(){
        collectionView?.delegate = self
        collectionView?.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        collectionView?.collectionViewLayout = layout
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        setupNavigationItems()
    }
    
    func setupNavigationItems(){
        //left bar button items
        leftTitleLabel.textColor = .black
        leftTitleLabel.textAlignment = .left
        
        leftTitleLabel.frame = CGRect(x: 0.0, y: 0.0, width: 110, height: 20)
        let leftTitleBarBtn = UIBarButtonItem.init(customView: leftTitleLabel)
       
        let image = UIImage.init(named: "Icon_Angle_Left", in: AKUtility.bundle, compatibleWith: nil)
         let backbarbtn = UIBarButtonItem.addLeftBarButton(title: "",image:image, self, action: #selector(backBtnTapped))
        
        self.navigationItem.leftBarButtonItems = [backbarbtn, leftTitleBarBtn]
        
        deselectButton.setTitleColor(UIColor.blue, for: .normal)
        deselectButton.setTitle(NavigationBarTitle.deselectAll, for: .normal)
        deselectButton.addTarget(self, action: #selector(deselectAllTapped), for: .touchUpInside)
        deselectButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        updateDeselectStatus()
        let deselectBarBtn = UIBarButtonItem.init(customView: deselectButton)
        deselectBarBtn.style = .done
        
        doneButton.setTitleColor(UIColor.blue, for: .normal)
        doneButton.setTitle(CommonText.done, for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        let doneBarBtn = UIBarButtonItem.init(customView: doneButton)
        doneBarBtn.style = .done
        
        self.navigationItem.rightBarButtonItems = [doneBarBtn, deselectBarBtn]
    }
    
    @objc func backBtnTapped()  {
        delegate?.cancelPhotoPickAction(cancelAll: !(selectedAssets.count > 0 ))
    }
    
    @objc func doneTapped()  {
        delegate?.imagePicker(didFinishPickingAssets: selectedAssets)
    }
    
    @objc func deselectAllTapped()  {
        selectedAssets = []
        selectedIndexPaths = []
        collectionView?.reloadData()
        updateDeselectStatus()
    }
    
    func updateDeselectStatus()  {
        let isSelected = !(selectedAssets.count > 0)
        deselectButton.isHidden = isSelected
        doneButton.isHidden = isSelected
        updateLeftTitle()
    }
    
    func updateLeftTitle()  {
        if selectedAssets.count > 0 {
            leftTitleLabel.text = "\(NavigationBarTitle.selected)(\(selectedAssets.count))"
        }else{
            leftTitleLabel.text = NavigationBarTitle.gallery
        }
    }
    
    private func updateFetchOptionPredicate() {
        var predicates: [NSPredicate] = []
        if let allowedMediaTypes = self.allowedMediaTypes {
            let mediaTypesPredicates = allowedMediaTypes.map { NSPredicate(format: "mediaType = %d", $0.rawValue) }
            let allowedMediaTypesPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: mediaTypesPredicates)
            predicates += [allowedMediaTypesPredicate]
        }
        
        if let allowedMediaSubtypes = self.allowedMediaSubtypes {
            let mediaSubtypes = NSPredicate(format: "mediaSubtypes = %d", allowedMediaSubtypes.rawValue)
            predicates += [mediaSubtypes]
        }
        
        if predicates.count > 0 {
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchOptions.predicate = predicate
        } else {
            fetchOptions.predicate = nil
        }
        fetchPhotos()
    }
    
    private func updateSelectedImage(isSelected : Bool, indexPath : IndexPath){
        collectionView.reloadItems(at: [indexPath])
    }
    
}

extension AKPhotoPickerViewController : UICollectionViewDelegateFlowLayout  {
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if  let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AKPhotoPickerCollectionViewCell", for: indexPath) as? AKPhotoPickerCollectionViewCell {
            if  let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath){
                let photoAsset = photoAssets.object(at: indexPath.item)
                collectionViewCell.photoAsset = photoAsset
                collectionViewCell.size = layoutAttributes.frame.size
                if selectedAssets.contains(photoAsset){
                    collectionViewCell.photoSelected = true
                }
            }
            
            return collectionViewCell
        }
        return UICollectionViewCell.init()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let photoAsset = photoAssets.object(at: indexPath.item)
        let isAlreadySelected = selectedAssets.contains(photoAsset)
        
        if !isAlreadySelected && selectedAssets.count + 1 > maximumSelectionsAllowed {
            let cell =  collectionView.cellForItem(at: indexPath)
            cell?.contentView.shake()
            //            Alerts.showToastMessage(toastMessage: Alerts.ToastMessage(message: Attachements.maximumPhotosError, position: .middle, showtimeInSeconds:2), controller: self)
            return false
        }
        return true
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoAsset = photoAssets.object(at: indexPath.item)
        
        let isAlreadySelected = selectedAssets.contains(photoAsset)
        if isAlreadySelected{
            
            selectedAssets = selectedAssets.filter { $0 != photoAsset }
        }else{
            selectedAssets += [photoAsset]
        }
        updateSelectedImage(isSelected: !isAlreadySelected, indexPath: indexPath)
        updateDeselectStatus()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width - 6) / 4 , height: 100)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2;
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
}




