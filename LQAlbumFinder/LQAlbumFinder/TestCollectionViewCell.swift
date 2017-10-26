//
//  TestCollectionViewCell.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/10/17.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit

class TestCollectionViewCell: UICollectionViewCell {
    
    let scroll = LQPhotoScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.addSubview(scroll)
        scroll.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configData(_ model: LQPhotoItem) {
        
        model.image { (image) in
            self.scroll.displayImage(image)
        }
    }
}
