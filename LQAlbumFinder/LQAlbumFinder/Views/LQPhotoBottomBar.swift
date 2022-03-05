//
//  LQPhotoBottomBar.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/19.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

typealias LQPhotoBottomBarActionHandler = (_ button: UIButton) -> Void
class LQPhotoBottomBar: UIView {

    var actionEnable: Bool = false {
        didSet {
            self.previewButton.isEnabled = actionEnable
            self.commitButton.isEnabled = actionEnable
        }
    }
    
    var originHandler: LQPhotoBottomBarActionHandler?
    var previewHandler: LQPhotoBottomBarActionHandler?
    var commitHandler: LQPhotoBottomBarActionHandler?
    
    lazy var backgroundView: UIView = {
        
        let bgView = UIView()
        
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.8
        self.insertSubview(bgView, at: 0)
        return bgView
    }()
    
    lazy var previewButton: UIButton = {
        
        let btn = UIButton(type: .custom)
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("预览", for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .disabled)
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(previewButtonAction), for: .touchUpInside)
        self.addSubview(btn)
        return btn
    }()
    
    lazy var originButton: UIButton = {
        
        let originBtn = UIButton(type: .custom)
        
        originBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        originBtn.setTitle("原图", for: .normal)
        originBtn.setTitleColor(UIColor.lightGray, for: .disabled)
        originBtn.setImage(UIImage.init(named: LQPhotoIcon_originalUnSelected), for: .normal)
        originBtn.setImage(UIImage.init(named: LQPhotoIcon_originalSelected), for: .selected)
        originBtn.addTarget(self, action: #selector(originButtonAction), for: .touchUpInside)
        originBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        self.addSubview(originBtn)
        
        return originBtn
    }()
    
    lazy var commitButton: UIButton = {
        
        let sendBtn = UIButton(type: .custom)
        
        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sendBtn.setTitle("确定", for: .normal)
        if let bg = UIImage.init(named: LQPhotoIcon_commitButtonBg) {
            sendBtn.setBackgroundImage(bg.stretchableImage(withLeftCapWidth: Int(bg.size.width/2.0), topCapHeight: Int(bg.size.height)), for: .normal)
        }
        
        sendBtn.setTitleColor(UIColor.lightGray, for: .disabled)
        sendBtn.isEnabled = false
        sendBtn.addTarget(self, action: #selector(commitButtonAction), for: .touchUpInside)
        self.addSubview(sendBtn)
        
        return sendBtn
    }()
    
    func resetCommitButtonTitle(_ title: String) {
        
        commitButton.setTitle(title, for: .normal)
    }
    
    func commitWithHandler(_ handler: @escaping LQPhotoBottomBarActionHandler) {
        self.commitHandler = handler
    }
    
    func originWithHandler(_ handler: @escaping LQPhotoBottomBarActionHandler) {
        self.originHandler = handler
    }
    
    func previewWithHandler(_ handler: @escaping LQPhotoBottomBarActionHandler) {
        self.previewHandler = handler
    }
    @objc func commitButtonAction(_ button: UIButton) {
        if let handler = self.commitHandler {
            handler(button)
        }
    }
    @objc func originButtonAction(_ button: UIButton) {
        if let handler = self.originHandler {
            handler(button)
        }
    }
    @objc func previewButtonAction(_ button: UIButton) {
        if let handler = self.previewHandler {
            handler(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundView.frame = self.bounds
        if self.previewHandler != nil {
            self.previewButton.frame = CGRect(x: 10, y: 0, width: 50, height: 49)
        }
        
        self.originButton.frame = CGRect(x: self.center.x - 50, y: 0, width: 100, height: 49)
//        self.originButton.bounds = CGRect(x: 0, y: 0, width: 100, height: 49)
//        self.originButton.center = CGPoint(x: self.frame.width/2.0, y: self.frame.height/2.0)
        self.commitButton.frame = CGRect(x: self.frame.width - 100, y: 5, width: 80, height: 39)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
//    func isNotchScreen() -> Bool {
//        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiomPhone {
//            return NOSTR
//        }
//    }

}
