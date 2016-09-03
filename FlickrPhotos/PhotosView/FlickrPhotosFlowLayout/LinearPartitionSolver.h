#import <Foundation/Foundation.h>

/**
 * Solves partition problem.
 * https://www.crispymtn.com/stories/the-algorithm-for-a-perfectly-balanced-photo-gallery
 * http://articles.leetcode.com/2011/04/the-painters-partition-problem.html
 * http://stackoverflow.com/questions/7938809/dynamic-programming-linear-partitioning-please-help-grok/7942946#7942946
 */
@interface LinearPartitionSolver : NSObject

+ (NSArray *)linearPartitionForSequence:(NSArray *)sequence numberOfPartitions:(NSInteger)numberOfPartitions;

@end
