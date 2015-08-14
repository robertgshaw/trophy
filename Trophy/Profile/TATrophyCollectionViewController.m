//
//  TATrophyCollectionViewController.m
//  Trophy
//
//  Created by Gigster on 1/18/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophyCollectionViewController.h"

#import "TATrophyActionFooterView.h"
#import "TATrophy.h"
#import "TATrophyCollectionViewCell.h"
#import "TATrophyCloseupViewController.h"
#import "TACommentTableViewController.h"
#import "UIColor+TAAdditions.h"

#import <Parse/Parse.h>

static const CGFloat kTrophyCollectionViewCellWidth = 250.0;

@interface TATrophyCollectionViewController () <UICollectionViewDelegateFlowLayout,
                                                TATrophyActionFooterDelegate, TATrophyCloseupViewControllerDelegate>

@property (nonatomic, strong) NSIndexPath *indexPathOfCurrentCloseupItem;

@end

@implementation TATrophyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    NSString *reuseIdentifier = NSStringFromClass([TATrophyCollectionViewCell class]);
    [self.collectionView registerClass:[TATrophyCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)setTrophies:(NSArray *)trophies
{
    NSArray* reversed = [[trophies reverseObjectEnumerator] allObjects];
    _trophies = reversed;
    [self.collectionView reloadData];
}

- (void)presentTrophyCloseup:(TATrophy *)trophy
{
    // presents trophy closeup
    TATrophyCloseupViewController *closeupViewController = [[TATrophyCloseupViewController alloc] initWithTrophy:trophy];
    closeupViewController.delegate = self;
    closeupViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:closeupViewController animated:YES];
}

-(void)presentTrophyComments:(TATrophy *)trophy
{
    TACommentTableViewController *commentVC = [[TACommentTableViewController alloc] initWithPhoto:trophy];
    commentVC.delegate = self;
    [self.navigationController pushViewController:commentVC animated:YES];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.trophies count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = NSStringFromClass([TATrophyCollectionViewCell class]);
    TATrophyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.actionFooterDelegate = self;
    PFObject *parseObject = [self.trophies objectAtIndex:indexPath.row];
    cell.trophy = [[TATrophy alloc] initWithStoredTrophy:parseObject];;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // parse query
    PFObject *parseObject = [self.trophies objectAtIndex:indexPath.row];
    
    // sets index path of current closeup cell
    self.indexPathOfCurrentCloseupItem = indexPath;
    
    [self presentTrophyCloseup:[[TATrophy alloc] initWithStoredTrophy:parseObject]];
}

#pragma mark <UICollectionViewFlowLayoutDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kTrophyCollectionViewCellWidth, CGRectGetHeight(self.view.bounds) - 20);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat sidePadding = floorf((CGRectGetWidth(self.view.bounds) - kTrophyCollectionViewCellWidth) / 2.0);
    return UIEdgeInsetsMake(10, sidePadding, 10, sidePadding);
}

#pragma mark - TACloseupViewControllerDelegate Methods
- (void) closeUpViewControllerBackButtonPressed
{
    // "unsets" current closeup
    self.indexPathOfCurrentCloseupItem = nil;
    
    // pops to the trophy collection view controller
    [self.navigationController popToViewController:self.delegate animated:YES];
    
    // displays the nav bar and the tab bar
    self.navigationController.navigationBarHidden = NO;
}

-(void) trophyCloseupDidPerformAction:(TATrophy *)updatedTrophy
{
    // updates only the current closeup cell when an action is performed
    if (self.indexPathOfCurrentCloseupItem != nil)
    {
        [self.collectionView reloadItemsAtIndexPaths:@[self.indexPathOfCurrentCloseupItem]];
    }
}

#pragma mark - TATimelineActionFooterViewDelegate Methods

- (void)trophyActionFooterDidPressLikesButton
{
    
}

- (void)trophyActionFooterDidPressCommentsButton
{
    
}

- (void)trophyActionFooterDidPressAddButton
{
    
}

@end
