//
//  MMViewController.m
//  MakeyMikey
//
//  Created by Antti Mattila on 13.6.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#import "MMViewController.h"
#import "MMPreviewViewController.h"
#import "UIImage+FixOrientation.h"

#define SHOW_IMAGE_SEGUE @"ShowImage"

@interface MMViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImage *image;

@end

@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)photoFromCamera:(id)sender
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[self showPhotoPicker:UIImagePickerControllerSourceTypeCamera];
	}
}

- (IBAction)photoFromLibrary:(id)sender
{
    [self showPhotoPicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showPhotoPicker:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:SHOW_IMAGE_SEGUE sender:self];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SHOW_IMAGE_SEGUE]) {
        MMPreviewViewController *previewVC = (MMPreviewViewController *)segue.destinationViewController;
        previewVC.image = [self.image fixOrientation];
    }
}

@end
