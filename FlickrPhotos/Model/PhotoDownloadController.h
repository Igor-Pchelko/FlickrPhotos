//
//  ImageDownloadController.h
//  FlickrPhotos
//
//  Created by Igor Pchelko on 09/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoDownloadController : NSObject<NSURLSessionDelegate>

@property (nonatomic, retain) NSURLSession *session;

- (instancetype)init;

- (void)downloadImageWithURL:(NSURL*)url
           completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler;

@end
