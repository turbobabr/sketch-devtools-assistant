//
//  SDTActionsController.m
//  Sketch DevTools Assistant
//
//  Created by Andrey on 09/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"


#import "SDTActionsController.h"
#import "SDTScriptableAction.h"
#import <CocoaScript/COScript.h>
#import "Constants.h"
#import "NSLogger.h"

@implementation SDTActionsController

+(SDTActionsController*)sharedInstance {
    static dispatch_once_t once;
    static SDTActionsController *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}


-(void)runActions:(NSString*)target {
    NSMutableArray *actions = [self deserialize];
    for(SDTScriptableAction* action in actions) {
        if([action.target isEqualToString:target]) {
            [action execute];
        }
    }
}

-(void)addAction:(SDTScriptableAction*)action {
    if([self exists:action]) {
        return;
    }
    
    NSMutableArray* actions=[self deserialize];
    [actions addObject:action];
    [self serialize:actions];
}

-(BOOL)exists:(SDTScriptableAction*)action {
    NSMutableArray *actions = [self deserialize];
    for(SDTScriptableAction* act in actions) {
        if([action compare:act]) return true;
    }
    
    return false;
}

-(void)removeAction:(SDTScriptableAction*)action {
   
}

-(void)removeAllActions {
    [self serialize:[NSMutableArray array]];
};

-(void)serialize:(NSMutableArray*)actions {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *archivedObject = [NSKeyedArchiver archivedDataWithRootObject:actions];
    [defaults setObject:archivedObject forKey:@"actions"];
    [defaults synchronize];
}

-(NSMutableArray*)deserialize {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"actions"]) {
        NSData *archivedObject = [defaults objectForKey:@"actions"];
        return (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    }
    
    return [NSMutableArray array];
}

-(void)logActions:(NSString*)label {
    
    NSLog(@"%@",label);
    NSLog(@"--------------------------------");
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"actions"]) {
        NSData *archivedObject = [defaults objectForKey:@"actions"];
        NSMutableArray *actions = (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
        
        for(SDTScriptableAction* action in actions) {
            NSLog(@"%@",[action objectAsDictionary]);
        }
    }
    
    NSLog(@"--------------------------------");
    NSLog(@" ");
}

-(void)removeActionWithID:(NSString*)actionID target:(NSString*)target {
    
    NSMutableArray *actions = [self deserialize];
    NSInteger index=0;
    for(SDTScriptableAction* action in actions) {
        if([action.actionID isEqualToString:actionID] && [action.target isEqualToString:target]) {
            [actions removeObjectAtIndex:index];
            [self serialize:actions];
            break;
        }
        
        index++;
    }
}

-(void)enableActionWithID:(NSString*)actionID target:(NSString*)target enabled:(BOOL)enabled {
    
    NSMutableArray *actions = [self deserialize];
    for(SDTScriptableAction* action in actions) {
        if([action.actionID isEqualToString:actionID] && [action.target isEqualToString:target]) {
            action.enabled=enabled;
            [self serialize:actions];
            break;
        }
    }
}

+(void)listen {
    SDTActionsController* shared=[SDTActionsController sharedInstance];
    [shared initializeCommandObservers];
}

-(void)initializeCommandObservers {
    NSString *observedObject = @"com.turbobabr.sketch.devtools.command";
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    
    [center addObserver: self selector: @selector(externalCommandReleaseNormal:) name:@"release-normal" object: observedObject];
    [center addObserver: self selector: @selector(externalCommandReleaseSandboxed:) name:@"release-sandboxed" object: observedObject];
    [center addObserver: self selector: @selector(externalCommandBetaNormal:) name:@"beta-normal" object: observedObject];
    [center addObserver: self selector: @selector(externalCommandBetaSandboxed:) name:@"beta-sandboxed" object: observedObject];
}

+(void)destroy {
    SDTActionsController* shared=[SDTActionsController sharedInstance];
    [shared removeCommandObservers];
}

-(void)removeCommandObservers {
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    [center removeObserver:self name: @"release-normal" object: nil];
    [center removeObserver:self name: @"release-sandboxed" object: nil];
    [center removeObserver:self name: @"beta-normal" object: nil];
    [center removeObserver:self name: @"beta-sandboxed" object: nil];
}

-(void)externalCommandReleaseNormal:(NSNotification*)notification
{
    [self processNotifications:false isBeta:false];
}

-(void)externalCommandReleaseSandboxed:(NSNotification*)notif
{
    [self processNotifications:true isBeta:false];
}

-(void)externalCommandBetaNormal:(NSNotification*)notification
{
    [self processNotifications:false isBeta:true];
}

-(void)externalCommandBetaSandboxed:(NSNotification*)notif
{
    [self processNotifications:true isBeta:true];
}


-(void)processNotifications:(BOOL)isSandboxed isBeta:(BOOL)isBeta {
    NSString* filePath = [NSString stringWithFormat:@"%@/%@",[(isSandboxed ? (isBeta ? kPluginFolderPathBetaSandboxed : kPluginFolderPathSandboxed) : kPluginFolderPathNormal) stringByExpandingTildeInPath],kExchangeFileName];
    NSDictionary *commandInfo = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:kNilOptions error:nil];
    
    if(commandInfo[@"command"]) {
        if([commandInfo[@"command"] isEqualToString:@"RegisterAction"]) {
            SDTScriptableAction* action=[[SDTScriptableAction alloc] initWithCommandData:commandInfo[@"data"]];
            [self addAction:action];
            
        } else if([commandInfo[@"command"] isEqualToString:@"RemoveAction"]) {
            [self removeActionWithID:commandInfo[@"data"][@"id"] target:commandInfo[@"data"][@"target"]];
        } else if([commandInfo[@"command"] isEqualToString:@"EnableAction"]) {
            NSDictionary* data=commandInfo[@"data"];
            [self enableActionWithID:data[@"id"] target:data[@"target"] enabled:[data[@"value"] boolValue]];
        }
    }
}


+(id)sketchAppController:(NSString*)bundleID {
    return [[COScript app:([bundleID isEqualToString:@"com.bohemiancoding.sketch3.beta"]) ? @"Sketch Beta" : @"Sketch"] delegate];
}

+(void)runScriptAtPath:(NSString*)filePath target:(NSString*)target {
    [self runScriptAtURL:[NSURL fileURLWithPath:filePath] target:target];
};

+(void)runScriptAtURL:(NSURL*)url target:(NSString*)target {
    
    id appController=[self sketchAppController:target];
    SEL sel=NSSelectorFromString(@"runPluginAtURL:");
    if([appController respondsToSelector:sel]) {
        [appController performSelector:sel withObject:url];
        // [appController performSelector:NSSelectorFromString(@"refreshCurrentDocument")];
    }
};

+(void)runScript:(NSString*)source target:(NSString*)target {
    
    id appController=[self sketchAppController:target];
    SEL sel=NSSelectorFromString(@"runPluginScript:");
    if([appController respondsToSelector:sel]) {
        [appController performSelector:sel withObject:source];
        // [appController performSelector:NSSelectorFromString(@"refreshCurrentDocument")];
    }
}

#pragma clang diagnostic pop

@end
