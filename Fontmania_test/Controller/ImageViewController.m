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

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(dragText:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
}

- (void)addText {
    CGFloat textWidth = 100.f;
    CGFloat textHeight = 30.f;
    CGRect textRect = CGRectMake(CGRectGetMidX(self.imageView.frame) - textWidth / 2,
                                 CGRectGetMidY(self.imageView.frame) - textHeight / 2,
                                 textWidth,
                                 textHeight);
    
    UILabel *text = [[UILabel alloc] initWithFrame:textRect];
    text.text = @"Something";
    [self.imageView addSubview:text];
    self.commentLabel = text;
}

- (void)dragText:(UIPanGestureRecognizer *)gesture {
    CGPoint touchPoint = [gesture locationInView:self.imageView];
    CGRect
    if (CGRectContainsPoint(self.commentLabel.frame, touchPoint)) {
        self.commentLabel.center = touchPoint;
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:NO completion:^{
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        self.imageView.image = chosenImage;
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)photoButtonPressed:(UIBarButtonItem *)sender {
    [self choosePhoto];
}

- (IBAction)addTextButtonPressed:(UIBarButtonItem *)sender {
    [self addText];
}

@end
