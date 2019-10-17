//
//  MasterViewControllerS.swift
//  ios-code-challenge
//
//  Created by Joe Rocca on 5/31/19.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import UIKit

class FavoritesViewController: BaseTableViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let dataSource = dataSource {
            FavoriteService.shared.runWhenInitialized {
                dataSource.setObjects(FavoriteService.shared.favorites)
                self.tableView.reloadData()
            }
        }
    }
}
