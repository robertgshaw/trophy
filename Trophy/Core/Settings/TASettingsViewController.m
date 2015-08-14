//
//  TAAddSettingsViewController.m
//  Trophy
//
//  Created by Gigster on 12/20/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TASettingsViewController.h"

#import "TAActiveUserManager.h"
#import "TAAddSettingsView.h"
#import "TARootViewController.h"
#import "TASettingsView.h"

#import "TADefines.h"
#import "UIColor+TAAdditions.h"
#import <SVProgressHUD.h>

@interface TASettingsViewController () <TASettingsViewDelegate,
                                       UIImagePickerControllerDelegate,
                                       UINavigationControllerDelegate>

@property (nonatomic, strong) TASettingsView *settingsView;
@property (nonatomic, assign) BOOL showSetupFlow;
@end

@implementation TASettingsViewController

- (instancetype)initWithSetupFlow:(BOOL)shouldShowSetupFlow
{
    self = [super init];
    if (self) {
        _showSetupFlow = shouldShowSetupFlow;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSLog(@"Settings setup view did load");
    
    if (self.showSetupFlow) {
        NSLog(@"New user, no settings information");
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navigationItem.hidesBackButton = YES;
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.barTintColor = [UIColor darkYellowColor];
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"CREATE PROFILE";
        titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:20.0];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
        
        TAAddSettingsView *addSettingsView = [[TAAddSettingsView alloc] initWithFrame:self.view.bounds];
        addSettingsView.delegate = self;
        [self.view addSubview:addSettingsView];
    } else {
        NSLog(@"Loading settings information");
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.barTintColor = [UIColor darkYellowColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
        titleLabel.text = @"Settings";
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
    
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed)];
        self.navigationItem.rightBarButtonItem = rightButton;

        TASettingsView *settingsView = [[TASettingsView alloc] initWithSettings:[TAActiveUserManager sharedManager].activeUser];
        settingsView.frame = self.view.bounds;
        settingsView.delegate = self;
        [self.view addSubview:settingsView];
    }
}

#pragma mark - TAaddSettingsView Delegate Methods

- (void)settingsViewDidPressProfileImageButton:(TASettingsView *)settingsView
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.settingsView = settingsView;

    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)settingsViewDidPressSaveButton:(TASettingsView *)settingsView
{
    BlockWeakSelf weakSelf = self;
    if (settingsView.profileImage == nil) {
        [[TAActiveUserManager sharedManager] updateUserWithParameters:@{@"name": settingsView.name,
                                                                        @"bio": settingsView.bio}
                                                              success:^{
                                                                  [weakSelf.delegate settingsViewControllerDidUpdateProfileSettings];
                                                              } failure:^(NSString *error) {
                                                                  [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
                                                              }];
    } else {
        NSData *imageData = UIImageJPEGRepresentation(settingsView.profileImage, 0.05f);
        BlockWeakSelf weakSelf = self;
        [self uploadImage:imageData withCompletion:^(PFFile *imageFile) {
            NSDictionary *settings = @{@"name": settingsView.name,
                                       @"bio": settingsView.bio,
                                       @"profileImage": imageFile};
            [[TAActiveUserManager sharedManager] updateUserWithParameters:settings
                                                                  success:^{
                                                                      [SVProgressHUD dismiss];
                                                                      [weakSelf.delegate settingsViewControllerDidUpdateProfileSettings];
                                                                  } failure:^(NSString *error) {
                                                                      [SVProgressHUD dismiss];
                                                                      [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
                                                                  }];
        }];
    }
}

- (void)uploadImage:(NSData *)imageData withCompletion:(void (^)(PFFile *imageFile))completion
{
    [SVProgressHUD showWithStatus:@"Saving your settings" maskType:SVProgressHUDMaskTypeBlack];
    PFFile *imageFile = [PFFile fileWithName:@"profile_image.jpg" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            completion(imageFile);
        }
        else{
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:error.description maskType:SVProgressHUDMaskTypeBlack];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        NSLog(@"Updating (%d%% done)", percentDone);
    }];
}

#pragma mark - UIImagePickerController Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)imagePicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.settingsView.profileImage = chosenImage;

    [imagePicker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UINavigation Delegate Methods
- (void)logoutButtonPressed
{
    [[TAActiveUserManager sharedManager] endSession];
}

@end
