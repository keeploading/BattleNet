//
//  MeViewController.m
//  BattleNet
//
//  Created by yrliu on 14-5-29.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import "MeViewController.h"
#import "LoginViewController.h"
#import "UIKit/UIBarButtonItem.h"

@interface MeViewController ()
@property UIBarButtonItem *loginButton;

@end

@implementation MeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    //LoginViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginIdentifier"];
    //[self.navigationController pushViewController:login animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![[UserManager sharedInstance] isAvailable]){
        self.loginButton = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:self action:@selector(doLogin:)];
        self.navigationItem.rightBarButtonItem = self.loginButton;
    }else{
        if (self.navigationItem.rightBarButtonItem != nil){
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneWithLogin:(UIStoryboardSegue *)segue
{
    
}

- (IBAction)doLogin:(id)sender {
    [self performSegueWithIdentifier:@"ToLogin" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]){
        UINavigationController *navController = [segue destinationViewController];
        
        ((LoginViewController*)navController.viewControllers.lastObject).userManager = [UserManager sharedInstance];
    }
}

@end
