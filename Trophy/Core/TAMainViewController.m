//
//  TAMainViewController.m
//  Trophy
//
//  Created by Gigster on 1/2/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAMainViewController.h"

#import "TAActiveUserManager.h"
#import "TALeaderboardViewController.h"
#import "TAProfileViewController.h"
#import "TASettingsViewController.h"
#import "TATimelineViewController.h"
#import "TATrophyEditorViewController.h"
#import "TATrophyPickerOverlayView.h"
#import "TAUser.h"

@interface TAMainViewController () <UINavigationControllerDelegate,
                                    UIImagePickerControllerDelegate, 
                                    UITabBarControllerDelegate,
                                    TATrophyPickerOverlayDelegate,
                                    TATrophyEditorViewControllerDelegate,
                                    TAPresentedViewControllerDelegate,
                                    TASettingsViewControllerDelegate>
@property (nonatomic, strong) UIViewController *timelineController;
@property (nonatomic, strong) UIViewController *imagePicker;
@property (nonatomic, strong) UIViewController *leaderboardController;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation TAMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;

    [self configureViewControllers];
    
}

- (void)configureViewControllers
{
    TATimelineViewController *timelineViewController = [[TATimelineViewController alloc] init];
    
    timelineViewController.presentedDelegate = self;
    self.timelineController = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
    
    self.imagePicker = [[UIViewController alloc] init];
    self.imagePicker.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"camera-tab-button.png"] selectedImage:[UIImage imageNamed:@"camera-tab-button-selected.png"]];
    self.imagePicker.tabBarItem.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0);
    
    TALeaderboardViewController *leaderboardViewController = [[TALeaderboardViewController alloc] init];
    leaderboardViewController.presentedDelegate = self;
    self.leaderboardController = [[UINavigationController alloc] initWithRootViewController:leaderboardViewController];
    self.leaderboardController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"leaderboard-tab-button.png"] selectedImage:[UIImage imageNamed:@"leaderboard-tab-button-selected.png"]];
    self.leaderboardController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);

    self.viewControllers = @[self.timelineController, self.imagePicker, self.leaderboardController]; 
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController == self.imagePicker) {
        [self presentImagePickerController];
        return NO;
    }
    return YES;
}

#pragma mark - UINavigationController Delegate Method

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController setTitle:@""];
}

#pragma mark - UIImagePickerController Methods

- (void)presentImagePickerController
{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    self.imagePickerController.delegate = self;
    self.imagePickerController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"camera-tab-button.png"] selectedImage:[UIImage imageNamed:@"camera-tab-button-selected.png"]];
    self.imagePickerController.tabBarItem.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0);
    self.imagePickerController.showsCameraControls = NO;

    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat aspectRatio = 4.0 / 3.0;
    CGFloat transform = (screenSize.height / screenSize.width) / aspectRatio;
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 64.0);
    CGAffineTransform scale = CGAffineTransformMakeScale(transform, transform);
    self.imagePickerController.cameraViewTransform = CGAffineTransformConcat(translate, scale);

    TATrophyPickerOverlayView *overlayView = [[TATrophyPickerOverlayView alloc] initWithFrame:self.imagePickerController.cameraOverlayView.frame];
    overlayView.delegate = self;
    self.imagePickerController.cameraOverlayView = overlayView;
    [self.view addSubview:self.imagePickerController.view];

    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    if (chosenImage == nil) return;

    // Format image
    UIImage *image = chosenImage;
    UIImageOrientation correctOrientation;
    if (picker.sourceType != UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            correctOrientation = UIImageOrientationLeftMirrored;
        } else {
            correctOrientation = UIImageOrientationRight;
        }
        if (image.imageOrientation != correctOrientation) {
            image = [[UIImage alloc] initWithCGImage: chosenImage.CGImage
                                               scale: 1.0
                                         orientation: correctOrientation];
        }
    }

    TATrophyEditorViewController *trophyEditorVC = [[TATrophyEditorViewController alloc] initWithImage:image];
    trophyEditorVC.delegate = self;
    [picker presentViewController:trophyEditorVC animated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TATrophyPickerOverlayView Delegate Methods

- (void)trophyPickerOverlayDidSelectTakePhotoButton
{
    if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self.imagePickerController takePicture];
    }
}

- (void)trophyPickerOverlayDidSelectRotateButton
{
    if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
}

- (void)trophyPickerOverlayDidSelectFlashButton
{
    if (self.imagePickerController.cameraFlashMode == UIImagePickerControllerCameraFlashModeOn) {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
       
    }
    else  {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
       
    }
}

- (void)trophyPickerOverlayDidSelectCancelButton
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)trophyPickerOverlayDidSelectPhotoAlbumButton
{
    UIImagePickerController *cameraRollSelector = [[UIImagePickerController alloc] init];
    [cameraRollSelector.view setFrame:self.view.bounds];
    [cameraRollSelector setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [cameraRollSelector setDelegate:self];
    
    [self.imagePickerController presentViewController:cameraRollSelector animated:YES completion:nil];
}

#pragma mark - TATrophyEditorViewController Delegate Methods

- (void)trophyEditorViewControllerDidSendTrophyWithSuccess
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TAPresentedViewControllerDelegate Methods

- (void)presentSettings:(UIViewController *)viewController
{
    TASettingsViewController *settingsVC = [[TASettingsViewController alloc] initWithSetupFlow:NO];
    settingsVC.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)presentProfile:(UIViewController *)viewController
{
    TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
    TAProfileViewController *profileVC = [[TAProfileViewController alloc] initWithUser:currentUser];
    [viewController.navigationController pushViewController:profileVC animated:YES];
}

- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsViewControllerDidUpdateProfileSettings {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
