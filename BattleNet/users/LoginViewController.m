//
//  LoginViewController.m
//  BattleNet
//
//  Created by yrliu on 14-5-29.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import "LoginViewController.h"
#import "SignupTableViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@end

@implementation LoginViewController

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
    self.accountName.delegate = self;
    self.password.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.accountName == textField){
        [self.password becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
        NSString *str = self.accountName.text;
        if (str.length < 4 || [str rangeOfString:@"@"].location == NSNotFound){
            [self.errorMessage setText:@"请正确填写邮件地址。"];
            self.errorMessage.hidden = NO;
        }else{
            str = self.password.text;
            if (str.length < 6){
                [self.errorMessage setText:@"密码长度不能少于6个字符。"];
                self.errorMessage.hidden = NO;
            }
        }
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:self.accountName.text, @"email", self.password.text, @"password", nil];
        [self.userManager login:param withCallback:^(NSDictionary *response) {
            if (response == nil){
                [self.errorMessage setText:@"网络连接错误，请稍后重试。"];
                self.errorMessage.hidden = NO;
            }else if ([@"succeeded" compare:[response objectForKey:@"result"]] == NSOrderedSame){
                [self dismissViewControllerAnimated:YES completion:nil];
            }else if ([@"account_not_exist" compare:[response objectForKey:@"result"]] == NSOrderedSame){
                [self.errorMessage setText:@"您输入的邮箱未被注册。"];
                self.errorMessage.hidden = NO;
            }else if ([@"wrong_password" compare:[response objectForKey:@"result"]] == NSOrderedSame){
                [self.errorMessage setText:@"您输入的密码不正确。"];
                self.errorMessage.hidden = NO;
            }
        }];
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[SignupTableViewController class]]){
        ((SignupTableViewController*)segue.destinationViewController).userManager = self.userManager;
    }
}

@end
