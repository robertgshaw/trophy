//
//  TATrophyEditorViewController.m
//  Trophy
//
//  Created by Gigster on 1/7/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophyEditorViewController.h"

#import "TAActiveUserManager.h"
#import "TATrophy.h"
#import "TATrophyEditorView.h"
#import "TATrophyManager.h"
#import "TATrophySendViewController.h"

@interface TATrophyEditorViewController () <TATrophyEditorDelegate,
                                            TATrophySendViewControllerDelegate>

@property (nonatomic, strong) UIImage *cameraImage;
@property (nonatomic, strong) TATrophyEditorView *editorView;
@property (nonatomic, strong) TATrophySendViewController *sendViewController;

@end

@implementation TATrophyEditorViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _cameraImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.editorView = [[TATrophyEditorView alloc] initWithFrame:self.view.bounds];
    self.editorView.delegate = self;
    self.editorView.cameraImage = self.cameraImage;
    [self.view addSubview:self.editorView];
}

#pragma  mark - TATrophyEditorView Delegate

- (void)trophyEditorDidSelectCancel
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)trophyEditorDidSelectSend
{
    self.sendViewController = [[TATrophySendViewController alloc] init];
    self.sendViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.sendViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - TATrophySendViewDelegate

- (void)trophySendViewControllerDidPressClose
{
    [self.sendViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)trophySendViewControllerDidPressSend:(TAUser *)selectedUser
{
    TATrophy *trophy = [[TATrophy alloc] init];
    trophy.recipient = selectedUser;
    trophy.author = [TAActiveUserManager sharedManager].activeUser;
    trophy.caption = self.editorView.caption;
    trophy.image = self.cameraImage;
    trophy.time = [NSDate date];
    trophy.likes = 0;
    trophy.comments = nil;

    [[TATrophyManager sharedManager] addTrophyToActiveGroup:trophy
                                                    success:^{
                                                        [self.delegate trophyEditorViewControllerDidSendTrophyWithSuccess];
                                                    } failure:^(NSString *error) {
                                                        NSLog(@"%@", error);
                                                    }];
}

@end
