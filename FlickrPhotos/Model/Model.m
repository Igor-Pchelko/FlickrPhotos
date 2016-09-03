//
//  Model.m
//  FlickrPhotos
//
//  Created by Igor Pchelko on 08/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import "Model.h"

@interface Model ()

@end

@implementation Model

+ (instancetype)modelWithDelegate:(id<ModelDelegate>)delegate
{
    return [[Model alloc] initWithDelegate:delegate];
}

- (instancetype)initWithDelegate:(id<ModelDelegate>)delegate
{
    self = [super init];
    
    if (self == nil)
        return self;
    
    self.delegate = delegate;
    self.photos = [NSMutableArray arrayWithCapacity:5];
    self.photoDownloadController = [[PhotoDownloadController alloc] init];
    
    return self;
}

- (BOOL)processData:(NSData*)data
{
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    id photosData = [json valueForKeyPath:@"query.results.photo"];
    
    if (![photosData isKindOfClass:[NSArray class]])
        return NO;
    
    [self.photos removeAllObjects];
    
    for (id photoItemData in photosData)
    {
        PhotoItem *photoItem = [PhotoItem PhotoItemWithData:photoItemData];

        if (photoItem != nil)
        {
            [self.photos addObject:photoItem];
        }
    }
    
    return YES;
}

- (void)downloadPhotos
{
    for (PhotoItem *item in self.photos)
    {
        [self.photoDownloadController downloadImageWithURL:item.url
                                         completionHandler:^(UIImage *image, NSError *error)
         {
             if (!error)
             {
                 item.photo = image;
                 item.photoState = PhotoDownloaded;
             }
             else
             {
                 // Process error
                 item.photoState = PhotoDownloadFailed;
             }
             
             [self.delegate modelDidDownloadPhotoItem:item withError:error];
         }];
    }
}

- (NSData*)sampleFlicrData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sample-flicr" ofType:@"json"];
    return [NSData dataWithContentsOfFile:filePath];
}
@end
