//
//  LQPhotoPreviewCell.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/19.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit
import Photos

typealias LQPhotoPreviewCellTapHandler = () -> Void
class LQPhotoPreviewCell: UICollectionViewCell {
    
    lazy var scroll: UIScrollView = {
        
        let sl = UIScrollView()
        sl.delegate = self
        sl.maximumZoomScale = maxScale
        sl.minimumZoomScale = 1
        sl.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        sl.showsVerticalScrollIndicator = false
        sl.showsHorizontalScrollIndicator = false
        self.addSubview(sl)
        return sl
    }()
    
    lazy var zoomView: UIImageView = {
        
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        //        img.backgroundColor = UIColor.green
        return img
    }()
    
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    var singleTapHandle: LQPhotoPreviewCellTapHandler?
    var maxScale: CGFloat = 3.0 {
        
        didSet {
            self.scroll.maximumZoomScale = maxScale
        }
    }
    var minScale: CGFloat = 1.0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        
        scroll.addSubview(zoomView)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doupleTapGesture))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapGesture))
        self.addGestureRecognizer(singleTap)
        // 避免单双击冲突
        singleTap.require(toFail: doubleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func singleTapAction(_ handle: @escaping LQPhotoPreviewCellTapHandler) {
        singleTapHandle = handle
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scroll.frame = self.bounds
        self.zoomViewToCenter()
    }
    
    @objc func doupleTapGesture(_ gesture: UITapGestureRecognizer) {
        
        if scroll.zoomScale != 1 {
            scroll.setZoomScale(1.0, animated: true)
        } else {
            scroll.setZoomScale(maxScale, animated: true)
        }
    }
    
    @objc func singleTapGesture( _ gesture: UITapGestureRecognizer) {
        if let handle = singleTapHandle {
            handle()
        }
    }
    
    func configData(_ item: LQPhotoItem) {
        
        let manager = PHCachingImageManager.default()
        
        if self.tag != 0 {
            let resID = PHImageRequestID(self.tag)
            
            manager.cancelImageRequest(resID)
        }
        
        let size = self.bounds.size
        
        let resID = manager.requestImage(for: item.asset, targetSize: CGSize.init(width: size.width*LQAlbumWindowScale, height: size.height*LQAlbumWindowScale), contentMode: .aspectFill, options: nil) { (image, info) in
            guard let img = image else {
                return
            }
            
            self.zoomView.image = img
        }
        
        self.tag = Int(resID)
        imageWidth = CGFloat(item.asset.pixelWidth)
        imageHeight = CGFloat(item.asset.pixelHeight)
        
        self.layoutZoomViewFrame()
    }
    
    func reset() {
        
        scroll.zoomScale = 1.0
        scroll.contentOffset = .zero
        scroll.contentSize = .zero
        scroll.maximumZoomScale = maxScale
        scroll.minimumZoomScale = minScale
    }
    
    func zoomViewToCenter() {
        
        let boundSize = self.bounds.size
        var frameToCenter = self.zoomView.frame
        
        if frameToCenter.width < boundSize.width {
            frameToCenter.origin.x = (boundSize.width - frameToCenter.width)/2.0
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.height < boundSize.height {
            frameToCenter.origin.y = (boundSize.height - frameToCenter.height)/2.0
        } else {
            frameToCenter.origin.y = 0
        }
        
        self.zoomView.frame = frameToCenter
    }
    
    func layoutZoomViewFrame() {
        
//        var zoomFrame: CGRect = .zero
//        var zoomViewWidth = self.bounds.width
//        var zoomViewS = zoomViewWidth/imageWidth
//        var zoomViewHeight = zoomViewS*imageHeight
//
//        var zoomX: CGFloat = 0
//        var zoomY: CGFloat = (self.bounds.height - zoomViewHeight)/2.0
//
//        if zoomViewHeight > self.bounds.height {
//            zoomViewHeight = self.bounds.height
//            zoomViewS = zoomViewHeight/imageHeight
//            zoomViewWidth = imageWidth*zoomViewS
//            zoomY = 0
//            zoomX = (self.bounds.width - zoomViewWidth)/2.0
//        }
//        //
//        zoomFrame.size = CGSize(width: zoomViewWidth, height: zoomViewHeight)
//        zoomFrame.origin = CGPoint(x: zoomX, y: zoomY)
//        zoomView.frame = zoomFrame
//
//        self.scroll.setZoomScale(1.0, animated: false)
        
        var zoomFrame: CGRect = .zero
        let zoomViewWidth = self.bounds.width
        let zoomViewS = zoomViewWidth/imageWidth
        let zoomViewHeight = zoomViewS*imageHeight
        
        let zoomX: CGFloat = 0
        var zoomY: CGFloat = 0
        
        if zoomViewHeight < self.bounds.height {
            
            zoomY = (self.bounds.height - zoomViewHeight)/2.0
        }
        //
        zoomFrame.size = CGSize(width: zoomViewWidth, height: zoomViewHeight)
        zoomFrame.origin = CGPoint(x: zoomX, y: zoomY)
        zoomView.frame = zoomFrame
        
        self.scroll.setZoomScale(1.0, animated: false)
        maxScale = 2.0
    }
}

extension LQPhotoPreviewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        self.zoomViewToCenter()
    }
}
