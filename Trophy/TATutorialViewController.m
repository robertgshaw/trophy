//
//  TATutorialViewController.m
//  Trophy
//
//  Created by Robert Shaw on 9/1/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATutorialViewController.h"

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

    // initialize the scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.delegate = self;
    [self.scrollView setBackgroundColor:[UIColor trophyNavyColor]];
    [self.view addSubview:self.scrollView];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 4, self.scrollView.frame.size.height - 100)];
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(0 + 50, 200, 50, 21)];
    [label setText:@"Hello"];
    [self.scrollView addSubview:label];
    
    UILabel *label2  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 50, 200, 50, 21)];
    [label2 setText:@"Hello2"];
    [self.scrollView addSubview:label2];
    
    UILabel *label3  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 2 + 50, 200, 50, 21)];
    [label3 setText:@"Hello3"];
    [self.scrollView addSubview:label3];
    
    UILabel *label4  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 3 + 50, 200, 50, 21)];
    [label4 setText:@"Hello4"];
    [self.scrollView addSubview:label4];
    
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
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.pageControl.frame = frame;
    self.pageControl.numberOfPages = 4;
    self.pageControl.currentPage = 0; 
    [self.view addSubview:self.pageControl];
    self.pageControl.backgroundColor = [UIColor trophyNavyColor];
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
