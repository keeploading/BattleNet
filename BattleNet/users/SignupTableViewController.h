//
//  SignupTableViewController.h
//  BattleNet
//
//  Created by yrliu on 14-6-3.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"

@interface SignupTableViewController : UITableViewController<UITextFieldDelegate>
@property UserManager* userManager;

@end
