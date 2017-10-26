//
//  LQPhotoCameraCell.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/9/8.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit

class LQPhotoCameraCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = UIViewContentMode.scaleAspectFill
//        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named:"photo_camera")
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = self.bounds
    }
}
