//
//  LQAlbumViewController.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/19.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//
// 相册列表视图

import UIKit

class LQAlbumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var dataSources: [LQAlbumItem] = []
    
    private var isNavigationBarHidden: Bool = false
    
    private lazy var activity: UIActivityIndicatorView = {
        
        let acti = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        acti.hidesWhenStopped = true
        acti.center = self.view.center
        self.view.addSubview(acti)
        return acti;
    }()
    
    private lazy var topView: UIView = {
        
        let top = UIView()
        
        top.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        view.addSubview(top)
        return top
    }()
    
    private lazy var cancelButton: UIButton = {
        
        let cancelButton = UIButton(type: .custom)
        
        cancelButton.setImage(UIImage(named: LQPhotoIcon_cancel), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        
        topView.addSubview(cancelButton)
        return cancelButton
    }()
    
    private lazy var titleLabel: UILabel = {
        
        let lb = UILabel()
        
        lb.textColor = UIColor.white
        lb.textAlignment = .center
        lb.font = UIFont.boldSystemFont(ofSize: 18)
        topView.addSubview(lb)
        return lb
    }()
    
    lazy var tableView: UITableView = {
        
        let table = UITableView(frame: .zero, style: .plain)
        
        table.delegate = self
        table.dataSource = self
//        view.addSubview(table)
        view.insertSubview(table, belowSubview: topView)
        return table
    }()
    
    deinit {
        print("LQAlbumTableViewController deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let nav = self.navigationController {
            isNavigationBarHidden = nav.isNavigationBarHidden
            nav.isNavigationBarHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let nav = self.navigationController {
            nav.isNavigationBarHidden = isNavigationBarHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        titleLabel.text = "相册"
        
//        self.tableView.tableHeaderView = self.topView
        self.tableView.register(LQAlbumCell.self, forCellReuseIdentifier: "LQAlbumTableViewCellReuseIdentifier")
        self.tableView.tableFooterView = UIView()
        
        if LQAlbumManager.isAuthorized {
            if self.dataSources.count <= 0 {
                self.activity.startAnimating()
                DispatchQueue(label: "queue").async {
                    let albums = LQAlbumManager.shared.fetchAlbums()
                    
                    for item in albums {
                        if item.name == "相机胶卷" {
                            self.dataSources.insert(item, at: 0)
                        } else {
                            self.dataSources.append(item)
                        }
                    }
                    DispatchQueue.main.async {
                        self.activity.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
        let theight =  (44 + self.view.safeAreaInsets.top)
        topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: theight)
        cancelButton.frame = CGRect(x: self.view.frame.width - 60.0, y: theight - 40, width: 50.0, height: 30.0)
        titleLabel.frame = CGRect(x: 70, y: theight - 40.0, width: self.view.frame.width - 140.0, height: 30.0)
        
        tableView.contentInset = UIEdgeInsets(top: theight, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LQAlbumTableViewCellReuseIdentifier", for: indexPath) as! LQAlbumCell
        
        let item = dataSources[indexPath.row]
        
        cell.configWith(item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = dataSources[indexPath.row]
        let photo = LQPhotoViewController()
        photo.albumItem = item
        self.navigationController?.pushViewController(photo, animated: true)
    }
    
    @objc func cancelButtonAction() {
        
        self.dismiss(animated: true, completion: nil)
    }
}
