//
//  MasterViewControllerS.swift
//  ios-code-challenge
//
//  Created by Joe Rocca on 5/31/19.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import UIKit
import CoreLocation

class MasterViewController: UITableViewController, CLLocationManagerDelegate, UISearchResultsUpdating {
    
    var detailViewController: DetailViewController?
    
    lazy private var dataSource: NXTDataSource? = {
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
            
            if !strongSelf.loadingPage && shouldScroll {
                strongSelf.loadingPage = true
                //This will keep trying to page when we're on the last page, which is not ideal. I would account for that if I was doing an app that is intended to be released
                strongSelf.loadNextPage()
            }
        }
        
        return dataSource
    }()
    
    lazy private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        
        locationManager.delegate = self
       
        return locationManager
    }()
    
    lazy private var searchController: UISearchController = {
        let searchController = UISearchController()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search businesses"
        searchController.obscuresBackgroundDuringPresentation = false
        
        return searchController
    }()
    
    private var currentSearchId: String? = nil
    private var currentQuery = YLPSearchQuery(location: "5550 West Executive Dr. Tampa, FL 33609")
    private var loadingPage = false //We should probably make this atomic, but this should be fine for an assessment

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        navigationItem.searchController = searchController
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            loadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? false
        super.viewDidAppear(animated)
    }
    
    // MARK: - Search
    func updateSearchResults(for searchController: UISearchController) {
        //Ideally, we would want a loading overlay (especially with our search delay), but for now, I'ld like to avoid making this overly complex (we'll add it in version 2.0)
        let thisSearchId = UUID().uuidString
        currentSearchId = thisSearchId
        //Avoid hammering the API and our battery and our data plan�
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            //If the searchId is different from what we put in the term variable, the user is actively typing. We can let the next async task handle the search.
            if self.currentSearchId == thisSearchId {
                self.loadData(search: searchController.searchBar.text)
            }
        }
    }
    
    // MARK: - Location Services
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        loadData()
    }
    
    // MARK: - Data Update
    func loadNextPage() {
        currentQuery.page = currentQuery.page + 1
        
        AFYelpAPIClient.shared().search(with: currentQuery, completionHandler: { [weak self] (searchResult, error) in
            guard let strongSelf = self,
                let dataSource = strongSelf.dataSource,
                let businesses = searchResult?.businesses else {
                    return
            }
            
            var appendList = dataSource.objects
            appendList?.append(contentsOf: businesses)
            
            dataSource.setObjects(appendList)
            strongSelf.tableView.reloadData()
            strongSelf.loadingPage = false
        })
    }
    
    func loadData(search: String? = nil) {
        currentQuery = YLPSearchQuery(location: "5550 West Executive Dr. Tampa, FL 33609")
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let location = locationManager.location?.coordinate {
                currentQuery = YLPSearchQuery(latitude: NSNumber(value: location.latitude), andLongitude: NSNumber(value: location.longitude))
            }
            
            if let search = search, search != "" {
                currentQuery.term = search
            }
            
            runYelpQuery(currentQuery)
        }
        else {
            if let search = search, search != "" {
                currentQuery.term = search
            }
            
            runYelpQuery(currentQuery)
        }
    }
    
    func runYelpQuery(_ query: YLPSearchQuery) {
        AFYelpAPIClient.shared().search(with: query, completionHandler: { [weak self] (searchResult, error) in
            guard let strongSelf = self,
                let dataSource = strongSelf.dataSource,
                let businesses = searchResult?.businesses else {
                    return
            }
            dataSource.setObjects(businesses)
            strongSelf.tableView.reloadData()
        })
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

}
