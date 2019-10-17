//
//  YLPBusiness.h
//  ios-code-challenge
//
//  Created by Dustin Lange on 1/21/18.
//  Copyright © 2018 Dustin Lange. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface YLPBusiness : NSObject

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

/**
 *  Yelp id of this business.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 *  Name of this business.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 *  Categories of this business.
 */
@property (nonatomic, readonly, copy) NSArray<NSDictionary<NSString *, NSString *> *> *categories;

/**
 *  Rating of this business.
 */
@property (nonatomic, readonly, copy) NSNumber *rating;

/**
 *  Number of reviews of this business.
 */
@property (nonatomic, readonly, copy) NSNumber *reviewCount;

/**
 *  Current distance between this business and the user.
 */
@property (nonatomic, readonly, copy) NSNumber *distance;

/**
 *  Relative price of this business.
 */
@property (nonatomic, readonly, copy) NSString *price;

/**
 *  URL for the thumbnail for this business.
 */
@property (nonatomic, readonly, copy) NSString *imageUrl;

@end

NS_ASSUME_NONNULL_END
