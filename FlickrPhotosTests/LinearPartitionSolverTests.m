//
//  LinearPartitionTests.m
//  FlickrPhotos
//
//  Created by Igor Pchelko on 09/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LinearPartitionSolver.h"

@interface LinearPartitionSolverTests : XCTestCase

@end

@implementation LinearPartitionSolverTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatSequenceSplitsToThreeParts
{
    NSArray *partitions = [LinearPartitionSolver linearPartitionForSequence:@[@1,@9,@6,@3,@8,@3,@8,@1,@7] numberOfPartitions:3];
    NSInteger total = 0;
    for (NSArray *partition in partitions)
    {
        NSInteger sum = 0;

        for (NSNumber *num in partition)
        {
            sum += [num integerValue];
        }
        
        NSLog(@"partition: %@", partition);
        NSLog(@"sum: %ld", sum);
        
        total += sum;
    }
    
    NSLog(@"total: %ld", total);
    
    XCTAssertEqual(partitions.count, 3, @"Should split to 3 partitions");
}


@end
