//
//  LQAlbumCell.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/19.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

class LQAlbumCell: UITableViewCell {

    lazy var coverImage: UIImageView = {
        
        let img = UIImageView()
        img.contentMode = .scaleToFill
        self.contentView.addSubview(img)
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.black
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var numberLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.gray
        self.contentView.addSubview(label)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configWith(_ item: LQAlbumItem) {
        
        if let asset = item.coverAsset {
            let width = self.bounds.height - 4
            let size = CGSize.init(width: width*LQAlbumWindowScale, height: width*LQAlbumWindowScale)
            
            LQAlbumManager.shared.imageAsync(from: asset, targetSize: size, handle: { (image, info) in
                if let img = image {
                    self.coverImage.image = img
                }
            })
        }
        
        nameLabel.text = item.name
        numberLabel.text = "(\(item.count))"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = self.bounds.height
        
        coverImage.frame = CGRect(x: 10, y: 2, width: height - 4, height: height - 4)
        
        let nameSize = nameLabel.sizeThatFits(CGSize(width: 100, height: height - 4))
        
        nameLabel.frame = CGRect(x: coverImage.frame.maxX + 10, y: 2, width: nameSize.width + 8, height: height - 4)
        
        let numberSize = numberLabel.sizeThatFits(CGSize(width: 100, height: height - 4))
        numberLabel.frame = CGRect(x: nameLabel.frame.maxX + 10, y: 2, width: numberSize.width + 4, height: height - 4)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
