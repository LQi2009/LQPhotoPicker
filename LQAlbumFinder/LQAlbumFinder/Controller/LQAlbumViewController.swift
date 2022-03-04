//
//  LQAlbumViewController.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/19.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//
// 相册列表视图

import UIKit

class LQAlbumViewController: UITableViewController {

    private var dataSources: [LQAlbumItem] = []
    
    private lazy var activity: UIActivityIndicatorView = {
        
        let acti = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        acti.hidesWhenStopped = true
        acti.center = self.view.center
        self.view.addSubview(acti)
        return acti;
    }()
    
    deinit {
        print("LQAlbumTableViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.title = "相册"
        setupNavBar()
        
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

    private func setupNavBar() {
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.frame = CGRect(x: self.view.frame.width - 60, y: 20, width: 50, height: 44)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        let leftBar = UIBarButtonItem(customView: UIView())
        self.navigationItem.leftBarButtonItem = leftBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LQAlbumTableViewCellReuseIdentifier", for: indexPath) as! LQAlbumCell
        
        let item = dataSources[indexPath.row]
        
        cell.configWith(item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
