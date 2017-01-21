//
//  ImageViewController.m
//  Fontmania_test
//
//  Created by Vladimir Ananko on 1/20/17.
//  Copyright © 2017 Vladimir Ananko. All rights reserved.
//

#import "ImageViewController.h"
#import "Photos/Photos.h"

@interface ImageViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UILabel *commentLabel;
@property (assign, nonatomic) CGPoint touchOffset;
@property (assign, nonatomic) CGFloat lastScale;
@property (assign, nonatomic) CGFloat lastFont;
@property (assign, nonatomic) CGPoint commentLabelCenter;
@property (assign, nonatomic) CGSize commentLabelSize;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.0f;
    [self.view addGestureRecognizer:longPressGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchGesture];
    NSLog(@"%@", NSStringFromCGRect(self.imageView.frame));

}

- (void)addText {
    if (!self.commentLabel) {
        CGFloat textWidth = 100.f;
        CGFloat textHeight = 30.f;
        CGRect textRect = CGRectMake(CGRectGetMidX(self.imageView.frame) - textWidth / 2,
                                     CGRectGetMidY(self.imageView.frame) - textHeight / 2,
                                     textWidth,
                                     textHeight);
        
        UILabel *comment = [[UILabel alloc] initWithFrame:textRect];
        comment.text = @"Something";
        [self.imageView addSubview:comment];
        self.commentLabel = comment;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    CGPoint touchPointInLabel = [gesture locationInView:self.commentLabel];
    CGPoint touchPointInImage = [gesture locationInView:self.imageView];
    
    if (CGRectContainsPoint(self.commentLabel.frame, touchPointInImage)) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            self.touchOffset = CGPointMake((CGRectGetMidX(self.commentLabel.bounds) - touchPointInLabel.x), (CGRectGetMidY(self.commentLabel.bounds) - touchPointInLabel.y));
        }
        
        if (gesture.state == UIGestureRecognizerStateChanged) {
            CGPoint newCenter = CGPointMake(touchPointInImage.x + self.touchOffset.x, touchPointInImage.y + self.touchOffset.y);
            self.commentLabel.center = newCenter;
        }
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.lastFont = self.commentLabel.font.pointSize;
        self.commentLabelCenter = self.commentLabel.center;
        self.commentLabelSize = self.commentLabel.frame.size;
        self.lastScale = 1;
    }
    CGRect frameSize = CGRectMake(CGRectGetMinX(self.commentLabel.frame),
                                  CGRectGetMinY(self.commentLabel.frame),
                                  self.commentLabelSize.width * self.lastScale,
                                  self.commentLabelSize.height * self.lastScale);
    
    self.commentLabel.frame = frameSize;
    self.commentLabel.center = self.commentLabelCenter;

    CGFloat fontSize = self.lastScale * self.lastFont;
    UIFont *font = [UIFont fontWithName:self.commentLabel.font.fontName size:fontSize];
    [self.commentLabel setFont:font];
    self.lastScale = gesture.scale;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:NO completion:^{
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        CGFloat width = chosenImage.size.width;
        CGFloat height = chosenImage.size.height;

        self.imageView.image = chosenImage;
        NSLog(@"%@", NSStringFromCGRect(self.imageView.frame));

    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:NULL];
}

- (void)choosePhoto {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusDenied: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showImagePickerStatusDeniedAlertWithTitle:@"Allow TombCare_Client to access your photos" message:@"Access was previously denied, please grant access from Settings."];
                });
            }
                break;
                
            case PHAuthorizationStatusRestricted: {
            }
                break;
                
            default:
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:picker animated:NO completion:nil];
                });
        }
    }];
}

- (void)showImagePickerStatusDeniedAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)photoButtonPressed:(UIBarButtonItem *)sender {
    [self choosePhoto];
}

- (IBAction)addTextButtonPressed:(UIBarButtonItem *)sender {
    [self addText];
    NSLog(@"%@", NSStringFromCGRect(self.imageView.frame));

}

@end
