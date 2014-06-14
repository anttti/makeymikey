//
//  MMPreviewViewController.m
//  MakeyMikey
//
//  Created by Antti Mattila on 13.6.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#import "MMPreviewViewController.h"
#import "SVProgressHUD.h"

@interface MMPreviewViewController ()

@property (nonatomic, strong) UIImage *mikeyifiedImage;

@end

@implementation MMPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SVProgressHUD showWithStatus:@"Mikeyifying!"];
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf) {
            UIImage *grayscaledImage = [strongSelf convertImageToGrayScale:strongSelf.image];
            strongSelf.mikeyifiedImage = [strongSelf addFacesToImage:grayscaledImage];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"Great Success!"];
                strongSelf.imageView.image = strongSelf.mikeyifiedImage;
            });
        }
    });
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return newImage;
}

- (UIImage *)addFacesToImage:(UIImage *)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    NSArray *features = [detector featuresInImage:ciImage];
    
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);

    UIImage *mike = [UIImage imageNamed:@"mike-small-3"];
    CGImageRef mikeRef = mike.CGImage;
    CGFloat aspectRatio = mike.size.width / mike.size.height;
    
    [features enumerateObjectsUsingBlock:^(CIFaceFeature *feature, NSUInteger idx, BOOL *stop) {
        CGContextSaveGState(context);
        
        CGFloat fX = feature.bounds.origin.x;
        CGFloat fY = feature.bounds.origin.y;
        CGFloat fWidth = feature.bounds.size.width;
        CGFloat fHeight = feature.bounds.size.height;
        
        CGFloat width = fWidth;
        CGFloat height = fHeight / aspectRatio;
        
        CGFloat angle = 0;
        if ([feature hasLeftEyePosition] && [feature hasRightEyePosition]) {
            CGFloat dx = feature.leftEyePosition.x - feature.rightEyePosition.x;
            CGFloat dy = feature.leftEyePosition.y - feature.rightEyePosition.y;
            angle = atan2(dy, dx) + M_PI;
        }

        CGRect imageRect = {
            CGPointMake(fX + fWidth / 2, fY + fHeight / 2),
            CGSizeMake(width, height)
        };
        
        CGContextTranslateCTM(context, imageRect.origin.x, imageRect.origin.y);
        CGContextRotateCTM(context, angle);
        CGContextTranslateCTM(context, imageRect.size.width * -0.5, imageRect.size.height * -0.5);
        CGContextDrawImage(context, (CGRect){ CGPointZero, imageRect.size }, mikeRef);
        
        CGContextRestoreGState(context);
    }];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

#pragma mark - Sharing

- (IBAction)share:(id)sender
{
    NSArray *items = @[self.mikeyifiedImage];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:items
                                            applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
