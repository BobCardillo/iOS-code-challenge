//
//  YLPBusiness.m
//  ios-code-challenge
//
//  Created by Dustin Lange on 1/21/18.
//  Copyright © 2018 Dustin Lange. All rights reserved.
//

#import "YLPBusiness.h"

const double METERS_TO_MILES_MULTIPLIER = 0.000621371192;

@implementation YLPBusiness

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    if(self = [super init]) {
        _identifier = attributes[@"id"];
        _name = attributes[@"name"];
        _categories = attributes[@"categories"];
        _rating = attributes[@"rating"];
        _reviewCount = attributes[@"review_count"];
        _distance = [NSNumber numberWithDouble:[attributes[@"distance"] doubleValue] * METERS_TO_MILES_MULTIPLIER];
        _price = attributes[@"price"];
        _imageUrl = attributes[@"image_url"];
    }
    
    return self;
}

@end
