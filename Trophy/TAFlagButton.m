//
//  TAFlagButton.m
//  Trophy
//
//  Created by Robert Shaw on 8/11/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAFlagButton.h"
#import "UIColor+TAAdditions.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface TAFlagButton ()

@property (nonatomic, strong) UILabel *flagLabel;
@property (nonatomic, strong) UIImageView *flagLogo;

@end

@implementation TAFlagButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addTarget:self action:@selector(didPressFlagButton) forControlEvents:UIControlEventTouchUpInside];
        
        // initializes back label
        self.flagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.flagLabel.text = @"Flag";
        self.flagLabel.textColor = [UIColor trophyYellowColor];
        [self addSubview:self.flagLabel];
        
        // initializes back logo
        self.flagLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag-icon"]];
        [self addSubview:self.flagLogo];
    
    }
    
    return self;
}

- (void) layoutSubviews
{
    // lays out the back logo
    CGRect frame = self.flagLogo.frame;
    frame.size = CGSizeMake(20.0, 20.0);
    frame.origin.x = 0.0;
    frame.origin.y = 0.0;
    self.flagLogo.frame = frame;
    
    // lays out the back label
    [self.flagLabel sizeToFit];
    frame = self.flagLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.flagLogo.frame) + 1;
    frame.origin.y = self.flagLogo.frame.origin.y;
    self.flagLabel.frame = frame;
}


#pragma mark - button action handlers
- (void)didPressFlagButton {
    
    // alert - yes/no for flag
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag Trophy" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil]; [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // Set buttonIndex == 0 to handel "Ok"/"Yes" button response
        // Ok button response
        
        //Query parse
        PFQuery *query = [PFQuery queryWithClassName:@"Trophy"];
        [query whereKey:@"objectId" equalTo: [[self.delegate getTATrophy] getTrophyAsParseObject].objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError *error) {
            if (!error) {
                // The find succeeded.
                
                //flag function
                [object setObject:[NSNumber numberWithBool:YES] forKey:@"flag"];
                
                [object saveInBackground];
                NSLog(@"Successfully flagged. This trophy will be reviewed for removal.");
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }
}


@end
