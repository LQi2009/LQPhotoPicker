//
//  LQAlbumTableViewController.swift
//  LQAlbumFinder
//
//  Created by Artron_LQQ on 2017/8/22.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit

class LQAlbumTableViewController: UITableViewController {

    var dataSources: [LQAlbumItem] = []
    
    deinit {
        print("LQAlbumTableViewController deinit")
    }
    
//    init() {
//        super.init(style: .plain)
//        
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.title = "相册"
        setupNavBar()
        
        self.tableView.register(LQAlbumTableViewCell.self, forCellReuseIdentifier: "LQAlbumTableViewCellReuseIdentifier")
        self.tableView.tableFooterView = UIView()
        
        if LQAlbumManager.isAuthorized {
            if self.dataSources.count <= 0 {
                
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
                        self.tableView.reloadData()
                    }
                }
            }

        }
    }

    func setupNavBar() {
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.frame = CGRect(x: self.view.frame.width - 60, y: 20, width: 50, height: 44)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        let leftBar = UIBarButtonItem(customView: UIView())
        //        self.navigationController?.navigationItem.leftBarButtonItem = leftBar
        self.navigationItem.leftBarButtonItem = leftBar
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSources.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LQAlbumTableViewCellReuseIdentifier", for: indexPath) as! LQAlbumTableViewCell

        // Configure the cell...
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
        let photo = LQPhotoCollectionViewController()
        photo.albumItem = item
        self.navigationController?.pushViewController(photo, animated: true)
    }

    func cancelButtonAction() {
        
        self.dismiss(animated: true, completion: nil)
    }

}
