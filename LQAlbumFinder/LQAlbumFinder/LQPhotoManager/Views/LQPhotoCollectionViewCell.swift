//
//  LQPhotoCollectionViewCell.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/8/22.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit
import Photos

typealias LQPhotoCollectionViewCellSelectedHandle = (_ isSelected: Bool) -> Void

class LQPhotoCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView: UIImageView = {
    
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        self.contentView.addSubview(img)
        img.backgroundColor = UIColor.red
        return img
    }()
    
    lazy var videoTimeLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(x: 5, y: self.contentView.frame.height - 20, width: self.contentView.frame.width - 10, height: 20))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.textAlignment = .right
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var selectedButton: UIButton = {
    
        let selectButton = UIButton(type: .custom)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        selectButton.setBackgroundImage(UIImage.init(named: "selectButton_unselectedState"), for: .normal)
        selectButton.setBackgroundImage(UIImage.init(named: "selectButton_selectedStateBackground"), for: .selected)
        selectButton.addTarget(self, action: #selector(selectedButtonAction), for: .touchUpInside)
        self.contentView.addSubview(selectButton)
        return selectButton
    }()
    
    lazy var maskWhiteView: UIView = {
    
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.alpha = 0.8
        view.isHidden = true
        view.frame = self.bounds
        view.isUserInteractionEnabled = false
        self.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = self.bounds
        var width = self.bounds.width/3.0
        if width < 23 {
            width = 25
        } else if width > 30 {
            width = 30
        }
        
        let space: CGFloat = 4
        
        selectedButton.frame = CGRect(x: self.bounds.width - width - space, y: space, width: width, height: width)
    }
    
    var isSelectedHandle: LQPhotoCollectionViewCellSelectedHandle?
    
    func configData(_ item: LQPhotoItem) {
        
        let manager = PHCachingImageManager.default()
        
//        let options = PHImageRequestOptions()
        
        if self.tag != 0 {
            let resID = PHImageRequestID(self.tag)
            
            manager.cancelImageRequest(resID)
        }
        
        let size = self.bounds.size
        
        let resID = manager.requestImage(for: item.asset, targetSize: CGSize.init(width: size.width*LQAlbumWindowScale, height: size.height*LQAlbumWindowScale), contentMode: .aspectFill, options: nil) { (image, info) in
            guard let img = image else {
                return
            }
            
            self.imageView.image = img
        }
        
        self.tag = Int(resID)
        
        if item.asset.mediaType == .video {
            let duration = item.asset.duration
            videoTimeLabel.text = formatPlayTime(secounds: duration)
            videoTimeLabel.isHidden = false
        } else {
            videoTimeLabel.isHidden = true
        }
        
        maskWhiteView.isHidden = item.isSelectedEnable
        selectedButton.isSelected = item.isSelected
        if item.isSelected && item.selectedNumber != -1 {
            selectedButton.setTitle("\(item.selectedNumber)", for: .selected)
        }
    }
    
    func selectedHandle(_ handle: @escaping LQPhotoCollectionViewCellSelectedHandle) {
        isSelectedHandle = handle
    }
    
    @objc private func selectedButtonAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            springAnimation(button)
        }
        
        if let handle = isSelectedHandle {
            handle(button.isSelected)
        }
    }
    
    private func formatPlayTime(secounds: TimeInterval)-> String {
        if secounds.isNaN{
            return "00:00"
        }
        var Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        var Hour = 0
        if Min>=60 {
            Hour = Int(Min / 60)
            Min = Min - Hour*60
            return String(format: "%02d:%02d:%02d", Hour, Min, Sec)
        }
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    private func springAnimation(_ view: UIView) {
        // 动画方式一
        //        let animate = CASpringAnimation(keyPath: "bounds")
        //        animate.mass = 10.0
        //        animate.stiffness = 5000
        //        animate.damping = 100
        //        animate.initialVelocity = 5.0
        //        animate.duration = animate.settlingDuration
        //
        //        var frame = view.bounds
        //        frame.size.width += 4
        //        frame.size.height += 4
        //        animate.toValue = NSValue.init(cgRect: frame)
        //        animate.isRemovedOnCompletion = true
        //        animate.fillMode = kCAFillModeForwards
        //        animate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        //        view.layer.add(animate, forKey: "boundsAnimate")
        // 动画方式二
        //        UIView.animate(withDuration: 0.2, animations: {
        //            var frame = view.frame
        //            frame.size.width += 4
        //            frame.size.height += 4
        //            view.frame = frame
        //        }, completion: { (finish) in
        //            UIView.animate(withDuration: 0.1, animations: {
        //                var frame = view.frame
        //                frame.size.width -= 6
        //                frame.size.height -= 6
        //                view.frame = frame
        //            }, completion: { (finish) in
        //                UIView.animate(withDuration: 0.2, animations: {
        //                    var frame = view.frame
        //                    frame.size.width += 2
        //                    frame.size.height += 2
        //                    view.frame = frame
        //
        //                })
        //            })
        //        })
        // 动画方式三
        let keyAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyAnimation.values = [0.9, 0.84, 0.8, 0.9, 1.0, 1.1, 1.2, 1.1, 1.0]
        keyAnimation.repeatCount = 1
        keyAnimation.isRemovedOnCompletion = false
        keyAnimation.fillMode = kCAFillModeForwards
        keyAnimation.duration = 0.6
        keyAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        view.layer.add(keyAnimation, forKey: "keyFrameAnima")
    }
}
