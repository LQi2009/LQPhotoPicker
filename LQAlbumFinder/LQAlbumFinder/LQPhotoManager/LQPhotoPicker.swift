//
//  LQPhotoM.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/9/4.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit

enum LQPhotoPickerType {
    case regular, photos, videos
}

class LQPhotoPicker {

    var type: LQPhotoPickerType = .regular
    var delegate: LQPhotoPickerDelegate?
    
    init() {
        
    }
    
    init(with type: LQPhotoPickerType) {
        self.type = type
        
    }
    
    func show(_ viewController: UIViewController) {
        
        if type == .photos {
//            UIImagePickerController
            let photo = LQPhotoCollectionViewController()
            let navi = UINavigationController(rootViewController: photo)
            photo.style = .photos
            viewController.present(navi, animated: true, completion: nil)
        } else if type == .videos {
            let photo = LQPhotoCollectionViewController()
            let navi = UINavigationController(rootViewController: photo)
            photo.style = .videos
            viewController.present(navi, animated: true, completion: nil)
        } else {
            let photo = LQPhotoCollectionViewController()
            let navi = UINavigationController(rootViewController: photo)
            photo.style = .regular
            viewController.present(navi, animated: true) {
                let album = LQAlbumTableViewController()
                var vcs = navi.childViewControllers
                vcs.insert(album, at: 0)
                navi.setViewControllers(vcs, animated: false)
            }
            
            photo.didSelectedItems({ (items) in
                self.didSelected(items)
            })
        }
    }
    
    func didSelected(_ items: [LQPhotoItem]) {
        if let delegate = delegate {
            delegate.photoPicker(self, didSelectedItems: items)
        }
    }
    
}

protocol LQPhotoPickerDelegate {
    func photoPicker(_ picker: LQPhotoPicker, didSelectedItems items: [LQPhotoItem])
    
    func photoPickerDidCancel(_ picker: LQPhotoPicker)
}
