//
//  FlickrPhotosFlowLayout.m
//  FlickrPhotos
//
//  Created by Igor Pchelko on 08/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import "FlickrPhotosFlowLayout.h"
#import "LinearPartitionSolver.h"

@interface FlickrPhotosFlowLayout ()

@property (nonatomic, strong) NSMutableArray *framesForSection;
@property (nonatomic) CGSize contentSize;

@end

@implementation FlickrPhotosFlowLayout

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

#pragma mark - UICollectionViewLayout (UISubclassingHooks)

// The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
// The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
// Subclasses should always call super if they override.
- (void)prepareLayout
{
    [super prepareLayout];
    
    NSAssert([self.delegate conformsToProtocol:@protocol(FlickrPhotosFlowLayoutDelegate)],
             @"UICollectionView delegate should conform to FlickrPhotosFlowLayoutDelegate protocol");
    
    CGFloat rowHeight = self.preferredRowHeight;
    
    if (rowHeight == 0)
        rowHeight = CGRectGetHeight(self.collectionView.bounds) / 4.0;
    
    CGSize contentSize = CGSizeZero;
    
    self.framesForSection = [NSMutableArray arrayWithCapacity:[self.collectionView numberOfSections]];
    
    for (int section = 0; section < [self.collectionView numberOfSections]; section++)
    {
        // add new item frames array to sections array
        NSInteger numberOfItemsInSections = [self.collectionView numberOfItemsInSection:section];
        NSInteger itemFramesDataSize = sizeof(CGRect) * numberOfItemsInSections;
        NSMutableData *itemFramesData = [NSMutableData dataWithCapacity:itemFramesDataSize];
        self.framesForSection[section] = itemFramesData;
        
        CGSize sectionSize = CGSizeZero;
        CGFloat totalItemWidth = [self totalItemWidthForSection:section forRowHeight:rowHeight];
        NSInteger numberOfRows = MAX(roundf(totalItemWidth / [self viewPortWidth]), 1);
    
        CGPoint sectionOffset = CGPointMake(0, contentSize.height);
        
        [self setupItemFramesForSection:section
                           numberOfRows:numberOfRows
                          sectionOffset:sectionOffset
                            sectionSize:&sectionSize];
        
        contentSize = CGSizeMake(sectionSize.width, contentSize.height + sectionSize.height);
    }
    
    self.contentSize = contentSize;
}

- (void)setupItemFramesForSection:(NSInteger)section
                     numberOfRows:(NSUInteger)numberOfRows
                    sectionOffset:(CGPoint)sectionOffset
                      sectionSize:(CGSize *)sectionSize
{
    NSArray *weights = [self weightsForItemsInSection:section];
    NSArray *partitions = [LinearPartitionSolver linearPartitionForSequence:weights numberOfPartitions:numberOfRows];
    
    CGRect *frames = [self itemFramesForSection:section];
    CGPoint offset = CGPointMake(sectionOffset.x, sectionOffset.y);
    CGFloat previousItemSize = 0;
    CGFloat contentMaxValue = 0;
    NSInteger i = 0;
    
    for (NSArray *row in partitions)
    {
        CGFloat summedRatios = 0;
        NSInteger count = i + row.count;
        
        for (NSInteger j = i; j < count; j++)
        {
            summedRatios += [self preferredAspectRatioForItemAt:j inSection:section];
        }
        
        CGFloat rowHeight = [self viewPortWidth] / summedRatios;
        
        for (NSInteger j = i; j < count; j++)
        {
            CGFloat preferredAspectRatio = [self preferredAspectRatioForItemAt:j inSection:section];
            CGSize actualSize = CGSizeMake(roundf(rowHeight * preferredAspectRatio),
                                           roundf(rowHeight));
            
            CGRect frame = CGRectMake(offset.x, offset.y, actualSize.width, actualSize.height);
            frames[i++] = frame;
            
            offset.x += actualSize.width;
            previousItemSize = actualSize.height;
            contentMaxValue = CGRectGetMaxY(frame);
        }
        
        // Sometimes partition algorithm can return empty row, let's skip it
        if (row.count > 0)
        {
            // move offset to next line
            offset = CGPointMake(0, offset.y + previousItemSize);
        }
    }
    
    *sectionSize = CGSizeMake([self viewPortWidth], (contentMaxValue - sectionOffset.y));
}

// Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.
- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

// UICollectionView calls these four methods to determine the layout information.
// Implement -layoutAttributesForElementsInRect: to return layout attributes for for supplementary or decoration views, or to perform layout in an as-needed-on-screen fashion.
// Additionally, all layout subclasses should implement -layoutAttributesForItemAtIndexPath: to return layout attributes instances on demand for specific index paths.
// If the layout supports any supplementary or decoration view types, it should also implement the respective atIndexPath: methods for those types.
// return an array layout attributes instances for all the views in the given rect
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    for (NSInteger section = 0, n = [self.collectionView numberOfSections]; section < n; section++)
    {
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];

        UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                  atIndexPath:sectionIndexPath];
        
        if (!CGSizeEqualToSize(headerAttributes.frame.size, CGSizeZero) && CGRectIntersectsRect(headerAttributes.frame, rect))
        {
            [layoutAttributes addObject:headerAttributes];
        }

        const CGRect *frames = [self itemFramesForSection:section];

        for (int i = 0; i < [self.collectionView numberOfItemsInSection:section]; i++)
        {
            if (CGRectIntersectsRect(rect, frames[i]))
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
                [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            }
        }
        
        UICollectionViewLayoutAttributes *footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                                  atIndexPath:sectionIndexPath];
        
        if (!CGSizeEqualToSize(footerAttributes.frame.size, CGSizeZero) && CGRectIntersectsRect(footerAttributes.frame, rect))
        {
            [layoutAttributes addObject:footerAttributes];
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = [self itemFrameForIndexPath:indexPath];
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    // If there is no header or footer, we need to return nil to prevent a crash from UICollectionView private methods.
    if (CGRectIsEmpty(attributes.frame))
    {
        attributes = nil;
    }
    
    return attributes;
}

// return YES to cause the collection view to requery the layout for geometry information
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;

    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds) || CGRectGetHeight(newBounds) != CGRectGetHeight(oldBounds))
        return YES;
    
    return NO;
}

#pragma mark - Custom setters

- (void)setPreferredRowHeight:(CGFloat)preferredRowHeight
{
    _preferredRowHeight = preferredRowHeight;
    [self invalidateLayout];
}

#pragma mark - Delegate

- (id<FlickrPhotosFlowLayoutDelegate>)delegate
{
    return (id<FlickrPhotosFlowLayoutDelegate>)self.collectionView.delegate;
}

#pragma mark - Helpers

- (CGRect*)itemFramesForSection:(NSInteger)section
{
    return [self.framesForSection[section] mutableBytes];
}

- (CGRect)itemFrameForIndexPath:(NSIndexPath *)indexPath
{
    return [self itemFramesForSection: indexPath.section][indexPath.item];
}

- (CGFloat)totalItemWidthForSection:(NSInteger)section forRowHeight:(CGFloat)rowHight
{
    CGFloat totalItemWidth = 0;
    NSInteger count = [self.collectionView numberOfItemsInSection:section];
    
    for (NSInteger i = 0; i < count; i++)
    {
        CGFloat aspectRatio = [self preferredAspectRatioForItemAt:i inSection:section];
        totalItemWidth += aspectRatio * rowHight;
    }
    
    return totalItemWidth;
}

- (NSArray*)weightsForItemsInSection:(NSInteger)section
{
    NSMutableArray *weights = [NSMutableArray array];
    NSInteger count = [self.collectionView numberOfItemsInSection:section];
    
    for (NSInteger i = 0; i < count; i++)
    {
        NSInteger aspectRatio = roundf([self preferredAspectRatioForItemAt:i inSection:section] * 100);
        [weights addObject:@(aspectRatio)];
    }
    
    return weights;
}

- (CGFloat)viewPortWidth
{
    return CGRectGetWidth(self.collectionView.frame) - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
}

- (CGFloat)viewPortHeight
{
    return (CGRectGetHeight(self.collectionView.frame) - self.collectionView.contentInset.top  - self.collectionView.contentInset.bottom);
}

- (CGSize)preferredSizeForItemAt:(NSInteger)item inSection:(NSInteger)section
{
    return [self.delegate collectionView:self.collectionView
         preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
}

- (CGFloat)preferredAspectRatioForItemAt:(NSInteger)item inSection:(NSInteger)section
{
    CGSize preferredSize = [self preferredSizeForItemAt:item inSection:section];
    return preferredSize.width / preferredSize.height;
}

@end
