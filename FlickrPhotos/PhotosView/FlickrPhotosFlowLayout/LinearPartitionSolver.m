#import "LinearPartitionSolver.h"

#define TABLE_LOOKUP(table, i, j, rowsize) (table)[(i) * (rowsize) + (j)]

@implementation LinearPartitionSolver

// Returns a solution of linear partition problem

+ (NSMutableData *)linearPartitionTableForSequence:(NSArray *)sequence
                                     numPartitions:(NSInteger)numPartitions
{
    NSInteger itemsInSequence = [sequence count];
    
    // allocate a table: n * k integers
    NSInteger tableSize = sizeof(NSInteger) * itemsInSequence * numPartitions;
    NSMutableData* tmpTableData = [NSMutableData dataWithLength:tableSize];
    NSInteger *tmpTable = [tmpTableData mutableBytes];
    
    // allocate a solution table: (n - 1) * (k - 1) integers
    NSInteger solutionSize = sizeof(NSInteger) * (itemsInSequence - 1) * (numPartitions - 1);
    NSMutableData* solutionData = [NSMutableData dataWithLength:solutionSize];
    NSInteger *solutionTable = [solutionData mutableBytes];
    
    // fill table with initial values
    for (NSInteger i = 0; i < itemsInSequence; i++)
    {
        NSInteger offset = i? TABLE_LOOKUP(tmpTable, i - 1, 0, numPartitions) : 0;
        TABLE_LOOKUP(tmpTable, i, 0, numPartitions) = [sequence[i] integerValue] + offset;
    }
    
    for (NSInteger j = 0; j < numPartitions; j++)
    {
        TABLE_LOOKUP(tmpTable, 0, j, numPartitions) = [sequence[0] integerValue];
    }
    
    // calculate the costs and fill the solution buffer
    for (NSInteger i = 1; i < itemsInSequence; i++)
    {
        for (NSInteger j = 1; j < numPartitions; j++)
        {
            NSInteger currentMin = 0;
            NSInteger minX = NSIntegerMax;
            
            for (NSInteger x = 0; x < i; x++)
            {
                NSInteger c1 = TABLE_LOOKUP(tmpTable, x, j - 1, numPartitions);
                NSInteger c2 = TABLE_LOOKUP(tmpTable, i, 0, numPartitions) - TABLE_LOOKUP(tmpTable, x, 0, numPartitions);
                NSInteger cost = MAX(c1, c2);
                
                if (!x || cost < currentMin)
                {
                    currentMin = cost;
                    minX = x;
                }
            }
            
            TABLE_LOOKUP(tmpTable, i, j, numPartitions) = currentMin;
            TABLE_LOOKUP(solutionTable, i - 1, j - 1, numPartitions - 1) = minX;
        }
    }
    
    return solutionData;
}

+ (NSArray *)linearPartitionForSequence:(NSArray *)sequence
                     numberOfPartitions:(NSInteger)numberOfPartitions
{
    NSInteger itemsInSequence = [sequence count];
    
    if (numberOfPartitions <= 0) return @[];
    
    if (numberOfPartitions >= itemsInSequence)
    {
        NSMutableArray *partition = [[NSMutableArray alloc] init];
        [sequence enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [partition addObject:@[obj]];
        }];
        return partition;
    }
    
    if (itemsInSequence == 1)
    {
        return @[sequence];
    }
    
    // get the solution table
    const NSInteger *solutionTable = [[self linearPartitionTableForSequence:sequence numPartitions:numberOfPartitions] bytes];

    NSMutableArray *partitions = [NSMutableArray array];
    NSInteger solutionRowSize = numberOfPartitions - 1;
    itemsInSequence = itemsInSequence - 1;
    
    for (numberOfPartitions = numberOfPartitions - 2; numberOfPartitions >= 0; numberOfPartitions--)
    {
        if (itemsInSequence < 1)
        {
            [partitions insertObject:@[] atIndex:0];
        }
        else
        {
            NSMutableArray *itemsInPartition = [NSMutableArray array];
            NSInteger range = itemsInSequence + 1;
            itemsInSequence = TABLE_LOOKUP(solutionTable, itemsInSequence - 1, numberOfPartitions, solutionRowSize);

            for (NSInteger i = itemsInSequence + 1; i < range; i++)
            {
                [itemsInPartition addObject:sequence[i]];
            }
            
            [partitions insertObject:itemsInPartition atIndex:0];
        }
    }

    // Add last partition
    NSMutableArray *itemsInPartition = [NSMutableArray array];
    for (NSInteger i = 0, range = itemsInSequence + 1; i < range; i++)
    {
        [itemsInPartition addObject:sequence[i]];
    }
    
    [partitions insertObject:itemsInPartition atIndex:0];
    
    return partitions;
}

@end
