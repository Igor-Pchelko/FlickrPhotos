//
//  ViewController.m
//  FlickrPhotos
//
//  Created by Igor Pchelko on 08/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoItemViewCell.h"
#import "Model.h"
#import "FlickrPhotosFlowLayout.h"
#import "DetailPhotoViewController.h"

@interface PhotosViewController () <ModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate, FlickrPhotosFlowLayoutDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) Model *model;
@property (nonatomic, assign) CGFloat zoomGestureLastScale;
@property (nonatomic, assign) CGFloat zoomGestureCurrentZoom;

@end

@implementation PhotosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.model = [Model modelWithDelegate:self];
    [self.model processData:[self.model sampleFlicrData]];
    [self.model downloadPhotos];
    
    self.zoomGestureCurrentZoom = 1.0f;
    [self setPreferredRowSize];
}

- (void)setPreferredRowSize
{
    FlickrPhotosFlowLayout *layout = (FlickrPhotosFlowLayout *)self.collectionView.collectionViewLayout;
    layout.preferredRowHeight = 100.0 * self.zoomGestureCurrentZoom;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan )
    {
        self.zoomGestureLastScale = gestureRecognizer.scale;
    }
    else if ( gestureRecognizer.state == UIGestureRecognizerStateChanged )
    {
        float scaleDeltaFactor = gestureRecognizer.scale/self.zoomGestureLastScale;
        float currentZoom = self.zoomGestureCurrentZoom;
        float newZoom = currentZoom * scaleDeltaFactor;
        
        // clamp
        float kMaxZoom = 2.5f;
        float kMinZoom = 0.5f;
        newZoom = MAX(kMinZoom,MIN(newZoom,kMaxZoom));
        
        // store for next time
        self.zoomGestureCurrentZoom = newZoom;
        self.zoomGestureLastScale = gestureRecognizer.scale;
        
        [self setPreferredRowSize];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.model.photos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoItemViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoItemViewCell"
                                                                        forIndexPath:indexPath];
    PhotoItem *item = self.model.photos[indexPath.row];
    cell.photo.image = item.photo;
    
    return cell;
}

#pragma mark - ModelDelegate
- (void)modelDidDownloadPhotoItem:(PhotoItem*)photoItem withError:(NSError*)error
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSInteger ix = [self.model.photos indexOfObject:photoItem];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:ix inSection:0];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    });
}


#pragma mark - FlickrPhotosFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.model.photos objectAtIndex:indexPath.item] size];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowDetailPhotoViewController"])
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        PhotoItem *item = self.model.photos[indexPath.row];
        
        DetailPhotoViewController *detailViewController = (DetailPhotoViewController *)segue.destinationViewController;
        detailViewController.photoItem = item;
    }
}

-(IBAction)unwindfromDetailPhotoViewController:(UIStoryboardSegue *)sender
{
}

@end
