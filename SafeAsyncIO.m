//
//  SafeAsyncIO.m
//  AsyncIO
//
//  Created by Heechul Ryu on 12/7/15.
//  Copyright © 2015 Heechul Ryu. All rights reserved.
//

#import "SafeAsyncIO.h"
#define UIVIEW_LOCKED NO
#define UIVIEW_UNLOKCED YES

@interface SafeAsyncIO ()

@property (nonatomic, strong) NSArray *viewsToBeLocked;
@property (copy) SafeAsyncIOPrePostCallback postprocess;
@property (nonatomic, strong) NSString *uniqueKey;

@end

@implementation SafeAsyncIO

+ (NSString *)uniqueKeyWithRunner:(id<NSObject>)runner alias:(NSString *)alias
{
    NSString *runnersKey = [@(runner.hash) stringValue];

    if(!alias){
        return runnersKey;
    }
    return [NSString stringWithFormat:@"%@-%@", runnersKey, alias];
}

+ (BOOL)checkProcessRunningWithUniqueKey:(NSString *)uniqueKey
{
    return !![[self SafeAsyncIOStore] objectForKey:uniqueKey];
}

+ (BOOL)runIOProcess:(SafeAsyncIOCallback)process
           uniqueKey:(NSString *)uniqueKey
{
    return [self runIOProcess:process uniqueKey:uniqueKey viewsToBeLocked:nil];
}

+ (BOOL)runIOProcess:(SafeAsyncIOCallback)process
           uniqueKey:(NSString *)uniqueKey
     viewsToBeLocked:(NSArray *)viewsToBeLocked
{
    return [self preprocess:nil ioProcess:process postprocess:nil uniqueKey:uniqueKey viewsToBeLocked:viewsToBeLocked];
}

+ (BOOL)preprocess:(SafeAsyncIOPrePostCallback)preprocess
         ioProcess:(SafeAsyncIOCallback)ioProcess
       postprocess:(SafeAsyncIOPrePostCallback)postprocess
         uniqueKey:(NSString *)uniqueKey
{
    return [self preprocess:preprocess ioProcess:ioProcess postprocess:postprocess uniqueKey:uniqueKey viewsToBeLocked:nil];
}

+ (BOOL)preprocess:(SafeAsyncIOPrePostCallback)preprocess
         ioProcess:(SafeAsyncIOCallback)ioProcess
       postprocess:(SafeAsyncIOPrePostCallback)postprocess
         uniqueKey:(NSString *)uniqueKey
   viewsToBeLocked:(NSArray *)viewsToBeLocked
{
    if ([self checkProcessRunningWithUniqueKey:uniqueKey]) {
        return NO;
    }

    SafeAsyncIO *io = [SafeAsyncIO new];
    io.viewsToBeLocked = viewsToBeLocked;
    io.postprocess = postprocess;
    io.uniqueKey = uniqueKey;
    [io lockViews];

    [[self SafeAsyncIOStore] setObject:io forKey:uniqueKey];

    if (preprocess) {
        preprocess();
    }

    ioProcess(io);

    return YES;
}


- (void)done
{
    if(_postprocess) {
        _postprocess();
    }

    [self unlockViews];

    [[[self class] SafeAsyncIOStore] removeObjectForKey:self.uniqueKey];
}

- (void)lockViews
{
    for (UIView *view in _viewsToBeLocked) {
        view.userInteractionEnabled = UIVIEW_LOCKED;
    }
}

- (void)unlockViews
{
    for (UIView *view in _viewsToBeLocked) {
        view.userInteractionEnabled = UIVIEW_UNLOKCED;
    }
}

+ (NSMutableDictionary *)SafeAsyncIOStore
{
    static NSMutableDictionary *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [NSMutableDictionary new];
    });

    return sharedStore;
}

@end


