//
//  SDTScriptableAction.h
//  Sketch DevTools Assistant
//
//  Created by Andrey on 09/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDTScriptableAction : NSObject <NSCoding>


@property BOOL enabled;
@property NSString* actionID;
@property NSString* name;
@property NSString* scriptFilePath;
@property NSString* scriptSource;
@property NSString* origin;
@property NSString* target;
@property NSString* trigger;


-(void)execute;
-(instancetype)initWithCommandData:(NSDictionary*)data;
-(NSDictionary*)objectAsDictionary;

-(BOOL)compare:(SDTScriptableAction*)other;

@end
