//
//  FlickrPhotosFlowLayout.h
//  FlickrPhotos
//
//  Created by Igor Pchelko on 08/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotosFlowLayout : UICollectionViewLayout

@property (nonatomic) CGFloat preferredRowHeight;

@end


@protocol FlickrPhotosFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@required
- (CGSize)collectionView:(UICollectionView *)collectionView preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end