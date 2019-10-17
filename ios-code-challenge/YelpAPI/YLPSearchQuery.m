//
//  YLPSearchQuery.m
//  ios-code-challenge
//
//  Created by Dustin Lange on 1/21/18.
//  Copyright © 2018 Dustin Lange. All rights reserved.
//

#import "YLPSearchQuery.h"

const int SEARCH_PAGE_SIZE = 20; //The default page size for the Yelp API

@interface YLPSearchQuery()

@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;

@end

@implementation YLPSearchQuery

- (instancetype)initWithLocation:(NSString *)location
{
    if(self = [super init]) {
        _location = location;
    }
    
    _page = 0;
    
    return self;
}
- (instancetype)initWithLatitude:(NSNumber *)latitude andLongitude:(NSNumber *)longitude
{
    if(self = [super init]) {
        _latitude = latitude;
        _longitude = longitude;
    }
    
    _page = 0;
    
    return self;
}
- (NSDictionary *)parameters
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if(self.location) {
        params[@"location"] = self.location;
    }

    if(self.latitude && self.longitude) {
        params[@"latitude"] = self.latitude;
        params[@"longitude"] = self.longitude;
    }
    
    if(self.term) {
        params[@"term"] = self.term;
    }
    
    if(self.radiusFilter > 0) {
        params[@"radius"] = @(self.radiusFilter);
    }
    
    if(self.categoryFilter != nil && self.categoryFilter.count > 0) {
        params[@"categories"] = [self.categoryFilter componentsJoinedByString:@","];
    }
    
    params[@"sort_by"] = @"distance";
    
    params[@"offset"] = [NSNumber numberWithInt:self.page * SEARCH_PAGE_SIZE];
    
    return params;
}

- (NSArray<NSString *> *)categoryFilter {
    return _categoryFilter ?: @[];
}

@end
