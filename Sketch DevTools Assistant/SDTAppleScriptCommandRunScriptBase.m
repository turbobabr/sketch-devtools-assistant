//
//  SDTAppleScriptCommandRunScriptBase.m
//  Sketch DevTools Assistant
//
//  Created by Andrey on 20/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTAppleScriptCommandRunScriptBase.h"
#import "AppDelegate.h"
#import "NSLogger.h"

#import "SDTActionsController.h"
#import "Constants.h"

#import "NSBundle+OBCodeSigningInfo.h"


@implementation SDTAppleScriptCommandRunScriptBase

-(NSString*)resolveFilePath:(NSString*)filePath env:(NSDictionary*)env {
    if(!env) return nil;
    
    NSString* target=env[@"target"];
    BOOL isSandboxed=[env[@"isSandboxed"] boolValue];
    
    NSString* rootPath=nil;
    if([target isEqualToString:kSketchReleaseBundleID]) {
        rootPath=(isSandboxed) ? kPluginFolderPathSandboxed : kPluginFolderPathNormal;
    } else if([target isEqualToString:kSketchBetaBundleID]) {
        rootPath=(isSandboxed) ? kPluginFolderPathBetaSandboxed : kPluginFolderPathNormal;
    }
    
    if(!rootPath) return nil;
    
    if([filePath rangeOfString:@"./"].location==0){
        NSString* pluginsRoot=[rootPath stringByExpandingTildeInPath];
        
        NSMutableArray* components=[NSMutableArray arrayWithArray:filePath.pathComponents];
        [components removeObjectAtIndex:0];
        
        return [NSString pathWithComponents:[pluginsRoot.pathComponents arrayByAddingObjectsFromArray:components]];
    }
    
    return [filePath stringByExpandingTildeInPath];
}

-(NSDictionary*)runningEnvForBundleWithIdentifier:(NSString*)bundleIdentifier {
    
    // Check running instances of an application with the provided bundle id.
    NSArray* instances=[NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    if(instances && instances.count>0) {
        // Check if Sandboxed.
        NSBundle* bundle=[NSBundle bundleWithPath:[[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleIdentifier]];
        if(bundle) {
            return @{ @"target" : bundleIdentifier, @"isSandboxed" : @([bundle ob_isSandboxed]) };
        }
    }
    
    return nil;
}

-(NSDictionary*)runningEnv {
    
    // We prefere to work with `release` version of Sketch if it's currently running.
    NSDictionary* env=[self runningEnvForBundleWithIdentifier:kSketchReleaseBundleID];
    if(env) return env;
    
    // If `release` version isn't running, trying to work with beta.
    return [self runningEnvForBundleWithIdentifier:kSketchBetaBundleID];
}


@end
