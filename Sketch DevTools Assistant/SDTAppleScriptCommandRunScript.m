//
//  SDTAppleScriptCommandRunScript.m
//  Sketch DevTools Assistant
//
//  Created by Andrey on 20/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTAppleScriptCommandRunScript.h"
#import "AppDelegate.h"
#import "NSLogger.h"
#import "SDTActionsController.h"

@implementation SDTAppleScriptCommandRunScript

- (id)performDefaultImplementation {
    
    NSDictionary* env=[self runningEnv];
    if(!env) return nil;
    
    NSString* scriptSource=[self directParameter];
    if(!scriptSource) return nil;

    [SDTActionsController runScript:scriptSource target:env[@"target"]];
    
    // Have no idea what happened with refreshment bug, but now everything works fine.
    /*
    NSString* refreshScript=@"doc.currentContentViewController().contentDrawView().refresh();";
    [SDTActionsController runScript:refreshScript target:@"com.bohemiancoding.sketch3"];
     */
    
    return nil;
}


@end
