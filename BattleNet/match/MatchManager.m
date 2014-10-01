//
//  MatchManager.m
//  BattleNet
//
//  Created by Yiru Liu on 14-9-29.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import "MatchManager.h"

@implementation MatchManager

+ (id)sharedInstance
{
    static MatchManager *instance = nil;
    @synchronized(self) {
        if (instance == nil)
            instance = [[self alloc] init];
    }
    return instance;
}

@end
