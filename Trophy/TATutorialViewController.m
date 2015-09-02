//
//  TATutorialViewController.m
//  Trophy
//
//  Created by Robert Shaw on 9/1/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATutorialViewController.h"
#import "TATutorialView.h"
#import "UIColor+TAAdditions.h"

@interface TATutorialViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation TATutorialViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // hides nav bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.view.backgroundColor = [UIColor trophyRedColor];

    // initialize the scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50)];
    self.scrollView.delegate = self;
    [self.scrollView setBackgroundColor:[UIColor trophyNavyColor]];
    [self.view addSubview:self.scrollView];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 4, self.scrollView.frame.size.height - 100)];
    
    // initialize the frames for the tutorial views
    CGRect frame1 = CGRectZero;
    frame1.origin = CGPointMake(0, 0);
    frame1.size = CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height);
    
    CGRect frame2 = CGRectZero;
    frame2.origin = CGPointMake(self.view.frame.size.width, 0);
    frame2.size = frame1.size;
    
    CGRect frame3 = CGRectZero;
    frame3.origin = CGPointMake(self.view.frame.size.width * 2, 0);
    frame3.size = frame1.size;
    
    CGRect frame4 = CGRectZero;
    frame4.origin = CGPointMake(self.view.frame.size.width * 3, 0);
    frame4.size = frame1.size;
    
    // initializes tutorial views
    TATutorialView *tutorialView1 = [[TATutorialView alloc] initWithFrame:frame1 image:[UIImage imageNamed:@"tutorial-image-1-1"] caption:@"A trophy is a photo and a description that you award to a friend."];
    [self.scrollView addSubview:tutorialView1];
    
    TATutorialView *tutorialView2 = [[TATutorialView alloc] initWithFrame:frame2 image:[UIImage imageNamed:@"tutorial-image-2-1"] caption:@"Capture a trophy in the moment, or dig up an old photo for the group to relive."];
    [self.scrollView addSubview:tutorialView2];
    
    TATutorialView *tutorialView3 = [[TATutorialView alloc] initWithFrame:frame3 image:[UIImage imageNamed:@"tutorial-image-3-1"] caption:@"Compete for the top spot in the Hall of Fame. Who has what it takes?"];
    [self.scrollView addSubview:tutorialView3];
    
    TATutorialView *tutorialView4 = [[TATutorialView alloc] initWithFrame:frame4 image:[UIImage imageNamed:@"tutorial-image-4-1"] caption:@"Everything stays private within the group. Photos, comments, and profiles."];
    [self.scrollView addSubview:tutorialView4];
    
    // configure scroll view to only allow paganation
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // page control button
    self.pageControl = [[UIPageControl alloc] init];
    [self.pageControl sizeToFit];
    CGRect frame = self.pageControl.frame;
    frame.size = CGSizeMake(100, 30);
    frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = tutorialView1.frame.size.height * .2 + tutorialView1.frame.size.height * .04 + 20;
    self.pageControl.frame = frame;
    self.pageControl.numberOfPages = 4;
    self.pageControl.currentPage = 0; 
    [self.view addSubview:self.pageControl];
    self.pageControl.backgroundColor = [UIColor clearColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    // scroll view / pageanation / page control
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
    
}

@end
