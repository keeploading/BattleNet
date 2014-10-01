//
//  BNUser.h
//  BattleNet
//
//  Created by Yiru Liu on 14-9-9.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BNUserPosition) {
    BNUserPosition_Fan,
    BNUserPosition_GK,
    BNUserPosition_CB,
    BNUserPosition_LSB,
    BNUserPosition_RSB,
    BNUserPosition_DMF,
    BNUserPosition_LMF,
    BNUserPosition_RMF,
    BNUserPosition_OMF,
    BNUserPosition_CF,
    BNUserPosition_SS,
    BNUserPosition_LWF,
    BNUserPosition_RWF
};

typedef NS_ENUM(NSUInteger, BNUserFoot) {
    BNUserFoot_Right,
    BNUserFoot_Left,
    BNUserFoot_Both
};

@interface BNUser : NSObject

@property (nonatomic) NSString *uid;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *name;
@property (nonatomic) BOOL gender;
@property (nonatomic) NSDate* birth;
@property (nonatomic) BNUserPosition position;
@property (nonatomic) BNUserFoot foot;

-(id)initWithDictionary:(NSDictionary*)param;

-(NSDictionary*)toParameter:(BOOL)forSignup;
-(void)setData:(NSDictionary*)param;

@end
