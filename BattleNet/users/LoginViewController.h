//
//  LoginViewController.h
//  BattleNet
//
//  Created by yrliu on 14-5-29.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UITextField *accountName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property UserManager *userManager;

@end
