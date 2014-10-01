//
//  BNUser.m
//  BattleNet
//
//  Created by Yiru Liu on 14-9-9.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import "BNUser.h"

@implementation BNUser

- (id)init
{
    self = [super init];
    
    self.uid = @"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    self.birth = [dateFormatter dateFromString:@"1988-8-8 12:00:01 +0000"];

    return self;
}

-(id)initWithDictionary:(NSDictionary*)param
{
    self = [super init];
    [self setData:param];
    return self;
}

-(NSDictionary*)toParameter:(BOOL)forSignup
{
    NSString *avatar = @"";
    if (forSignup){
        //If avatar is created and saved at the root directory of user folder
        NSURL *filePath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        NSString *photoPath = [[filePath path] stringByAppendingPathComponent:@"current_user/avatar.png"];
        avatar = [[NSData dataWithContentsOfFile:photoPath] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        if (avatar == nil){
            avatar = @"";
        }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.uid, @"uid",
            self.email, @"email",
            self.password, @"password",
            self.name, @"name",
            avatar, @"avatar",
            [NSNumber numberWithBool:self.gender], @"gender",
            [NSNumber numberWithDouble:[self.birth timeIntervalSince1970]], @"birth",
            [NSNumber numberWithInt:self.position], @"position",
            [NSNumber numberWithInt:self.foot], @"foot", 
            nil
            ];
}

-(void)setData:(NSDictionary*)param
{
    self.uid = [param objectForKey:@"uid"];
    self.email = [param objectForKey:@"email"];
    self.password = [param objectForKey:@"password"];
    self.name = [param objectForKey:@"name"];
    self.gender = [param objectForKey:@"gender"];
    self.birth = [NSDate dateWithTimeIntervalSince1970: [[param objectForKey:@"birth"] doubleValue]];
    self.foot = [[param objectForKey:@"foot"] intValue];
    self.position = [[param objectForKey:@"position"] intValue];
}

@end
