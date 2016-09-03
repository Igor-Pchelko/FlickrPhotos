//
//  PhotoItem.m
//  FlickrPhotos
//
//  Created by Igor Pchelko on 08/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import "PhotoItem.h"

@implementation PhotoItem

+ (instancetype)PhotoItemWithData:(NSDictionary*)data
{
    return [[PhotoItem alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary*)data
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    self.width = [[data objectForKey:@"width_n"] integerValue];
    self.height = [[data objectForKey:@"height_n"] integerValue];
    self.title = [data objectForKey:@"title"];
    self.url = [NSURL URLWithString:[data objectForKey:@"url_n"]];
    self.photoState = PhotoNotDownloaded;
    
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"size: %ld x %ld; title: %@; state: %ld",
            self.width,
            self.height,
            self.title,
            self.photoState];
}

- (CGSize)size
{
    return CGSizeMake(self.width, self.height);
}

@end
