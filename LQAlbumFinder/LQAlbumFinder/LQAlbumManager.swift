//
//  LQAlbumManager.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/17.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit
import Photos

typealias LQAlbumManagerDidFetchPhotoHandler = ([LQPhotoItem]) -> Void
class LQAlbumManager: NSObject {

    static let shared: LQAlbumManager = LQAlbumManager()
    
    static var isAuthorized: Bool {
        let state = PHPhotoLibrary.authorizationStatus()
        if state == .authorized {
            return true
        } else {
            return false
        }
    }
    
    /// 检测授权
    ///
    /// - Parameter handle: 授权结果回调
    class func authotization(_ handle: @escaping ((_ isAuthorized: Bool) -> Void)) {
        
        let state = PHPhotoLibrary.authorizationStatus()
        
        switch state {
        case .restricted, .denied:
            // 因家长控制无法使用相册
            // 拒绝访问，引导用户重新设置权限
            print(Thread.current)
            DispatchQueue.main.async {
                handle(false)
            }
        case .notDetermined:
            // 未设置过, 请求权限
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    print(Thread.current)
                    DispatchQueue.main.async {
                        handle(true)
                    }
                }
            })
        case .authorized:
            // 有访问权限
            DispatchQueue.main.async {
                handle(true)
            }
        case .limited:
            print("limited")
            break
        @unknown default: break
            
        }
    }
    
    /// 新建相册
    ///
    /// - Parameters:
    ///   - name: 相册名称
    ///   - resultHandle: 结果
    func newAlbum(_ name: String, resultHandle: @escaping ((_ success: Bool,_ error: Error?) -> Void)) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        }) { (success, error) in
            resultHandle(success, error)
        }
    }
    
    /// 保存图片到相册
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - album: 相册名称
    /// - Returns: 保存结果
    @discardableResult
    func savePhoto(_ image: UIImage, to album: PHAssetCollection) -> Bool {
        
        var isSuccess = false
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            
            guard let addAsset = PHAssetCollectionChangeRequest(for: album) else {
                return
            }
            
            addAsset.addAssets([request.placeholderForCreatedAsset!] as NSArray)
        }) { (success, error) in
            if success == false {
                print("[Error: add new asset to \(String(describing: album.localizedTitle)) failed !] error Info: \(error.debugDescription)")
            }
            
            isSuccess = success
        }
        
        return isSuccess
    }
    
    /// 获取所有相册
    ///
    /// - Returns: 相册模型的集合
    func fetchAlbums() -> [LQAlbumItem] {
        
        var items: [LQAlbumItem] = []
        
        let results = self.fetchAlbumCollection(type: .smartAlbum, subType: .albumRegular)
        results.enumerateObjects({ (collection, index, stop) in
            //            || collection.localizedTitle?.range(of: "Videos") != nil
            if collection.localizedTitle?.range(of: "Deleted") != nil  {
                return
            }
            
            // 过滤掉没有照片的相册
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            if assets.count == 0 {
                return
            }
            
            let item = LQAlbumItem(collection)
            items.append(item)
        })
        
        // 获取用户创建的相册
        let userCollections = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        userCollections.enumerateObjects({ (collection, index, stop) in
            
            guard let collection = collection as? PHAssetCollection else {
                return
            }
            
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            guard assets.count > 0 else {
                return
            }
            
            let item = LQAlbumItem(collection)
            items.append(item)
        })
        
        return items
    }
    
    /// 获取指定名称的相册
    ///
    /// - Parameter name: 相册名称
    /// - Returns: 相册实体
    func fetchAlbum(_ name: String) -> LQAlbumItem? {
        
        let colltions = self.fetchAlbumCollection(type: .album, subType: .albumRegular)
        
        var result: PHAssetCollection?
        colltions.enumerateObjects({ (collecte, index, stop) in
            if collecte.localizedTitle == name {
                result = collecte
            }
        })
        
        if let rs = result {
            
            let item = LQAlbumItem(rs)
            
            return item
        } else {
            return nil
        }
    }
    
    func fetchVideosFrom(_ album: LQAlbumItem, videoMaxDuration: TimeInterval = -1) -> [LQPhotoItem] {
        
        var items: [LQPhotoItem] = []
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        //这里只检索视频
        options.predicate = NSPredicate.init(format: "mediaType in %@", [PHAssetMediaType.video.rawValue])
        let results = PHAsset.fetchAssets(in: album.assetCollection, options: options)
        
        results.enumerateObjects({ (asset, index, stop) in
            
            let item = LQPhotoItem(asset)
            // 如果最大时长为-1, 则没有限制长度, 直接添加
            if videoMaxDuration == -1 {
                items.append(item)
            } else {
                if asset.duration < videoMaxDuration + 1 {
                    items.append(item)
                }
            }
        })
        
        return items
    }
    
    /// 获取某个相册的照片
    ///
    /// - Parameter album: 相册模型
    /// - Returns: 照片模型集合
    func fetchPhotosFrom(_ album: LQAlbumItem) -> [LQPhotoItem] {
        
        var items: [LQPhotoItem] = []
        
        let option = PHFetchOptions()
        
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        option.predicate = NSPredicate(format: "mediaType in %@", [PHAssetMediaType.image.rawValue])
        
        let results = PHAsset.fetchAssets(in: album.assetCollection, options: option)
        
        results.enumerateObjects({ (asset, index, stop) in
            let item = LQPhotoItem(asset)
            items.append(item)
        })
        
        return items
    }
    
    /// 获取某个相册的所有资源
    ///
    /// - Parameters:
    ///   - album: 相册的模型
    ///   - videoMaxDuration: 如果包含视频, 视频的最大时长
    /// - Returns: 资源集合
    func fetchAssetsFrom(_ album: LQAlbumItem, videoMaxDuration: TimeInterval = -1) -> [LQPhotoItem] {
        
        var items: [LQPhotoItem] = []
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let results = PHAsset.fetchAssets(in: album.assetCollection, options: options)
        
        results.enumerateObjects({ (asset, index, stop) in
            let item = LQPhotoItem(asset)
            if asset.mediaType == .video {
                // 如果最大时长为-1, 则没有限制长度, 直接添加
                if videoMaxDuration == -1 {
                    items.append(item)
                } else {
                    if asset.duration < videoMaxDuration + 1 {
                        items.append(item)
                    }
                }
            } else {
                items.append(item)
            }
        })
        
        return items
    }
    
    func fetchAssets(_ album: LQAlbumItem, videoMaxDuration: TimeInterval = -1, handler: @escaping LQAlbumManagerDidFetchPhotoHandler) {
        
        var items: [LQPhotoItem] = []
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let results = PHAsset.fetchAssets(in: album.assetCollection, options: options)
        
        results.enumerateObjects({ (asset, index, stop) in
            let item = LQPhotoItem(asset)
            if asset.mediaType == .video {
                // 如果最大时长为-1, 则没有限制长度, 直接添加
                if videoMaxDuration == -1 {
                    items.append(item)
                } else {
                    if asset.duration < videoMaxDuration + 1 {
                        items.append(item)
                    }
                }
            } else {
                items.append(item)
            }
            
            if items.count == 30 {
                handler(items)
            }
        })
        
        handler(items)
    }
    
    /// 获取所有的视频资源
    ///
    /// - Parameter videoMaxDuration: 视频的最大时长
    /// - Returns: 视频资源集合
    func fetchAllVideos(_ videoMaxDuration: TimeInterval = -1) -> [LQPhotoItem] {
        
        var items: [LQPhotoItem] = []
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        //这里只检索视频
        options.predicate = NSPredicate.init(format: "mediaType in %@", [PHAssetMediaType.video.rawValue])
        let results = PHAsset.fetchAssets(with: options)
        
        results.enumerateObjects({ (asset, index, stop) in
            
            let item = LQPhotoItem(asset)
            // 如果最大时长为-1, 则没有限制长度, 直接添加
            if videoMaxDuration == -1 {
                items.append(item)
            } else {
                if asset.duration < videoMaxDuration + 1 {
                    items.append(item)
                }
            }
        })
        
        return items
    }
    
    /// 获取所有的图片
    ///
    /// - Returns: 图片集合
    func fetchAllPhotos() -> [LQPhotoItem] {
        
        let option = PHFetchOptions()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        var items: [LQPhotoItem] = []
        option.predicate = NSPredicate(format: "mediaType in %@", [PHAssetMediaType.image.rawValue])
        
        let results = PHAsset.fetchAssets(with: option)
        results.enumerateObjects({ (asset, index, stop) in
            let item = LQPhotoItem(asset)
            items.append(item)
        })
        
        return items
    }
    
    /// 获取所有的资源(包含图片和视频)
    ///
    /// - Parameter videoMaxDuration: 如果是视频资源, 最大时长
    /// - Returns: 资源集合
    func fetchAllAssets(_ videoMaxDuration: TimeInterval = -1) -> [LQPhotoItem] {
        var items: [LQPhotoItem] = []
        
        let option = PHFetchOptions()
        option.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        //        modificationDate
        //        creationDate
        let results = PHAsset.fetchAssets(with: option)
        
        results.enumerateObjects({ (asset, index, stop) in
            let item = LQPhotoItem(asset)
            if asset.mediaType == .video {
                // 如果最大时长为-1, 则没有限制长度, 直接添加
                if videoMaxDuration == -1 {
                    items.append(item)
                } else {
                    if asset.duration < videoMaxDuration + 1 {
                        items.append(item)
                    }
                }
            } else {
                items.append(item)
            }
        })
        
        return items
    }
    
    /// 获取某个资源中的图片
    ///
    /// - Parameters:
    ///   - item: PHAsset
    ///   - size: 图片的大小
    ///   - handle: 回调
    func imageAsync(from item: PHAsset,targetSize size: CGSize = PHImageManagerMaximumSize, handle: @escaping ((_ image: UIImage?, _ info: [String: Any]) -> Void)) {
        
        let options = PHImageRequestOptions()
        
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        
        PHCachingImageManager.default().requestImage(for: item, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (image, info) in
            handle(image, info as! [String : Any])
        })
    }
    
    /// 获取某个资源的原始数据
    ///
    /// - Parameter item: LQPhotoItem
    /// - Returns: 图片data
    func photoDataSync(from item: LQPhotoItem) -> Data? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        
        var dt: Data?
        
        PHCachingImageManager.default().requestImageData(for: item.asset, options: options) { (data, dsc, orientation, info) in
            
            //            let name = info?["PHImageFileSandboxExtensionTokenKey"] as? String
            dt = data
        }
        
        return dt
    }
    
    /// 获取某个资源中的视频数据
    ///
    /// - Parameters:
    ///   - item: LQPhotoItem
    ///   - completeHandle: 回调
    func videoData(from item: LQPhotoItem, completeHandle: @escaping ((_ url: URL, _ name: String, _ data: Data) -> Void)) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestAVAsset(forVideo: item.asset, options: options) { (asset, audiomix, info) in
            
            guard item.asset.mediaType == .video else {
                return
            }
            
            guard let asset = asset as? AVURLAsset else {
                return
            }
            
            #if DEBUG
            guard let data = NSData(contentsOf: asset.url) else {
                return
            }
            print("File Size : \(Double(data.length / 1024)) kb")
            #endif
            
            let name: String = NSUUID().uuidString + ".mp4"
            let compressUrl = NSURL.fileURL(withPath: NSTemporaryDirectory() + name)
            self.compressVideo(inputURL: asset.url, outPutUrl: compressUrl, handler: { (exportSession) in
                guard let session = exportSession else {
                    return
                }
                
                switch session.status {
                case .unknown, .waiting, .exporting, .failed, .cancelled:
                    break
                case .completed:
                    guard let data = NSData(contentsOf: compressUrl) else {
                        return
                    }
                    
                    completeHandle(compressUrl, name, data as Data)
                }
            })
        }
    }
    
    /// 根据视频资源URL获取视频
    ///
    /// - Parameters:
    ///   - inputURL: 视频URL
    ///   - outPutUrl: 输出URL
    ///   - handler: 回调
    func compressVideo(inputURL: URL , outPutUrl: URL, handler: @escaping ((_ exportSession: AVAssetExportSession?)-> Void)) {
        
        let urlAsset = AVURLAsset(url: inputURL)
        guard let exportSession = AVAssetExportSession.init(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            
            handler(nil)
            return }
        
        exportSession.outputURL = outPutUrl
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            handler(exportSession)
        }
    }
    
    /// 获取系统相册
    ///
    /// - Parameters:
    ///   - type: 相册类型
    ///   - subType: 相册子类型
    /// - Returns: 相册的集合
    func fetchAlbumCollection(type: PHAssetCollectionType, subType: PHAssetCollectionSubtype) -> PHFetchResult<PHAssetCollection> {
        
        let options = PHFetchOptions()
        
        return PHAssetCollection.fetchAssetCollections(with: type, subtype: subType, options: options)
    }
}


extension LQAlbumManager: PHPhotoLibraryChangeObserver {
    
    func registeObserver() {
        
        PHPhotoLibrary.shared().register(self)
    }
    
    func unregisteObserver() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}
