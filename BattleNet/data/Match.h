//
//  Match.h
//  BattleNet
//
//  Created by Yiru Liu on 14-9-29.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CourtType) {
    CourtType_5,
    CourtType_7,
    CourtType_11
};

typedef NS_ENUM(NSInteger, FeeType) {
    FeeType_AA,
    FeeType_Loser,
    FeeType_Home,
    FeeType_Away
};

@interface Match : NSObject

@property (nonatomic) NSDate *time;
@property (nonatomic) NSString *placeId;
@property (nonatomic) NSString *orgnizerTeam;
@property (nonatomic) CourtType courtType;
@property (nonatomic) int feeType;
@property (nonatomic) NSString *description;

@end
