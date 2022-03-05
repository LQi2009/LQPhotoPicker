//
//  LQPhotoPicker.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/19.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
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
            let photo = LQPhotoViewController()
            let navi = UINavigationController(rootViewController: photo)
            photo.style = .photos
            navi.modalPresentationStyle = .fullScreen
//            viewController.modalPresentationStyle = .fullScreen
            viewController.present(navi, animated: true, completion: nil)
        } else if type == .videos {
//            let photo = LQPhotoViewController()
//            let navi = UINavigationController(rootViewController: photo)
//            photo.style = .videos
//            viewController.present(navi, animated: true, completion: nil)
            
            LQPhotoViewController.show(viewController, style: .videos)
        } else {
//            let photo = LQPhotoViewController()
//            let navi = UINavigationController(rootViewController: photo)
//            photo.style = .regular
//            photo.camaraEnable = true
//            viewController.present(navi, animated: true) {
//                let album = LQAlbumViewController()
//                var vcs = navi.childViewControllers
//                vcs.insert(album, at: 0)
//                navi.setViewControllers(vcs, animated: false)
//            }
            
            let photo = LQPhotoViewController.show(viewController)
            
            photo.camaraEnable = true
//            photo.delegate = self
            photo.didSelectedItems({(items) in
//                let sf = self
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

extension LQPhotoPicker: LQPhotoViewControllerDelegate {
    
    func photoViewController(_ viewController: LQPhotoViewController, didSelectedItems items: [LQPhotoItem]) {
        self.didSelected(items)
    }
}

protocol LQPhotoPickerDelegate {
    func photoPicker(_ picker: LQPhotoPicker, didSelectedItems items: [LQPhotoItem])
    
    func photoPickerDidCancel(_ picker: LQPhotoPicker)
}
