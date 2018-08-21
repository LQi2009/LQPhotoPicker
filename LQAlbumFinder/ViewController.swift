//
//  ViewController.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/17.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LQPhotoPickerDelegate {

    var datas: [LQPhotoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let button = UIButton(type: .custom)
        button.setTitle("所有", for: .normal)
        button.backgroundColor = UIColor.red
        button.frame = CGRect(x: 30, y: 60, width: 100, height: 30)
        button.addTarget(self, action: #selector(showAlbum), for: .touchUpInside)
        self.view.addSubview(button)
        
        let photo = UIButton(type: .custom)
        photo.setTitle("图片", for: .normal)
        photo.backgroundColor = UIColor.red
        photo.frame = CGRect(x: 30, y: 100, width: 100, height: 30)
        photo.tag = 1
        photo.addTarget(self, action: #selector(showAlbum), for: .touchUpInside)
        self.view.addSubview(photo)
        
        let video = UIButton(type: .custom)
        video.setTitle("视频", for: .normal)
        video.backgroundColor = UIColor.red
        video.frame = CGRect(x: 30, y: 140, width: 100, height: 30)
        video.tag = 2
        video.addTarget(self, action: #selector(showAlbum), for: .touchUpInside)
        self.view.addSubview(video)
        
        let camera = UIButton(type: .custom)
        camera.setTitle("相机", for: .normal)
        camera.backgroundColor = UIColor.red
        camera.frame = CGRect(x: 30, y: 180, width: 100, height: 30)
        camera.tag = 3
        camera.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
        self.view.addSubview(camera)
    }

    @objc func showAlbum(_ button: UIButton) {
        
        let picker = LQPhotoPicker()
        picker.delegate = self
        
        if button.tag == 1 {
            
            picker.type = .photos
        } else if button.tag == 2 {
            picker.type = .videos
        }
        
        picker.show(self)
    }
    
    @objc func cameraAction() {
        
//        LQPhotoCamera.authotization { (isAuth) in
//            print(isAuth)
//        }
    }
    func photoPickerDidCancel(_ picker: LQPhotoPicker) {
        
    }
    
    func photoPicker(_ picker: LQPhotoPicker, didSelectedItems items: [LQPhotoItem]) {
        
        let preview = LQPhotoBrowser()
        preview.frame = self.view.bounds
        self.view.insertSubview(preview, at: 0)
        preview.configDatas(items)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

