//
//  Match.m
//  BattleNet
//
//  Created by Yiru Liu on 14-9-29.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import "Match.h"

@implementation Match

-(id)init
{
    self = [super init];
    if (self != nil){
        _courtType = CourtType_7;
        //_time = [NSDate date];
    }
    return self;
}

@end
