//
//  LQAlbumViewController.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/19.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

class LQAlbumViewController: UITableViewController {

    var dataSources: [LQAlbumItem] = []
    
    lazy var activity: UIActivityIndicatorView = {
        
        let acti = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
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

    func setupNavBar() {
        
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

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
