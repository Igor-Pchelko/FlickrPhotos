//
//  DetailPhotoViewController.m
//  FlickrPhotos
//
//  Created by Igor Pchelko on 10/01/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import "DetailPhotoViewController.h"

@interface DetailPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@end

@implementation DetailPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.image = self.photoItem.photo;
    self.titleLabel.text = self.photoItem.title;
    self.sizeLabel.text = [NSString stringWithFormat:@"%ld x %ld", self.photoItem.width, self.photoItem.height];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToPhotosView:(id)sender
{
    
}

@end
