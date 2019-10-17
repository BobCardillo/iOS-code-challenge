//
//  NXTBusinessTableViewCell+YLPBusiness.m
//  ios-code-challenge
//
//  Created by Dustin Lange on 1/21/18.
//  Copyright © 2018 Dustin Lange. All rights reserved.
//

#import "NXTBusinessTableViewCell+YLPBusiness.h"
#import "YLPBusiness.h"

@implementation NXTBusinessTableViewCell (YLPBusiness) 

- (void)configureCell:(YLPBusiness *)business
{
    // Business Name
    self.nameLabel.text = [business name];
    
    NSMutableArray *categoryTitles = [[NSMutableArray alloc] init];
    for(NSDictionary *category in [business categories]) {
        [categoryTitles addObject:[category valueForKey:@"title"]];
    }
    self.categoryLabel.text = [categoryTitles componentsJoinedByString:@", "];
    //Printing the rating out like this as a number violates Yelp's display guidelines.
    //If I were releasing this somewhere, I would change these to the approved Yelp stars
    self.ratingLabel.text = [[business rating] stringValue];
    self.reviewCountLabel.text = [[business reviewCount] stringValue];
    self.distanceLabel.text = [[[business distance] stringValue] stringByAppendingString:@" miles"];
    
    //I've never really done anything with downloading images with the built-in networking stuff in iOS, so in the interest of ensuring I get this turned in in a reasonable amount of time, I'll just put in comments describing the process, and maybe come back to this if the rest of the challenge doesn't take too long.
    
    //NSData * imageData = nil; //get data from url in [business imageUrl]
    //UIImage * thumbnail = [UIImage imageWithData:imageData];
    
    //self.thumbnailImage.image = thumbnail;
}

#pragma mark - NXTBindingDataForObjectDelegate
- (void)bindingDataForObject:(id)object
{
    [self configureCell:(YLPBusiness *)object];
}

@end
