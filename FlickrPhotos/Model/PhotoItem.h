//
//  PhotoItem.h
//  FlickrPhotos
//
//  Created by Igor Pchelko on 08/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    PhotoNotDownloaded,
    PhotoDownloaded,
    PhotoDownloadFailed,
} PhotoItemState;

@interface PhotoItem : NSObject

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, assign) PhotoItemState photoState;
@property (nonatomic, readonly) CGSize size;

+ (instancetype)PhotoItemWithData:(NSDictionary*)data;

@end
