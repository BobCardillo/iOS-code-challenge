//
//  BaseTableViewController.swift
//  ios-code-challenge
//
//  Created by Ryan Novak on 2019-10-12.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import Foundation

class BaseTableViewController: UITableViewController {
    var detailViewController: DetailViewController?
    
    lazy internal var dataSource: NXTDataSource? = {
        guard let dataSource = NXTDataSource(objects: nil) else { return nil }
        dataSource.tableViewDidReceiveData = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
        }
        
        dataSource.tableViewDidSelectCell = { [weak self] sender in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: "showDetail", sender: sender)
        }
        
        dataSource.tableViewDidScroll = { [weak self] in
            guard let strongSelf = self, let tableView = strongSelf.tableView, dataSource.objects.count > 0 else {
                return
            }
            
            let shouldScroll = (tableView.contentOffset.y + tableView.frame.height) > (tableView.contentSize.height - 250)
            
            if shouldScroll {
                strongSelf.onScrollToBottom()
            }
        }
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? false
        super.viewDidAppear(animated)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let controller = (segue.destination as? UINavigationController)?.viewControllers.first as? DetailViewController,
                let object = dataSource?.objects[indexPath.row] as? YLPBusiness else {
                return
            }
            controller.setDetailItem(newDetailItem: object)
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    open func onScrollToBottom() {}
}
