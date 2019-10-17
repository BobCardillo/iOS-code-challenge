//
//  DetailViewController.swift
//  ios-code-challenge
//
//  Created by Joe Rocca on 5/31/19.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailCategoriesLabel: UILabel!
    @IBOutlet weak var detailRatingLabel: UILabel!
    @IBOutlet weak var detailReviewCountLabel: UILabel!
    @IBOutlet weak var detailPriceLabel: UILabel!
    @IBOutlet weak var detailThumbnailImage: UIImageView!
    lazy private var favoriteBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star-Outline"), style: .plain, target: self, action: #selector(onFavoriteBarButtonSelected(_:)))

    @objc var detailItem: YLPBusiness?
    
    private var _favorite: Bool = false
    private var isFavorite: Bool {
        get {
            return _favorite
        } 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        navigationItem.rightBarButtonItems = [favoriteBarButtonItem]
    }
    
    private func configureView() {
        guard let detailItem = detailItem else { return }
        
        loadViewIfNeeded()
        
        detailNameLabel.text = detailItem.name
        //I added some extra text here to these labels brcause it's not really clear what is what from just the data. While I'm not terribly concerned about presentation in this challenge (that's what designers are for), I thought this might be a simple way of disambiguating the fields to make it easier to verify everything is being presented correctly.
        //These field labels are not localizable when written this way. Since there is no strings file in the project, I'm assuming we're not going to worry about it for the challenge
        //What I get back from the Yelp API _shouldn't_ contain nulls. However, if this were an actual product, I would probably want to not default to an empty string.
        detailCategoriesLabel.text = "Categories: \(detailItem.categories.map{ $0["title"] ?? "" }.joined(separator: ", "))"
        detailRatingLabel.text = "Rating: \(detailItem.rating.stringValue)"
        detailReviewCountLabel.text = "Reviews: \(detailItem.reviewCount.stringValue)"
        detailPriceLabel.text = "Price: \(detailItem.price)"
        
        //Holding off on thumbnail like on task 1
        //Pretty much the same process for getting an image and adding to UIImageView applies here, but in Swift rather than Obj-C
        
    }
    
    func setDetailItem(newDetailItem: YLPBusiness) {
        guard detailItem != newDetailItem else { return }
        detailItem = newDetailItem
        configureView()
        
        FavoriteService.shared.runWhenInitialized {
            if FavoriteService.shared.isFavorite(newDetailItem) {
                self._favorite = true
                self.updateFavoriteBarButtonState()
            }
        }
    }
    
    private func updateFavoriteBarButtonState() {
        favoriteBarButtonItem.image = isFavorite ? UIImage(named: "Star-Filled") : UIImage(named: "Star-Outline")
    }
    
    @objc private func onFavoriteBarButtonSelected(_ sender: Any) {
        if let detailItem = detailItem {
            FavoriteService.shared.runWhenInitialized {
                if self.isFavorite {
                    FavoriteService.shared.remove(detailItem)
                }
                else {
                    FavoriteService.shared.add(detailItem)
                }
                
                self._favorite.toggle()
                self.updateFavoriteBarButtonState()
            }
        }
    }
}
