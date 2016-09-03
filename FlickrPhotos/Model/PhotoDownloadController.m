//
//  ImageDownloadController.m
//  FlickrPhotos
//
//  Created by Igor Pchelko on 09/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//
#import "PhotoDownloadController.h"

@implementation PhotoDownloadController

- (instancetype)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:nil
                                                     delegateQueue:nil];
    
    return self;
}

- (void)downloadImageWithURL:(NSURL*)url
           completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler;
{
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url
                                                 completionHandler:^(NSData *data,
                                                                     NSURLResponse *response,
                                                                     NSError *error)
                                      {
                                          if (!error)
                                          {
                                              UIImage *image = [[UIImage alloc] initWithData:data];
                                              completionHandler(image, nil);
                                              NSLog(@"image: %@", image);
                                          }
                                          else
                                          {
                                              completionHandler(nil, error);
                                          }
                                      }];
    
    [dataTask resume];
}

@end
