//
//  MasterViewControllerS.swift
//  ios-code-challenge
//
//  Created by Joe Rocca on 5/31/19.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: BaseTableViewController, CLLocationManagerDelegate, UISearchResultsUpdating {
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
        
        navigationItem.searchController = searchController
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            loadData()
        }
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
    
    override func onScrollToBottom() {
        if !loadingPage {
            loadingPage = true
            //This will keep trying to page when we're on the last page, which is not ideal. I would account for that if I was doing an app that is intended to be released
            loadNextPage()
        }
    }
}
