//
//  LQPhotoPreviewController.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/8/24.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit

private let reuseIdentifier = "LQPhotoPreviewCellReuseIdentifier"
typealias LQPhotoPreviewController_currentIndexPathHandler = (_ indexPath: IndexPath) -> Void
typealias LQPhotoPreviewControllerSelectedIndexPathHandler = (_ indexPath: IndexPath, _ isSelected: Bool, _ isOriginal: Bool) -> Void

class LQPhotoPreviewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var dataSource: [LQPhotoItem] = []
    var selectedItems: [LQPhotoItem] = []
    var maxSelectedNumber: Int = 9
    var isPreview: Bool = false
    
    var beginIndexPath: IndexPath! = IndexPath(item: 0, section: 0){
        didSet{
            currentIndexPath = beginIndexPath
        }
    }
    //MARK: - private perporty
    fileprivate var currentIndexPath: IndexPath! = IndexPath(item: 0, section: 0)
    private var beginDragOffset: CGPoint = .zero
    private var currentIndexPathHandle: LQPhotoPreviewController_currentIndexPathHandler?
    fileprivate var selectedIndexPathHandle: LQPhotoPreviewControllerSelectedIndexPathHandler?
    var selectedHandle: LQPhotoSelectedHandle?
    fileprivate var topBar: UIView!
    fileprivate var bottomBar: UIView!
    fileprivate var commitButton: UIButton!
    fileprivate var originButton: UIButton!
    
    fileprivate var isBarHidden: Bool = false
    fileprivate var isBarDidHidden: Bool = false
    fileprivate var selectedButton: UIButton!
    
    deinit {
        print("LQPhotoPreviewController deinit")
    }
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        
        self.view.addSubview(collection)
        
        return collection
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
       collectionView.register(LQPhotoPreviewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.layoutTopBar()
        self.layoutBottomView()
        
        for item in selectedItems {
            if item.isOriginal {
                originButton.isSelected = true
                break
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        topBar.frame = CGRect(x: 0, y: 0, width: LQAlbumWindowWidth, height: 64)
        
        collectionView.frame = self.view.bounds
        if let index = beginIndexPath {
            
            collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didSelectedItems(_ handle: @escaping LQPhotoSelectedHandle) {
        selectedHandle = handle
    }
    
    func indexPathChangedHandle(_ handle: @escaping LQPhotoPreviewController_currentIndexPathHandler) {
        currentIndexPathHandle = handle
    }
    
    func selectedIndexPath(_ handle: @escaping LQPhotoPreviewControllerSelectedIndexPathHandler) {
        selectedIndexPathHandle = handle
    }

    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LQPhotoPreviewCell
        
        let item = dataSource[indexPath.section]
        
        if isPreview == false {
            item.indexPath = indexPath
        }
        
        cell.configData(item)
        
        cell.singleTapAction {[weak self] in
            self?.topBarHidden()
        }
        
        return cell
    }
    ///

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let cel = cell as! LQPhotoPreviewCell
        cel.reset()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt; \(indexPath.section)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return self.view.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
 
    var isBeginDrag: Bool = false
    var effectiveSlidingDistance: CGFloat = 30.0
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        isBeginDrag = true
        beginDragOffset = scrollView.contentOffset
    }
    
//    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//
//        if isBeginDrag == false {
//            return
//        }
//
//        isBeginDrag = false
//        var currentIndex: Int = currentIndexPath.row
//
//        let currentOffset = scrollView.contentOffset.x - beginDragOffset.x
//        //向左滑动
//        if currentOffset - effectiveSlidingDistance > 0 {
//            // 如果滑动达到一定幅度, 则滚动到下一个
//            currentIndex += 1
//            if currentIndex >= dataSource.count {
//                currentIndex = dataSource.count - 1
//            }
//        } else if currentOffset + effectiveSlidingDistance < 0  {
//            // 如果滑动达到一定幅度, 则滚动到前一个
//            currentIndex -= 1
//            if currentIndex < 0 {
//                currentIndex = 0
//            }
//        }
//
//        let collection = scrollView as! UICollectionView
//        currentIndexPath = IndexPath(item: currentIndex, section: 0)
//        collection.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: true)
//
//        setSelectedButtonState(currentIndexPath)
//    }
 func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        return
    
    
        var currentIndex: Int = currentIndexPath.section
    
    if isBeginDrag {
        
        let currentOffset = scrollView.contentOffset.x - beginDragOffset.x
        //向左滑动
        if currentOffset - effectiveSlidingDistance > 0 {
            // 如果滑动达到一定幅度, 则滚动到下一个
            currentIndex += 1
            if currentIndex >= dataSource.count {
                currentIndex = dataSource.count - 1
            }
        } else if currentOffset + effectiveSlidingDistance < 0  {
            // 如果滑动达到一定幅度, 则滚动到前一个
            currentIndex -= 1
            if currentIndex < 0 {
                currentIndex = 0
            }
        }
    }
    
    let collection = scrollView as! UICollectionView
    currentIndexPath = IndexPath(item: 0, section: currentIndex)
    collection.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: true)
    
    setSelectedButtonState(currentIndexPath)
    
    if isBeginDrag {
        isBeginDrag = false
    }
}
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func springAnimation(_ view: UIView) {
        
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
//MARK: - TopToolBar
extension LQPhotoPreviewController {
    
    fileprivate func topBarHidden() {
        
        var alpha: CGFloat = 0
        isBarHidden = !isBarHidden
        
        if isBarHidden && !isBarDidHidden {
            alpha = 0
        } else if !isBarHidden && isBarDidHidden {
            alpha = 0.8
        }
        
        UIView.animate(withDuration: 0.2, animations: { 
            self.topBar.alpha = alpha
            self.bottomBar.alpha = alpha
        }) { (finish) in
            self.isBarDidHidden = !self.isBarDidHidden
        }
    }
    
    fileprivate func layoutTopBar() {
        
        let topView = UIView()
        topView.frame = CGRect(x: 0, y: 0, width: LQAlbumWindowWidth, height: 64)
        self.view.addSubview(topView)
        topBar = topView
        
        let bgView = UIView()
        bgView.frame = topView.bounds
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.8
        topView.addSubview(bgView)
        
        let backButton = UIButton(type: .custom)
        backButton.setBackgroundImage(UIImage.init(named: "previewTopBar_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButton.frame = CGRect(x: 10, y: 12, width: 22, height: 40)
        topView.addSubview(backButton)
        
        let selectButton = UIButton(type: .custom)
        selectButton.setBackgroundImage(UIImage.init(named: "selectButton_unselectedState"), for: .normal)
        selectButton.setBackgroundImage(UIImage.init(named: "selectButton_selectedStateBackground"), for: .selected)
        selectButton.addTarget(self, action: #selector(selectedButtonAction), for: .touchUpInside)
        
        selectButton.frame = CGRect(x: LQAlbumWindowWidth - 40, y: (64 - 30)/2.0, width: 30, height: 30)
        topView.addSubview(selectButton)
        selectedButton = selectButton
        setSelectedButtonState(beginIndexPath)
    }
    
    @objc fileprivate func backButtonAction(_ button: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func selectedButtonAction(_ button: UIButton) {
        if selectedItems.count == maxSelectedNumber && !button.isSelected {
            let alert = UIAlertController(title: "您最多只能选择\(maxSelectedNumber)张照片!", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "我知道了", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        button.isSelected = !button.isSelected
        if button.isSelected {
            
            self.springAnimation(button)
        }
        
        selectedItem(button.isSelected, indexPath: currentIndexPath)
        setSelectedButtonState(currentIndexPath)
        
        if let handle = selectedIndexPathHandle {
            
            if isPreview {
                let item = dataSource[currentIndexPath.section]
                handle(item.indexPath!, button.isSelected, originButton.isSelected)
                
            } else {
               handle(currentIndexPath, button.isSelected, originButton.isSelected)
            }
        }
    }
    
    private func selectedItem(_ isSelected: Bool, indexPath: IndexPath) {
        
        let item = dataSource[indexPath.section]
        item.isSelected = isSelected
        item.isOriginal = originButton.isSelected
        
        if isSelected {
            
            item.selectedNumber = selectedItems.count + 1
            selectedItems.append(item)
        } else {
            
            let index = selectedItems.index(of: item)
            if let ix = index {
                selectedItems.remove(at: ix)
            }
            
            for i in 0..<selectedItems.count {
                let im = selectedItems[i]
                im.selectedNumber = i + 1
                selectedItems[i] = im
                
                let index = dataSource.index(of: im)
                dataSource[index!] = im
            }

        }
        
        dataSource[indexPath.section] = item
        
        var selectedEnable = true
        if selectedItems.count == 9 {
            selectedEnable = false
        }
        
        for i in 0..<dataSource.count {
            let im = dataSource[i]
            if im.isSelected == false {
                im.isSelectedEnable = selectedEnable
                dataSource[i] = im
            }
        }
        
        setBottomViewState()
    }
    
    fileprivate func setSelectedButtonState(_ indexPath: IndexPath?) {
        
        if let index = indexPath {
            
            let item = dataSource[index.section]
            selectedButton.isSelected = item.isSelected
            if item.selectedNumber != -1 {
                selectedButton.setTitle("\(item.selectedNumber)", for: .selected)
            }
            print(item.selectedNumber)
        }
        
    }
}

//MARK: - Bottom Tool Bar
extension LQPhotoPreviewController {
    
    func layoutBottomView() {
        
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: LQAlbumWindowHeight - 49, width: LQAlbumWindowWidth, height: 49)
//        bottomView.backgroundColor = UIColor.white
        self.view.addSubview(bottomView)
        bottomBar = bottomView
        
        let bgView = UIView()
        bgView.frame = bottomView.bounds
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.8
        bottomView.addSubview(bgView)
        
//        let editButton = UIButton(type: .custom)
//        editButton.frame = CGRect(x: 10, y: 0, width: 50, height: 49)
//        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        editButton.setTitle("编辑", for: .normal)
//        editButton.isEnabled = false
//        editButton.addTarget(self, action: #selector(editSelectedItemAction), for: .touchUpInside)
//        bottomView.addSubview(editButton)
        
        let originBtn = UIButton(type: .custom)
        originBtn.bounds = CGRect(x: 0, y: 7, width: 80, height: 30)
//        bottomView.frame.width/2.0
        originBtn.center = CGPoint(x: 50, y: bottomView.frame.height/2.0)
        originBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        originBtn.setTitle("原图", for: .normal)
        originBtn.setImage(UIImage.init(named: "unSelectedBG"), for: .normal)
        originBtn.setImage(UIImage.init(named: "selectedBG"), for: .selected)
        originBtn.addTarget(self, action: #selector(originButtonAction), for: .touchUpInside)
        bottomView.addSubview(originBtn)
        originButton = originBtn
        
        let sendBtn = UIButton(type: .custom)
        sendBtn.frame = CGRect(x: bottomView.frame.width - 70, y: 4, width: 60, height: 41)
        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sendBtn.setTitle("确定(\(selectedItems.count))", for: .normal)
        sendBtn.setBackgroundImage(UIImage.init(named: "green_btnBG"), for: .normal)
//        sendBtn.isEnabled = false
        sendBtn.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        bottomView.addSubview(sendBtn)
        commitButton = sendBtn
    }
    
    func editSelectedItemAction() {
        
    }
    
    func originButtonAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        
        if button.isSelected && selectedButton.isSelected == false  {
            selectedButtonAction(selectedButton)
        } else {
            
            if let handle = selectedIndexPathHandle {
                
                if isPreview {
                    let item = dataSource[currentIndexPath.section]
                    handle(item.indexPath!, selectedButton.isSelected, originButton.isSelected)
                    
                } else {
                    handle(currentIndexPath, selectedButton.isSelected, originButton.isSelected)
                }
            }
        }
        
        
        
        
        
        for item in selectedItems {
            item.isOriginal = button.isSelected
        }
    }
    
    func sendButtonAction() {
        if selectedItems.count == 0 {
            let item = dataSource[currentIndexPath.section]
            selectedItems.append(item)
        }
        
        if let handle = selectedHandle {
            handle(selectedItems)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func setBottomViewState() {
        if selectedItems.count > 0 {
            commitButton.setTitle("确定(\(selectedItems.count))", for: .normal)
        } else {
            commitButton.setTitle("确定", for: .normal)
        }
    }
}
