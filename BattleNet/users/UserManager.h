//
//  UserManager.h
//  BattleNet
//
//  Created by Yiru Liu on 14-9-17.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNUser.h"

@interface UserManager : NSObject

@property (nonatomic) BNUser *me;

-(void)signup:(void(^)(NSDictionary* response))callback;
-(void)login:(NSDictionary*)param withCallback:(void(^)(NSDictionary* response))callback;
-(BOOL)isAvailable;

+ (UserManager*)sharedInstance;

@end
