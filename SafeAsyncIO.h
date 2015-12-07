//
//  SafeAsyncIO.h
//  AsyncIO
//
//  Created by Heechul Ryu on 12/7/15.
//  Copyright © 2015 Heechul Ryu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SafeAsyncIO : NSObject

typedef void(^SafeAsyncIOCallback)(SafeAsyncIO *io);
typedef void(^SafeAsyncIOPrePostCallback)(void);

+ (NSString *)uniqueKeyWithRunner:(id<NSObject>)runner alias:(NSString *)alias;

+ (BOOL)checkProcessRunningWithUniqueKey:(NSString *)uniqueKey;

+ (BOOL)runIOProcess:(SafeAsyncIOCallback)process
           uniqueKey:(NSString *)uniqueKey;

+ (BOOL)runIOProcess:(SafeAsyncIOCallback)process
           uniqueKey:(NSString *)uniqueKey
     viewsToBeLocked:(NSArray *)viewsToBeLocked;

+ (BOOL)preprocess:(SafeAsyncIOPrePostCallback)preprocess
         ioProcess:(SafeAsyncIOCallback)ioProcess
       postprocess:(SafeAsyncIOPrePostCallback)postprocess
         uniqueKey:(NSString *)uniqueKey;

+ (BOOL)preprocess:(SafeAsyncIOPrePostCallback)preprocess
         ioProcess:(SafeAsyncIOCallback)ioProcess
       postprocess:(SafeAsyncIOPrePostCallback)postprocess
         uniqueKey:(NSString *)uniqueKey
   viewsToBeLocked:(NSArray *)viewsToBeLocked;

- (void)done;

@end