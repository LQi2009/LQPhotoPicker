//
//  LQPhotoTopBar.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/21.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

typealias LQPhotoTopBarActionHandler = (_ button: UIButton) -> Void
class LQPhotoTopBar: UIView {

    
    var backHandler: LQPhotoTopBarActionHandler?
    var selectedHandler: LQPhotoTopBarActionHandler?
    
    lazy var backgroundView: UIView = {
        
        let bgView = UIView()
        
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.8
        self.insertSubview(bgView, at: 0)
        return bgView
    }()
    
    lazy var backButton: UIButton = {
        
        let btn = UIButton(type: .custom)
        
//        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(UIImage.init(named: LQPhotoIcon_back), for: .normal)
        btn.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        self.addSubview(btn)
        return btn
    }()
    
    lazy var selectedButton: UIButton = {
        
        let btn = UIButton(type: .custom)
        
        btn.setTitleColor(UIColor.gray, for: .normal)
        btn.setBackgroundImage(UIImage.init(named: LQPhotoIcon_itemUnSelected), for: .normal)
        btn.setBackgroundImage(UIImage.init(named: LQPhotoIcon_itemSelected), for: .selected)
        btn.addTarget(self, action: #selector(selectedButtonAction), for: .touchUpInside)
        self.addSubview(btn)
        return btn
    }()
    
    @objc func selectedButtonAction(_ button: UIButton) {
        
        if let handler = self.selectedHandler {
            handler(button)
        }
    }
    
    @objc func backButtonAction(_ button: UIButton) {
        if let handler = self.backHandler {
            handler(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundView.frame = self.bounds
        self.backButton.frame = CGRect(x: 10, y: self.bounds.height - 40, width: 30, height: 30)
        self.selectedButton.frame = CGRect(x: self.frame.width - 40, y: self.bounds.height - 40, width: 30, height: 30)
    }
    
    func backWithHandler(_ handler: @escaping LQPhotoTopBarActionHandler) {
        self.backHandler = handler
    }
    
    func selectedWithHandler(_ handler: @escaping LQPhotoTopBarActionHandler) {
        self.selectedHandler = handler
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
