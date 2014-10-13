//
//  SDTScriptableAction.m
//  Sketch DevTools Assistant
//
//  Created by Andrey on 09/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTScriptableAction.h"
#import "SDTActionsController.h"
#import "NSLogger.h"

@implementation SDTScriptableAction


-(instancetype)initWithCommandData:(NSDictionary*)data {
    
    self = [super init];
    if(self && data) {
        self.actionID=data[@"id"];
        self.name=data[@"name"];
        self.origin=data[@"origin"];
        self.trigger=data[@"trigger"];
        self.target=data[@"target"];
        self.enabled=[data[@"enabled"] boolValue];
        if([data[@"external"] boolValue]) {
            self.scriptFilePath=data[@"filePath"];
            self.scriptSource=@"";
        } else {
            self.scriptSource=data[@"source"];
            self.scriptFilePath=@"";
        }
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)decoder {

    self = [super init];
    if(self){
        self.actionID = [decoder decodeObjectForKey:@"actionID"];
        self.enabled = [decoder decodeBoolForKey:@"enabled"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.scriptFilePath = [decoder decodeObjectForKey:@"scriptFilePath"];
        self.scriptSource = [decoder decodeObjectForKey:@"scriptSource"];
        self.origin = [decoder decodeObjectForKey:@"origin"];
        self.target = [decoder decodeObjectForKey:@"target"];
        self.trigger = [decoder decodeObjectForKey:@"trigger"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.actionID forKey:@"actionID"];
    [coder encodeBool:self.enabled forKey:@"enabled"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.scriptFilePath forKey:@"scriptFilePath"];
    [coder encodeObject:self.scriptSource forKey:@"scriptSource"];
    [coder encodeObject:self.origin forKey:@"origin"];
    [coder encodeObject:self.target forKey:@"target"];
    [coder encodeObject:self.trigger forKey:@"trigger"];
}

-(void)execute {
    if(!self.enabled) {
        return;
    }
    
    // Executing script from source.
    if([self.scriptFilePath isEqualToString:@""] && ![self.scriptSource isEqualToString:@""]) {
        // [SDTScriptLauncher launchScript:self.scriptSource];
        [SDTActionsController runScript:self.scriptSource target:self.target];

        return;
    }
    
    // Executing script from file.
    if(![self.scriptFilePath isEqualToString:@""] && [self.scriptSource isEqualToString:@""]) {
        if([[NSFileManager defaultManager] fileExistsAtPath:self.scriptFilePath isDirectory:nil]) {
            // [SDTScriptLauncher launchScriptAtURL:[NSURL fileURLWithPath:self.scriptFilePath]];
            [SDTActionsController runScriptAtPath:self.scriptFilePath target:self.target];
            
        } else {
            // TODO: Should throw an error here.
        }
    }
}

-(NSDictionary*)objectAsDictionary {
    
    return @{
             @"id": self.actionID,
             @"name": self.name,
             @"enabled": @(self.enabled),
             @"scriptFilePath": self.scriptFilePath,
             @"scriptSource": self.scriptSource,
             @"origin": self.origin,
             @"target": self.target,
             @"trigger": self.trigger
             };
}

-(BOOL)compare:(SDTScriptableAction*)other {
    return [self.actionID isEqualToString:other.actionID] && [self.name isEqualToString:other.name] && [self.scriptFilePath isEqualToString:other.scriptFilePath] && [self.scriptSource isEqualToString:other.scriptSource] && [self.target isEqualToString:other.target];
}

@end
