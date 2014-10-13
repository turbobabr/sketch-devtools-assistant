//
//  SDTActionsController.h
//  Sketch DevTools Assistant
//
//  Created by Andrey on 09/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SDTScriptableAction;

@interface SDTActionsController : NSObject

+(SDTActionsController*)sharedInstance;

-(void)runActions:(NSString*)target;

-(void)addAction:(SDTScriptableAction*)action;
-(void)removeAction:(SDTScriptableAction*)action;
-(void)removeActionWithID:(NSString*)name target:(NSString*)target;

+(void)listen;
+(void)destroy;

+(void)runScriptAtPath:(NSString*)filePath target:(NSString*)target;
+(void)runScriptAtURL:(NSURL*)url target:(NSString*)target;
+(void)runScript:(NSString*)source target:(NSString*)target;

@end
