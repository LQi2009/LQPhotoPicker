//
//  ViewController.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/8/22.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LQPhotoPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
//    var collection: UICollectionView!
//    var preview: LQPhotoBrowser!
    
    var datas: [LQPhotoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
//        layout.scrollDirection = .horizontal
//        collection = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
//        collection.dataSource = self
//        collection.delegate = self
//        collection.isPagingEnabled = true
//        self.view.addSubview(collection)
//        collection.backgroundColor = UIColor.white
//        collection.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
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

    func showAlbum(_ button: UIButton) {
        
        let picker = LQPhotoPicker()
        picker.delegate = self
        
        if button.tag == 1 {
            
            picker.type = .photos
        } else if button.tag == 2 {
            picker.type = .videos
        }
        
        picker.show(self)
    }
    
    func cameraAction() {
        
        LQPhotoCamera.authotization { (isAuth) in
            print(isAuth)
        }
    }
    func photoPickerDidCancel(_ picker: LQPhotoPicker) {
        
    }
    
    func photoPicker(_ picker: LQPhotoPicker, didSelectedItems items: [LQPhotoItem]) {
        
        let preview = LQPhotoBrowser()
        preview.frame = self.view.bounds
        self.view.insertSubview(preview, at: 0)
        preview.configDatas(items)
        
//        datas += items
//        collection.reloadData()
//
//
//        for item in datas {
//            print(item.asset)
//            print(item.asset.modificationDate)
//            print(item.isOriginal)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TestCollectionViewCell
        
        
        
        let item = datas[indexPath.row]
        cell.configData(item)
        
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

