//
//  LQPhotoScrollView.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/8/25.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit

typealias LQPhotoScrollViewHandle = () -> Void
class LQPhotoScrollView: UIScrollView {

    fileprivate var zoomView: UIImageView = UIImageView()
    private var imageSize: CGSize = .zero
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.scrollsToTop = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
        self.clipsToBounds = true
        self.maximumZoomScale = 3.0
        self.minimumZoomScale = 1.0
        self.addSubview(zoomView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayImage(_ image: UIImage) {
        
        imageSize = image.size
        zoomView.image = image
        self.contentSize = imageSize
        self.layoutZoomViewFrame()
    }
    
    func reset() {
        
        self.zoomScale = 1.0
        self.maximumZoomScale = 3.0
        self.minimumZoomScale = 1.0
        self.contentOffset = .zero
        self.contentSize = .zero
    }

    private lazy var doubleGesture: UITapGestureRecognizer = {
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleGestureAction))
        tap.numberOfTapsRequired = 2
        
        return tap
    }()
    
    private lazy var singleGesture: UITapGestureRecognizer = {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(singleGestureAction))
        tap.numberOfTapsRequired = 1
        
        return tap
    }()
    
    private lazy var longGesture: UILongPressGestureRecognizer = {
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction))
        
        return tap
    }()
    
    private var doubleHandle: LQPhotoScrollViewHandle?
    private var singleHandle: LQPhotoScrollViewHandle?
    private var longHandle: LQPhotoScrollViewHandle?
    
    @objc private func doubleGestureAction() {
        if let handle = doubleHandle {
            handle()
        }
        
        if self.zoomScale != 1 {
            self.setZoomScale(1.0, animated: true)
        } else {
            self.setZoomScale(3.0, animated: true)
        }
    }
    
    @objc private func singleGestureAction() {
        if let handle = singleHandle {
            handle()
        }
    }
    
    @objc private func longGestureAction() {
        if let handle = longHandle {
            handle()
        }
    }
    
    func addDoubleGesture(_ handle: LQPhotoScrollViewHandle?) {
        self.addGestureRecognizer(doubleGesture)
        doubleHandle = handle
    }
    
    func addSingleGesture(_ handle: LQPhotoScrollViewHandle?) {
        self.addGestureRecognizer(singleGesture)
        singleHandle = handle
    }
    
    func addLongGesture(_ handle: LQPhotoScrollViewHandle?) {
        self.addGestureRecognizer(longGesture)
        longHandle = handle
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomViewToCenter()
    }
    
    private func layoutZoomViewFrame() {
        
        var zoomFrame: CGRect = .zero
        var zoomViewWidth = self.bounds.width
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        
        var zoomViewS = zoomViewWidth/imageWidth
        var zoomViewHeight = zoomViewS*imageHeight
        
        var zoomX: CGFloat = 0
        var zoomY: CGFloat = (self.bounds.height - zoomViewHeight)/2.0
        
        if zoomViewHeight > self.bounds.height {
            zoomViewHeight = self.bounds.height
            zoomViewS = zoomViewHeight/imageHeight
            zoomViewWidth = imageWidth*zoomViewS
            zoomY = 0
            zoomX = (self.bounds.width - zoomViewWidth)/2.0
        }
        //
        zoomFrame.size = CGSize(width: zoomViewWidth, height: zoomViewHeight)
        zoomFrame.origin = CGPoint(x: zoomX, y: zoomY)
        zoomView.frame = zoomFrame
        
        self.setZoomScale(1.0, animated: false)
    }
    
    fileprivate func zoomViewToCenter() {
        
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
}

extension LQPhotoScrollView: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.zoomViewToCenter()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return zoomView
    }
}
