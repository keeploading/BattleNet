//
//  UserManager.m
//  BattleNet
//
//  Created by Yiru Liu on 14-9-17.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import "UserManager.h"
#import "AFHTTPRequestOperationManager.h"

@implementation UserManager

+ (id)sharedInstance
{
    static UserManager *instance = nil;
    @synchronized(self) {
        if (instance == nil)
            instance = [[self alloc] init];
    }
    return instance;
}

- (id)init
{
    if (self = [super init]){
        NSString *userPath = [self currentUserDir];
        BOOL isDirector;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:userPath isDirectory:&isDirector]){
            [fileManager createDirectoryAtPath:userPath withIntermediateDirectories:NO attributes:nil error:NULL];
        }

        NSString *userProfilePath = [userPath stringByAppendingPathComponent:@"profile"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:userProfilePath isDirectory:&isDirector]){
            self.me = [[BNUser alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:userProfilePath]];
        }else{
            self.me = [[BNUser alloc] init];
        }
    }
    return self;
}

-(BOOL)isAvailable
{
    return self.me.uid.length > 0;
}

- (void)login:(NSDictionary*)param withCallback:(void(^)(NSDictionary* response))callback
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"http://localhost:8080/user/login" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([@"succeeded" compare:[responseObject objectForKey:@"result"]] == NSOrderedSame){
            NSDictionary *myData = [responseObject objectForKey:@"user"];
            [self.me setData:myData];
            if (((NSNumber*)[myData objectForKey:@"has_avatar"]).boolValue){
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
                NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:self.me.uid, @"user_id", nil];
                [manager GET:@"http://localhost:8080/user/avatar" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if ([@"succeeded" compare:[responseObject objectForKey:@"result"]] == NSOrderedSame){
                        NSData *avatarData = [[NSData alloc] initWithBase64EncodedString:[responseObject objectForKey:@"avatar"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        [avatarData writeToFile:[[self currentUserDir] stringByAppendingPathComponent:@"avatar.png"] atomically:NO];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                }];
            }
        }
        callback(responseObject);
        [self save];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil);
    }];
    
}

- (void)signup:(void(^)(NSDictionary* response))callback
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = [self.me toParameter:YES];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //[[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"http://localhost:8080/user/create" parameters:parameters];
    
    [manager POST:@"http://localhost:8080/user/create" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.me.uid = [responseObject objectForKey:@"uid"];
        callback(responseObject);
        [self save];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil);
    }];

}

-(void)save
{
    [[self.me toParameter:NO] writeToFile:[[self currentUserDir] stringByAppendingPathComponent:@"profile"] atomically:YES];
}

-(NSString*)currentUserDir
{
    NSURL *filePath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    return [[filePath path] stringByAppendingPathComponent:@"current_user"];

}

@end
