//
//  Model.h
//  FlickrPhotos
//
//  Created by Igor Pchelko on 08/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoItem.h"
#import "PhotoDownloadController.h"

@protocol ModelDelegate <NSObject>

- (void)modelDidDownloadPhotoItem:(PhotoItem*)photoItem withError:(NSError*)error;

@end


@interface Model : NSObject

@property (nonatomic, strong) id<ModelDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) PhotoDownloadController *photoDownloadController;

+ (instancetype)modelWithDelegate:(id<ModelDelegate>)delegate;
- (BOOL)processData:(NSData*)data;
- (void)downloadPhotos;
- (NSData*)sampleFlicrData;

@end
