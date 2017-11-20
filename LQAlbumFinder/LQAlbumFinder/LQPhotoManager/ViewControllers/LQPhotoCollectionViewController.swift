//
//  LQPhotoCollectionViewController.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/8/22.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit
import Photos

enum LQPhotoCollectionStyle {
    case regular, photos, videos
}

private let reuseIdentifier = "LQPhotoCollectionViewControllerReuseIdentifier"
typealias LQPhotoSelectedHandle = (_ items: [LQPhotoItem]) -> Void

extension LQPhotoCollectionViewController {
    
    func didSelectedItems(_ handle: @escaping LQPhotoSelectedHandle) {
        selectedHandle = handle
    }
}

class LQPhotoCollectionViewController: UICollectionViewController {

    var albumItem: LQAlbumItem?
    var photoAlbum: LQAlbumItem?// 相机胶卷
    
    var dataSource: [LQPhotoItem] = []
    var maxSelectedNumber: Int = 9
    var style: LQPhotoCollectionStyle = .regular
    
    fileprivate var selectedItems: [LQPhotoItem] = []
//    fileprivate var isOriginal: Bool = false
    fileprivate var bottomBar: UIView!
    fileprivate var commitButton: UIButton!
    fileprivate lazy var imageManager = {
    
        return PHCachingImageManager()
    }()
    var selectedHandle: LQPhotoSelectedHandle?
    
    fileprivate var previousPreheatRect = CGRect.zero
    fileprivate var previewButton: UIButton!
    fileprivate var originButton: UIButton!
    
    deinit {
        print("LQPhotoCollectionViewController deinit")
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var colFrame = collectionView?.frame
        colFrame?.size.height -= 49
        collectionView?.frame = CGRect(x: 0, y: 0, width: LQAlbumWindowWidth, height: LQAlbumWindowHeight - 49)
        
        bottomBar.frame = CGRect(x: 0, y: LQAlbumWindowHeight - 49, width: LQAlbumWindowWidth, height: 49)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.collectionView!.register(LQPhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(LQPhotoCameraCell.self, forCellWithReuseIdentifier: "LQPhotoCameraCellID")
        
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.bounces = true
        self.title = "相册"
        LQLog("begin")
        if self.albumItem == nil {
            
            LQAlbumManager.authotization { (isAuth) in
                if isAuth {
                    
                    DispatchQueue(label: "LQPhotoCollectionViewControllerQueue").async {
                        self.loadData()
                    }
                } else {
                    self.noneAuthodAlert("无权访问您的相册")
                }
            }
        } else {
//            self.title = self.albumItem?.name
            
            DispatchQueue(label: "LQPhotoCollectionViewControllerQueue").async {
                
                self.loadData()
            }
        }
        LQLog("end")
        self.setupNavBar()
        layoutBottomView()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    private func loadData() {
        LQLog("start")
        if dataSource.count >= 0 {
            dataSource.removeAll()
        }
        
        // 过滤出相册库
        if photoAlbum == nil {
            let albums = LQAlbumManager.shared.fetchAlbums()
            for am in albums {
                if am.name == "相机胶卷" {
                    self.photoAlbum = am
                    break
                }
            }
        }
        
        var title = "相册"
        
        if  style == .photos  {
            let items = LQAlbumManager.shared.fetchAllPhotos()
            dataSource += items
        } else if style == .videos {
            let items = LQAlbumManager.shared.fetchAllVideos()
            dataSource += items
            title = "视频"
        } else {
            if self.albumItem == nil {
                let albums = LQAlbumManager.shared.fetchAlbums()
                for am in albums {
                    if am.name == "相机胶卷" {
                        self.albumItem = am
                        break
                    }
                }
            }
            
            title = (self.albumItem?.name)!
            let results = LQAlbumManager.shared.fetchAssetsFrom(albumItem!)
            dataSource += results
        }
        
        DispatchQueue.main.async {
//            if let am = self.albumItem {
//                self.title = am.name
//            }
            if self.dataSource.count > 0 {
                
                self.title = title
                self.collectionView?.reloadData()
                let index = IndexPath(item: self.dataSource.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: index, at: .bottom, animated: false)
                self.resetCachedAssets()
            }
        }
    }
    
    convenience init() {
        
        let space: CGFloat = 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (LQAlbumWindowWidth - space * 5)/4.0, height: (LQAlbumWindowWidth - space * 5)/4.0)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.sectionInset = UIEdgeInsetsMake(space, space, space, space)
        self.init(collectionViewLayout: layout)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupNavBar() {
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("取消", for: .normal)
        //        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.frame = CGRect(x: self.view.frame.width - 60, y: 20, width: 50, height: 44)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        if style == .regular {
            let backBtn = UIButton(type: .custom)
            backBtn.setTitle("返回", for: .normal)
            backBtn.setImage(UIImage.init(named: "previewTopBar_back"), for: .normal)
            backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            backBtn.setTitleColor(UIColor.white, for: .normal)
            backBtn.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
            backBtn.frame = CGRect(x: 0, y: 0, width: 54, height: 44)
            
            let leftBar = UIBarButtonItem(customView: backBtn)
            self.navigationItem.leftBarButtonItem = leftBar
        } else {
            
            let leftBar = UIBarButtonItem(customView: UIView())
            self.navigationItem.leftBarButtonItem = leftBar
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
        
    }
    
    @objc private func cancelButtonAction() {
        
        if self.presentationController != nil {
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc private func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dataSource.count > 0 {
            return dataSource.count
            // 显示拍摄按钮
//            return dataSource.count + 1
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == dataSource.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LQPhotoCameraCellID", for: indexPath)
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LQPhotoCollectionViewCell
    
        let item = dataSource[indexPath.row]
        item.indexPath = indexPath
        cell.configData(item)
        
        cell.selectedHandle {[weak self] (isSelected) in
            self?.selectedItem(isSelected, indexPath: indexPath)
        }
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard indexPath.row < dataSource.count else {
            self.cameraAction()
            return
        }
        
        let item = dataSource[indexPath.row]
        if item.isSelected == false && selectedItems.count == maxSelectedNumber {
            return
        }
        
        let preview = LQPhotoPreviewController()
        preview.dataSource += self.dataSource
        preview.selectedItems += self.selectedItems
        preview.beginIndexPath = IndexPath(item: 0, section: indexPath.row)
        preview.maxSelectedNumber = maxSelectedNumber
        
        self.navigationController?.pushViewController(preview, animated: true)
        
        preview.indexPathChangedHandle {[weak self] (indePath) in
            
            let index = IndexPath(item: indexPath.section, section: 0)
            
            self?.collectionView?.scrollToItem(at: index, at: .centeredVertically, animated: false)
        }
        
        preview.selectedIndexPath {[weak self] (indexPath, isSelected, isOriginal) in
            
            let index = IndexPath(item: indexPath.section, section: 0)
            self?.originButton.isSelected = isOriginal
            self?.selectedItem(isSelected, indexPath: index)
        }
        
        preview.didSelectedItems { (items) in
            if let handle = self.selectedHandle {
                handle(items)
            }
        }
        
    }

    fileprivate func selectedItem(_ isSelected: Bool, indexPath: IndexPath) {
        
        if selectedItems.count == maxSelectedNumber && isSelected {
           
            let alert = UIAlertController(title: "您最多只能选择\(maxSelectedNumber)张照片!", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "我知道了", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            collectionView?.reloadItems(at: [indexPath])
            return
        }
        
        let item = dataSource[indexPath.row]
        item.isSelected = isSelected
        item.isOriginal = originButton.isSelected
        if isSelected {
            
            item.selectedNumber = selectedItems.count + 1
            selectedItems.append(item)
        } else {
            
            let index = selectedItems.index(of: item)
            
            if let ix = index {
                selectedItems.remove(at: ix)
            }
            
            for i in 0..<selectedItems.count {
                let im = selectedItems[i]
                im.selectedNumber = i + 1
                selectedItems[i] = im
                
                let index = dataSource.index(of: im)
                dataSource[index!] = im
            }
        }
        
        dataSource[indexPath.row] = item
        var selectedEnable = true
        
        if selectedItems.count == 9 {
            selectedEnable = false
        }
        
        for i in 0..<dataSource.count {
            let im = dataSource[i]
            if im.isSelected == false {
                im.isSelectedEnable = selectedEnable
                dataSource[i] = im
            }
        }
        
        let visibleRect = CGRect(origin: (collectionView?.contentOffset)!, size: (collectionView?.bounds.size)!)
        let indexPathes = self.indexPathsForElements(in: visibleRect)
        collectionView?.reloadItems(at: indexPathes)
        
        setBottomViewState()
    }
    
    func noneAuthodAlert(_ title: String) {
        
        // 无授权界面
        let alert = UIAlertController(title: title, message: "是否去设置中添加访问权限?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "去设置", style: .default, handler: { (action) in
            
            let url = URL(string: UIApplicationOpenSettingsURLString)
            if UIApplication.shared.canOpenURL(url!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url!)
                }
            }
        })
        
        let cancel = UIAlertAction(title: "暂不设置", style: .cancel, handler: { (action) in
            if title == "无权访问您的相册" {
                self.cancelButtonAction()
            }
        })
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    override var shouldAutorotate: Bool {
        return false
    }
}

extension LQPhotoCollectionViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    //
    fileprivate func updateCachedAssets() {
        // 只更新可见区域内的视图
        guard isViewLoaded && view.window != nil else { return }
        
        // 预见区高度为可见区高度的2倍
        let visibleRect = CGRect(origin: (collectionView?.contentOffset)!, size: (collectionView?.bounds.size)!)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // 可见区与最后的预见区有明显差异再更新（减少更新频率）
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // 计算缓存起点和终点
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        
        let addedIndexPaths = addedRects.flatMap { rect in indexPathsForElements(in: rect) }
        
        var addedAssets = [PHAsset]()
        
        for indexPath in addedIndexPaths {
            if indexPath.row != 0 {
                addedAssets.append(dataSource[indexPath.row-1].asset)
            }
        }
        
        let removedIndexPaths = removedRects.flatMap { rect in indexPathsForElements(in: rect) }
        var removedAssets = [PHAsset]()
        for indexPath in removedIndexPaths {
            if indexPath.row != 0 {
                removedAssets.append(dataSource[indexPath.row-1].asset)
            }
        }
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let size = layout.itemSize
        
        // 更新PHCachingImageManager正在缓存的assets.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: size,
                                        contentMode: .aspectFill,
                                        options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: size,
                                       contentMode: .aspectFill,
                                       options: nil)
        
        // 存储最后的预见区
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    // 获取区域内所有IndexPath
    fileprivate func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

//MARK: - Bottom Tool Bar
extension LQPhotoCollectionViewController {
    
    fileprivate func layoutBottomView() {
        
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: LQAlbumWindowHeight - 49, width: LQAlbumWindowWidth, height: 49)
        bottomView.backgroundColor = UIColor.white
        self.view.addSubview(bottomView)
        bottomBar = bottomView
        
        let bgView = UIView()
        bgView.frame = bottomView.bounds
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.8
        bottomView.addSubview(bgView)
        
        previewButton = UIButton(type: .custom)
        previewButton.frame = CGRect(x: 10, y: 0, width: 50, height: 49)
        previewButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        previewButton.setTitle("预览", for: .normal)
        previewButton.isEnabled = false
        previewButton.addTarget(self, action: #selector(previewSelectedItemAction), for: .touchUpInside)
        bottomView.addSubview(previewButton)
        
        let originBtn = UIButton(type: .custom)
        originBtn.bounds = CGRect(x: 0, y: 0, width: 100, height: 30)
        
        originBtn.center = CGPoint(x: bottomView.frame.width/2.0, y: bottomView.frame.height/2.0)
        originBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        originBtn.setTitle("原图", for: .normal)
        originBtn.setImage(UIImage.init(named: "unSelectedBG"), for: .normal)
        originBtn.setImage(UIImage.init(named: "selectedBG"), for: .selected)
        originBtn.addTarget(self, action: #selector(originButtonAction), for: .touchUpInside)
        bottomView.addSubview(originBtn)
        originButton = originBtn
        
        let sendBtn = UIButton(type: .custom)
        sendBtn.frame = CGRect(x: bottomView.frame.width - 70, y: 4, width: 60, height: 41)
        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sendBtn.setTitle("确定", for: .normal)
        sendBtn.setBackgroundImage(UIImage.init(named: "green_btnBG"), for: .normal)
        sendBtn.isEnabled = false
        sendBtn.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        bottomView.addSubview(sendBtn)
        commitButton = sendBtn
    }
    
    @objc private func previewSelectedItemAction() {
        let preview = LQPhotoPreviewController()
        preview.selectedItems += selectedItems
        preview.dataSource += selectedItems
        preview.isPreview = true

        self.navigationController?.pushViewController(preview, animated: true)
        
        preview.selectedIndexPath {[weak self] (indexPath, isSelected, isOriginal) in
            self?.originButton.isSelected = isOriginal
            if isOriginal == false {
                
            } else {
                let index = IndexPath(item: indexPath.section, section: 0)
                
                self?.selectedItem(isSelected, indexPath: index)
            }
            
        }
    }
    
    @objc private func originButtonAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        
        for item in selectedItems {
            item.isOriginal =  button.isSelected
        }
    }
    
    @objc private func sendButtonAction() {
        if let handle = selectedHandle {
            handle(selectedItems)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setBottomViewState() {
        if selectedItems.count > 0 {
            commitButton.setTitle("确定(\(selectedItems.count))", for: .normal)
            previewButton.isEnabled = true
            commitButton.isEnabled = true
        } else {
           commitButton.setTitle("确定", for: .normal)
            previewButton.isEnabled = false
            commitButton.isEnabled = false
        }
    }
}

extension LQPhotoCollectionViewController:PHPhotoLibraryChangeObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func cameraAction() {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == .denied || status == .restricted {
            self.noneAuthodAlert("无权访问您的相机")
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                
//                picker.showsCameraControls = false
//                picker.cameraViewTransform = CGAffineTransform.init(scaleX: 1.5, y: 2.0)
                present(picker,animated: true,completion: nil)
            } else {
                print("不支持相机")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            
            return
        }
        
        let appInfo = Bundle.main.infoDictionary
        if let appName = appInfo?["CFBundleDisplayName"] as? String {
            if let album = LQAlbumManager.shared.fetchAlbum(appName) {
                LQAlbumManager.shared.savePhoto(image, to: album.assetCollection)
            } else {
                LQAlbumManager.shared.newAlbum(appName, resultHandle: { (success, error) in
                    if success {
                        if let album = LQAlbumManager.shared.fetchAlbum(appName) {
                            LQAlbumManager.shared.savePhoto(image, to: album.assetCollection)
                        }
                    }
                })
            }
        } else {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error, contextInfo: Any) {
        
        print("save success")
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}



public func LQLog<T>(_ message: T, file: String = #file, method: String = #function,line: Int = #line) {
    #if DEBUG
        let date = "\(Date().timeIntervalSince1970)"
        
        let msg = """
        *********************************************************
        class: \((file as NSString).lastPathComponent)
        method: \(method)
        line: \(line)
        date: \(date)
        message: \(message)
        *********************************************************
        """
        print(msg)
//        print("\((file as NSString).lastPathComponent)[\(line)][\(method)][\(date)], : \(message)")
    #else
    #endif
}
