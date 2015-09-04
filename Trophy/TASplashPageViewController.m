//
//  TASplashPageViewController.m
//  
//
//  Created by Matt Deveney on 9/4/15.
//
//

#import "TASplashPageView.h"
#import "UIColor+TAAdditions.h"
#import "TASplashPageViewController.h"
#import "TATutorialViewController.h"

@interface TASplashPageViewController () <TATutorialViewControllerDelegate>

@property (nonatomic, strong) TASplashPageView *splashPageView;

@end

@implementation TASplashPageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.splashPageView = [[TASplashPageView alloc] initWithFrame:self.view.bounds];
     self.splashPageView.backgroundColor = [UIColor trophyNavyColor];
    [self.view addSubview:self.splashPageView];
    
    // hides nav bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark TASplashView Delegate Methods

- (void)splashPageViewDidPressGetStarted:(TASplashPageView *)splashPageView
{
    TATutorialViewController *tutorialViewController = [[TATutorialViewController alloc] init];
    tutorialViewController.delegate = self;
    [self.navigationController pushViewController:tutorialViewController animated:YES];
}




@end
