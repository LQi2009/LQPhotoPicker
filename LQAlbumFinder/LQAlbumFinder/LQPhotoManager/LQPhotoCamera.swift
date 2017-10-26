//
//  LQPhotoCamera.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/9/10.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit
import AVFoundation

class LQPhotoCamera: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    class func authotization(_ handle: @escaping ((_ isAuthorized: Bool) -> Void)) {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch status {
        case .denied, .restricted:
            handle(false)
        case .notDetermined, .authorized:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let picker = UIImagePickerController()
                picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
//                picker.mediaTypes = [kUTTypeImage as String , "kUTTypeMovie"]
                //                picker.showsCameraControls = false
//                picker.cameraViewTransform = CGAffineTransform.init(scaleX: 1.5, y: 2.0)
                picker.cameraViewTransform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi*45/180))
                let window = UIApplication.shared.keyWindow
                
                window?.rootViewController?.present(picker,animated: true,completion: nil)
            } else {
                print("不支持相机")
            }
        }
    }
}
