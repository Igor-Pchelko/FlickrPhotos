//
//  FlickrPhotosTests.m
//  FlickrPhotosTests
//
//  Created by Igor Pchelko on 08/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Model.h"
#import "PhotoDownloadController.h"

@interface FlickrPhotosTests : XCTestCase<ModelDelegate>

@property (nonatomic, strong) Model *model;
@property (nonatomic, strong) XCTestExpectation *downloadPhotosExpectation;

@end

@implementation FlickrPhotosTests

- (void)setUp
{
    [super setUp];
    self.model = [Model modelWithDelegate:self];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatJsonDataProcesses
{
    NSData *data = [self.model sampleFlicrData];
    XCTAssertTrue([self.model processData:data]);
}

- (void)testThatDownloadComplete
{
    self.downloadPhotosExpectation = [self expectationWithDescription:@"Photos are downloaded"];
    NSData *data = [self.model sampleFlicrData];
    
    [self.model processData:data];
    [self.model downloadPhotos];
    
    [self waitForExpectationsWithTimeout:1000.0 handler:^(NSError *error)
     {
         NSLog(@"%@", [self.model photos]);

         if (error)
         {
             NSLog(@"Timeout Error: %@", error);
         }
     }];
}

- (BOOL)isAllPhotosDownloaded
{
    for (PhotoItem *photoItem in self.model.photos)
    {
        if (photoItem.photoState == PhotoNotDownloaded)
            return NO;
    }
    
    return YES;
}

- (void)modelDidDownloadPhotoItem:(PhotoItem*)photoItem withError:(NSError*)error
{
    NSLog(@"modelDidDownloadPhotoItem: %@", photoItem.photo);
    
    if ([self isAllPhotosDownloaded])
    {
        [self.downloadPhotosExpectation fulfill];
    }
}


- (void)testThatPhotoDownloadControllerReturnsImage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Image is downloaded"];
    
    PhotoDownloadController *controller = [[PhotoDownloadController alloc] init];

    [controller downloadImageWithURL:[NSURL URLWithString:@"https://farm9.staticflickr.com/8608/16145515232_dacd9535d0_n.jpg"]
                   completionHandler:^(UIImage *image, NSError *error)
     {
         XCTAssertNotNil(image, @"Should return image");
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error)
     {
         if (error)
         {
             NSLog(@"Timeout Error: %@", error);
         }
     }];
}

- (void)testThatPhotoDownloadControllerReturnsNoImage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Image is downloaded"];
    
    PhotoDownloadController *controller = [[PhotoDownloadController alloc] init];
    
    [controller downloadImageWithURL:[NSURL URLWithString:@"xyz"]
                   completionHandler:^(UIImage *image, NSError *error)
     {
         XCTAssertNil(image, @"Should return error");
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error)
     {
         if (error)
         {
             NSLog(@"Timeout Error: %@", error);
         }
     }];
}

@end
