//
//  LQAlbumItem.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/17.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit
import Photos

public class LQAlbumItem {

    var name: String = "未知"
    var count: Int = 0
    var assetCollection: PHAssetCollection!
    var coverAsset: PHAsset?
    
    init(_ collection: PHAssetCollection) {
        
        if let title = collection.localizedTitle {
            name = self.checkTitle(title)
        }
        
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        count = assets.count
        coverAsset = assets.lastObject
        assetCollection = collection
    }
    
    private func checkTitle(_ title: String) -> String {
        print(title)
        
        switch title {
        case "Slo-mo":
            return "慢动作"
        case "Recently Added":
            return "最近添加"
        case "Favorites":
            return "个人收藏"
        case "Recently Deleted":
            return "最近删除"
        case "Videos":
            return "视频"
        case "Selfies":
            return "自拍"
        case "Screenshots":
            return "屏幕快照"
        case "Camera Roll":
            return "相机胶卷"
        case "Panoramas":
            return "全景照片"
        case "Bursts":
            return "连拍快照"
        case "Hidden":
            return "隐藏相册"
        case "Depth Effect":
            return "景深效果"
        case "Time-lapse":
            return "延时摄影"
        case "All Photos":
            return "所有照片"
        case "Recents":
            return "最近的"

        default:
            return title
        }
    }
}

public class LQPhotoItem: NSObject {
    
    var isSelected: Bool = false {
        didSet{
            if isSelected == false {
                selectedNumber = -1
            }
        }
    }
    var selectedNumber: Int = -1
    
    var isSelectedEnable: Bool = true
    var isOriginal: Bool = false
    
    var asset: PHAsset!
    var indexPath: IndexPath?
    var isVideo: Bool {
        get {
            return asset.mediaType == .video;
        }
    }
    
    init(_ asset: PHAsset) {
        
        self.asset = asset
    }
    
    func image(_ handle: @escaping (_ img: UIImage) -> Void) {
        if isOriginal {
            LQAlbumManager.shared.imageAsync(from: asset, handle: { (image, info) in
                if let ig = image {
                    handle(ig)
                }
            })
        } else {
            let width: CGFloat = UIScreen.main.bounds.width
            let sl = width/CGFloat(asset.pixelWidth)
            let height = sl*CGFloat(asset.pixelHeight)
            let size = CGSize(width: width, height: height)
            
            LQAlbumManager.shared.imageAsync(from: asset, targetSize: size, handle: { (image, info) in
                if let ig = image{
                    handle(ig)
                }
            })
        }
    }
    
    func data(_ handle: (_ data: Data?) -> Void) {
        let data = LQAlbumManager.shared.photoDataSync(from: self)
        handle(data)
    }
}




