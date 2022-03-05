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
    
    var singleTapHandle: LQPhotoPreviewCellTapHandler?
    
    var photo: LQPhotoItem?
    
    lazy var imageView: UIImageView = {
        
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doupleTapGesture))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapGesture))
        self.addGestureRecognizer(singleTap)
        // 避免单双击冲突
        singleTap.require(toFail: doubleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func singleTapAction(_ handle: @escaping LQPhotoPreviewCellTapHandler) {
        singleTapHandle = handle
    }
    
    func configData(_ item: LQPhotoItem) {
        
        
    }
    func reset() {}
    
    @objc func doupleTapGesture(_ gesture: UITapGestureRecognizer) {}
    @objc func singleTapGesture( _ gesture: UITapGestureRecognizer) {}
}



//MARK: - 图片预览 LQPhotoImagePreviewCell
class LQPhotoImagePreviewCell: LQPhotoPreviewCell {
    
    static let reuseIdentifier = "LQPhotoPreviewCellReuseID"
    
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
    
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    var maxScale: CGFloat = 3.0 {
        
        didSet {
            self.scroll.maximumZoomScale = maxScale
        }
    }
    var minScale: CGFloat = 1.0
    var imageScale: CGFloat = 2.0
    var reqID: Int32 = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scroll.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scroll.frame = self.bounds
        self.zoomViewToCenter()
    }
    
    override func configData(_ item: LQPhotoItem) {
        
        let manager = PHCachingImageManager.default()
        
        if self.reqID > 0 {
            let resID = PHImageRequestID(self.reqID)
            
            manager.cancelImageRequest(resID)
        }
        
        let size = self.bounds.size
        
        self.reqID = manager.requestImage(for: item.asset, targetSize: CGSize.init(width: size.width*LQAlbumWindowScale, height: size.height*LQAlbumWindowScale), contentMode: .aspectFill, options: nil) { (image, info) in
            guard let img = image else {
                return
            }
            
            self.imageView.image = img
        }
        
        imageWidth = CGFloat(item.asset.pixelWidth)
        imageHeight = CGFloat(item.asset.pixelHeight)
        
        self.layoutZoomViewFrame()
        if imageWidth / imageHeight > size.width / size.height {
            imageScale = (imageWidth * size.height) / (size.width * imageHeight)
        } else {
            imageScale = (size.width * imageHeight) / (imageWidth * size.height)
        }
        
        maxScale = imageScale + 1
    }
    
    override func reset() {
        
        scroll.zoomScale = 1.0
        scroll.contentOffset = .zero
        scroll.contentSize = .zero
        scroll.maximumZoomScale = maxScale
        scroll.minimumZoomScale = minScale
    }
    
    @objc override func doupleTapGesture(_ gesture: UITapGestureRecognizer) {

        if scroll.zoomScale != 1 {
            scroll.setZoomScale(1.0, animated: true)
        } else {
            scroll.setZoomScale(imageScale, animated: true)

        }
    }
    
    @objc override func singleTapGesture( _ gesture: UITapGestureRecognizer) {
        if let handle = singleTapHandle {
            handle()
        }
    }
    
    func zoomViewToCenter() {
        
        let boundSize = self.bounds.size
        var frameToCenter = self.imageView.frame
        
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
        
        self.imageView.frame = frameToCenter
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
        imageView.frame = zoomFrame
        
        self.scroll.setZoomScale(1.0, animated: false)
//        maxScale = 3.0
    }
}

extension LQPhotoImagePreviewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        self.zoomViewToCenter()
    }
}

//MARK: - 视频预览 LQPhotoVideoPreviewCell
class LQPhotoVideoPreviewCell: LQPhotoPreviewCell {
    
    static let reuseIdentifier: String = "LQPhotoVideoPreviewCellReuseID"
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setImage(UIImage(named: LQPhotoIcon_video_play), for: .normal)
        button.setImage(UIImage(named: LQPhotoIcon_video_pause), for: .selected)
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return button
    }()
    
    lazy var player: AVPlayer = {
        
        let player = AVPlayer()
        
        return player
    }()
    
    lazy var playerLayer: AVPlayerLayer = {
        let playerl = AVPlayerLayer(player: self.player)
        
        
        return playerl
    }()
    
    var reqID: Int32 = -1
    var currentPlayItem: AVPlayerItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        self.layer.addSublayer(self.playerLayer)
        self.addSubview(self.playButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func configData(_ item: LQPhotoItem) {
        
        photo = item
        let manager = PHCachingImageManager.default()
        
        if self.reqID > 0 {
            let resID = PHImageRequestID(self.reqID)
            
            manager.cancelImageRequest(resID)
        }
        
        let size = self.bounds.size
        
        self.reqID = manager.requestImage(for: item.asset, targetSize: CGSize.init(width: size.width*LQAlbumWindowScale, height: size.height*LQAlbumWindowScale), contentMode: .aspectFill, options: nil) { (image, info) in
            guard let img = image else {
                return
            }
            
            self.imageView.image = img
        }
        
        prepareToPlayVideo()
    }
    
    override func reset() {
        if playButton.isSelected {
            playButton.isSelected = false
            player.pause()
        }
    }
    
    @objc func playAction() {
        playButton.isSelected = !playButton.isSelected
        
        if (playButton.isSelected) {
            player.play()
        } else {
            player.pause()
        }
        
        imageView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.playerLayer.frame = self.bounds
        self.imageView.frame = self.bounds
        self.playButton.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.playButton.center = CGPoint(x: self.bounds.size.width / 2.0, y: self.center.y)
    }
    
    
    func prepareToPlayVideo() {
        
        if let asset = photo?.asset {
            let manager = PHCachingImageManager.default()
            manager.requestPlayerItem(forVideo: asset, options: nil) { [weak self] playItem, info in
                
                self?.currentPlayItem = playItem
                if let p = playItem {
                    
                    self?.addObserverWithPlayerItem(p)
                    self?.player.replaceCurrentItem(with: p)
                }
            }
        }
    }
    
    func addObserverWithPlayerItem(_ item: AVPlayerItem?) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(playEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
    
    @objc func playEnd() {
        
        prepareToPlayVideo()
        playButton.isSelected = false
    }
}
