//
//  LQPhotoPreviewController.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/19.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

typealias LQPhotoCurrentIndexPathHandler = (_ indexPath: IndexPath) -> Void
typealias LQPhotoOriginalStateChangedHandler = (_ isOriginal: Bool) -> Void
typealias LQPhotoSelectedIndexPathHandler = (_ indexPath: IndexPath, _ isSelected: Bool) -> Void


class LQPhotoPreviewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var dataSource: [LQPhotoItem] = []
    var selectedItems: [LQPhotoItem] = []
    var maxSelectedNumber: Int = 0
    var isPreview: Bool = false
    
    var beginIndexPath: IndexPath! = IndexPath(item: 0, section: 0){
        didSet{
            currentIndexPath = beginIndexPath
        }
    }
    //MARK: - private perporty
    fileprivate var currentIndexPath: IndexPath! = IndexPath(item: 0, section: 0)
    private var beginDragOffset: CGPoint = .zero
    
    private var selectedHandler: LQPhotoSelectedHandler?
    private var currentIndexPathHandler: LQPhotoCurrentIndexPathHandler?
    private var originalStateChangedHandler: LQPhotoOriginalStateChangedHandler?
    private var selectedIndexPathHandler: LQPhotoSelectedIndexPathHandler?
    
    lazy var topBar: LQPhotoTopBar = {
        
        let bar = LQPhotoTopBar()
        self.view.addSubview(bar)
        return bar
    }()
    
    lazy var bottomBar: LQPhotoBottomBar = {
        
        let bar = LQPhotoBottomBar()
        self.view.addSubview(bar)
        return bar
    }()
    
    fileprivate var isBarHidden: Bool = false
    fileprivate var isBarDidHidden: Bool = false
    
    deinit {
        print("LQPhotoPreviewController deinit")
    }
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.00001
        layout.minimumInteritemSpacing = 0.00001
        
        let collection = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.isPagingEnabled = true
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
        
        if let handler = currentIndexPathHandler {
            handler(currentIndexPath)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        collectionView.register(LQPhotoImagePreviewCell.self, forCellWithReuseIdentifier: LQPhotoImagePreviewCell.reuseIdentifier)
        collectionView.register(LQPhotoVideoPreviewCell.self, forCellWithReuseIdentifier: LQPhotoVideoPreviewCell.reuseIdentifier)
        
        self.layoutTopBar()
        self.setupBottomBar()
        
        for item in selectedItems {
            if item.isOriginal {
                self.bottomBar.originButton.isSelected = true
                break
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let theight =  (64 + self.view.safeAreaInsets.bottom)
        topBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: theight)
        
        let height =  (49 + self.view.safeAreaInsets.bottom)
        bottomBar.frame = CGRect(x: 0, y: self.view.frame.height - height, width: self.view.frame.width, height:height)
        collectionView.frame = self.view.bounds
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let index = beginIndexPath {
            
            collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
        }
    }
    
    func didSelectedItems(_ handler: @escaping LQPhotoSelectedHandler) {
        selectedHandler = handler
    }
    
    func indexPathChanged(_ handler: @escaping LQPhotoCurrentIndexPathHandler) {
        currentIndexPathHandler = handler
    }
    
    func selectedIndexPath(_ handler: @escaping LQPhotoSelectedIndexPathHandler) {
        selectedIndexPathHandler = handler
    }

    func originalStateChanged(_ handler: @escaping LQPhotoOriginalStateChangedHandler) {
        originalStateChangedHandler = handler
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = dataSource[indexPath.row]
        var reuseid = ""
        if item.isVideo {
            reuseid = LQPhotoVideoPreviewCell.reuseIdentifier
        } else {
            reuseid = LQPhotoImagePreviewCell.reuseIdentifier
        }
        
        if isPreview == false {
            item.indexPath = indexPath
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseid, for: indexPath)
        
        if let pcell = cell as? LQPhotoPreviewCell {
            
            pcell.configData(item)
            
            pcell.singleTapAction {[weak self] in
                self?.topBarHidden()
            }
        }
        
        return cell
    }
    ///
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cel = cell as? LQPhotoPreviewCell {
            cel.reset()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        currentIndexPath = indexPath
        setSelectedButtonState(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func springAnimation(_ view: UIView) {
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyAnimation.values = [0.9, 0.84, 0.8, 0.9, 1.0, 1.1, 1.2, 1.1, 1.0]
        keyAnimation.repeatCount = 1
        keyAnimation.isRemovedOnCompletion = false
        keyAnimation.fillMode = CAMediaTimingFillMode.forwards
        keyAnimation.duration = 0.6
        keyAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        view.layer.add(keyAnimation, forKey: "keyFrameAnima")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        
        self.topBar.backWithHandler {[weak self] (button) in
            self?.backButtonAction(button)
        }
        
        self.topBar.selectedWithHandler {[weak self] (button) in
            self?.topButtonSelectedAction(button)
        }
        
        setSelectedButtonState(beginIndexPath)
    }
    
    @objc fileprivate func backButtonAction(_ button: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func topButtonSelectedAction(_ button: UIButton) {
        
        if maxSelectedNumber > 0 &&  selectedItems.count == maxSelectedNumber && !button.isSelected {
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
        
        if let handle = selectedIndexPathHandler {
            
            if isPreview {
                let item = dataSource[currentIndexPath.row]
                handle(item.indexPath!, button.isSelected)
                
            } else {
                handle(currentIndexPath, button.isSelected)
            }
        }
    }
    
    private func selectedItem(_ isSelected: Bool, indexPath: IndexPath) {
        
        let item = dataSource[indexPath.row]
        item.isSelected = isSelected
        item.isOriginal = bottomBar.originButton.isSelected
        
        if isSelected {
            if !selectedItems.contains(item) {
                item.selectedNumber = selectedItems.count + 1
                selectedItems.append(item)
            }
        } else {
            
            let index = selectedItems.firstIndex(of: item)
            if let ix = index {
                selectedItems.remove(at: ix)
            }
            
            for i in 0..<selectedItems.count {
                let im = selectedItems[i]
                im.selectedNumber = i + 1
            }
        }
                
        var selectedEnable = true
        if selectedItems.count == maxSelectedNumber {
            selectedEnable = false
        }
        
        for i in 0..<dataSource.count {
            let im = dataSource[i]
            if im.isSelected == false {
                im.isSelectedEnable = selectedEnable
            }
        }
        
        setBottomViewState()
    }
    
    fileprivate func setSelectedButtonState(_ indexPath: IndexPath?) {
        
        if let index = indexPath {
            
            let item = dataSource[index.row]
            topBar.selectedButton.isSelected = item.isSelected
            if item.selectedNumber != -1 {
                topBar.selectedButton.setTitle("\(item.selectedNumber)", for: .selected)
            }
            
            self.setBottomViewState()
        }
    }
}

//MARK: - Bottom Tool Bar
extension LQPhotoPreviewController {
    
    func setupBottomBar () {
        
        if self.selectedItems.count == 0 {
            self.bottomBar.commitButton.isEnabled = false
            
        } else {
            self.bottomBar.commitButton.setTitle("确定(\(selectedItems.count))", for: .normal)
            self.bottomBar.commitButton.isEnabled = true
        }
        
        self.bottomBar.originWithHandler {[weak self] (button) in
            self?.originButtonAction(button)
        }
        
        self.bottomBar.commitWithHandler { (button) in
            self.sendButtonAction()
        }
    }
    
    func editSelectedItemAction() {
        
    }
    
    func originButtonAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        
        for item in selectedItems {
            item.isOriginal = button.isSelected
        }
        
        if let handler = originalStateChangedHandler {
            
            handler(button.isSelected)
        }
        
        if button.isSelected  && !topBar.selectedButton.isSelected {
            
            topButtonSelectedAction(topBar.selectedButton)
        }
    }
    
    @objc func sendButtonAction() {
        if selectedItems.count == 0 {
            let item = dataSource[currentIndexPath.row]
            selectedItems.append(item)
        }
        
        if let handle = selectedHandler {
            handle(selectedItems)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func setBottomViewState() {
        if selectedItems.count > 0 {
            bottomBar.commitButton.isEnabled = true
            bottomBar.commitButton.setTitle("确定(\(selectedItems.count))", for: .normal)
        } else {
            bottomBar.commitButton.isEnabled = false
            bottomBar.commitButton.setTitle("确定", for: .normal)
        }
    }
    
    override var shouldAutorotate: Bool {
        
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
