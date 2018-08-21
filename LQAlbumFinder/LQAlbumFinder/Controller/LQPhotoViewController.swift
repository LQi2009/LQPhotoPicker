//
//  LQPhotoViewController.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/19.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit
import Photos

public enum LQPhotoCollectionStyle {
    case regular, photos, videos
}

private let reuseIdentifier = "LQPhotoCollectionViewControllerReuseIdentifier"
public typealias LQPhotoSelectedHandler = (_ items: [LQPhotoItem]) -> Void

extension LQPhotoViewController {
    
    public func didSelectedItems(_ handle: @escaping LQPhotoSelectedHandler) {
        selectedHandle = handle
    }
}

public class LQPhotoViewController: UICollectionViewController {

    var maxSelectedNumber: Int = 0
    var style: LQPhotoCollectionStyle = .regular
    var camaraEnable: Bool = false
    var albumItem: LQAlbumItem?
    var columnNumber: Int = 4
    
    private var photoAlbum: LQAlbumItem?// 相机胶卷
    
    private var photoSavedAlbum: LQAlbumItem?// 保存拍摄照片的相册
    private var dataSource: [LQPhotoItem] = []
    
    
    private lazy var activity: UIActivityIndicatorView = {
        
        let acti = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        acti.hidesWhenStopped = true
        acti.center = self.view.center
        self.view.addSubview(acti)
        return acti;
    }()
    
    private lazy var bottomBar: LQPhotoBottomBar = {

        let bar = LQPhotoBottomBar()
        self.view.addSubview(bar)
        return bar
    }()
    
    fileprivate var selectedItems: [LQPhotoItem] = []
    fileprivate lazy var imageManager = {
        
        return PHCachingImageManager()
    }()
    
    private var selectedHandle: LQPhotoSelectedHandler?
    fileprivate var previousPreheatRect = CGRect.zero
    
    deinit {
        print("LQPhotoCollectionViewController deinit")
        
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var colFrame = collectionView?.frame
        colFrame?.size.height -= 49
        collectionView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 49)
        
        bottomBar.frame = CGRect(x: 0, y: self.view.frame.height - 49, width: self.view.frame.width, height: 49)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = true
        self.collectionView!.register(LQPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(LQPhotoCameraCell.self, forCellWithReuseIdentifier: "LQPhotoCameraCellID")
        
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.bounces = true
        self.title = "相册"
        
        if self.albumItem == nil {
            
            LQAlbumManager.authotization {[weak self] (isAuth) in
                if isAuth {
                    self?.activity.startAnimating()
                    DispatchQueue(label: "LQPhotoCollectionViewControllerQueue").async {
                        self?.loadData()
                    }
                } else {
                    self?.noneAuthodAlert("无权访问您的相册")
                }
            }
        } else {
            //            self.title = self.albumItem?.name
            self.activity.startAnimating()
            DispatchQueue(label: "LQPhotoCollectionViewControllerQueue").async {
                self.loadData()
            }
        }
        
        self.setupNavBar()
        self.setupBottomBar()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    private func loadData() {
        if dataSource.count >= 0 {
            dataSource.removeAll()
        }
        
        // 过滤出相册库
        if photoAlbum == nil {
            let albums = LQAlbumManager.shared.fetchAlbums()
            for am in albums {
                if am.name == "相机胶卷" {
                    self.photoAlbum = am
                    self.photoSavedAlbum = am
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
                
                var allPhoto: LQAlbumItem? = nil
                let albums = LQAlbumManager.shared.fetchAlbums()
                for am in albums {
                    if am.name == "相机胶卷" {
                        self.albumItem = am
//                        break
                    } else if am.name == "所有照片" {
                        allPhoto = am
                    }
                }
                
                if self.albumItem == nil {
                    self.albumItem = allPhoto
                }
            }
            
            title = (self.albumItem?.name)!
            let results = LQAlbumManager.shared.fetchAssetsFrom(albumItem!)
            dataSource += results
        }
        
        DispatchQueue.main.async {
            self.title = title
            if self.dataSource.count > 0 {

                self.title = title
                self.collectionView?.reloadData()
                var index = IndexPath(item: self.dataSource.count - 1, section: 0)
                if self.camaraEnable {
                    index = IndexPath(item: self.dataSource.count, section: 0)
                }
                self.collectionView?.scrollToItem(at: index, at: .bottom, animated: false)
                self.resetCachedAssets()
                self.activity.stopAnimating()
            }
        }
    }
    
    func configDatas(_ datas: [LQPhotoItem]) {
        
        if self.dataSource.count > 0 {
            self.dataSource.removeAll()
        }
        
        self.dataSource += datas
        DispatchQueue.main.async {
            if self.dataSource.count > 0 {
                
                self.collectionView?.reloadData()
                
                var index = IndexPath(item: self.dataSource.count - 1, section: 0)
                
                if self.camaraEnable {
                    index = IndexPath(item: self.dataSource.count, section: 0)
                }
                
                self.collectionView?.scrollToItem(at: index, at: .bottom, animated: false)
                self.resetCachedAssets()
            }
        }
    }
    convenience init() {
        
        let space: CGFloat = 4
        var col = 4
        
        let layout = UICollectionViewFlowLayout()
        if LQAlbum_iPad {
            col = 10
        }
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - space * CGFloat(col + 1))/CGFloat(col), height: (UIScreen.main.bounds.width - space * CGFloat(col + 1))/CGFloat(col))
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.sectionInset = UIEdgeInsetsMake(space, space, space, space)
        self.init(collectionViewLayout: layout)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupNavBar() {
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.frame = CGRect(x: self.view.frame.width - 50, y: 20, width: 50, height: 44)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        if style == .regular {
            let backBtn = UIButton(type: .custom)
            backBtn.setTitle("返回", for: .normal)
            backBtn.setImage(UIImage.init(named: LQPhotoIcon_back), for: .normal)
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
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.camaraEnable {
            return dataSource.count + 1
        }
        
        return dataSource.count
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == dataSource.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LQPhotoCameraCellID", for: indexPath)
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LQPhotoCell
        
        let item = dataSource[indexPath.row]
        item.indexPath = indexPath
        cell.configData(item)
        
        cell.selectedHandler {[weak self] (isSelected) in
            self?.selectedItem(isSelected, indexPath: indexPath)
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard indexPath.row < dataSource.count else {
            self.cameraAction()
            return
        }
        
        let item = dataSource[indexPath.row]
        if item.isSelected == false && selectedItems.count == maxSelectedNumber && maxSelectedNumber > 0 {
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
            self?.bottomBar.originButton.isSelected = isOriginal
            self?.selectedItem(isSelected, indexPath: index)
        }
        
        preview.didSelectedItems {[weak self] (items) in
            if let handle = self?.selectedHandle {
                handle(items)
            }
        }
    }
    
    fileprivate func selectedItem(_ isSelected: Bool, indexPath: IndexPath) {
        
        if maxSelectedNumber > 0 && selectedItems.count == maxSelectedNumber && isSelected {
            
            let alert = UIAlertController(title: "您最多只能选择\(maxSelectedNumber)张照片!", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "我知道了", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            collectionView?.reloadItems(at: [indexPath])
            return
        }
        
        let item = dataSource[indexPath.row]
        item.isSelected = isSelected
        item.isOriginal = self.bottomBar.originButton.isSelected
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
        
        if selectedItems.count == maxSelectedNumber && maxSelectedNumber > 0 {
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
    
    override public var shouldAutorotate: Bool {
        
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}

extension LQPhotoViewController {
    
    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

//MARK: - Bottom Tool Bar
extension LQPhotoViewController {
    
    func setupBottomBar() {
        
        self.bottomBar.previewWithHandler {[weak self] (button) in
            
            self?.previewSelectedItemAction()
        }
        
        self.bottomBar.originWithHandler {[weak self] (button) in
            self?.originButtonAction(button)
        }
        
        self.bottomBar.commitWithHandler {[weak self] (button) in
            self?.sendButtonAction()
        }
    }
    
    private func previewSelectedItemAction() {
        
        let preview = LQPhotoPreviewController()
        preview.selectedItems += selectedItems
        preview.dataSource += selectedItems
        preview.isPreview = true
        
        self.navigationController?.pushViewController(preview, animated: true)
        
        preview.selectedIndexPath {[weak self] (indexPath, isSelected, isOriginal) in
            self?.bottomBar.originButton.isSelected = isOriginal
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
            
            self.bottomBar.resetCommitButtonTitle("确定(\(selectedItems.count))")
            self.bottomBar.actionEnable = true
        } else {
            self.bottomBar.resetCommitButtonTitle("确定)")
            self.bottomBar.actionEnable = false
        }
    }
}

extension LQPhotoViewController:PHPhotoLibraryChangeObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func cameraAction() {
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == .denied || status == .restricted {
            self.noneAuthodAlert("无权访问您的相机")
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
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
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            
            return
        }
        
        let appInfo = Bundle.main.infoDictionary
        if let appName = appInfo?["CFBundleDisplayName"] as? String {
            if let album = LQAlbumManager.shared.fetchAlbum(appName) {
                self.photoSavedAlbum = album
                LQAlbumManager.shared.savePhoto(image, to: album.assetCollection)
            } else {
                LQAlbumManager.shared.newAlbum(appName, resultHandle: { (success, error) in
                    if success {
                        if let album = LQAlbumManager.shared.fetchAlbum(appName) {
                            self.photoSavedAlbum = album
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
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        print("photoLibraryDidChange")
        
        if let changes = changeInstance.changeDetails(for: (self.photoSavedAlbum?.assetCollection)!) {
            
            if let album = changes.objectAfterChanges {
                
                let item = LQAlbumItem(album)
                let items = LQAlbumManager.shared.fetchAssetsFrom(item)
                
                if let last = items.last, let sLast = self.dataSource.last {
                    
                    if last.asset.localIdentifier != sLast.asset.localIdentifier {
                        self.dataSource.append(items.last!)
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                }
                
                
            }
        }

    }
}

private var currentPath: IndexPath?
extension LQPhotoViewController {
    
    func addPan() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        
        collectionView?.superview?.addGestureRecognizer(pan)
    }
    
    @objc func panGestureAction(_ pan: UIPanGestureRecognizer) {
        
        let point = pan.location(in: collectionView)
        
        if let path = collectionView?.indexPathForItem(at: point) {
            
            if let current = currentPath {
                if current == path {
                    return
                }
            }
            
            currentPath = path
            //            self.selectedItem(<#T##isSelected: Bool##Bool#>, indexPath: <#T##IndexPath#>)
            //            if let cell = collectionView?.cellForItem(at: path) as? LQPhotoCollectionViewCell {
            //                self.selectPhoto(cell: cell)
            //                //                scrollCollection(cell, point)
            //            }
        }
    }
}
