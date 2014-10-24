//
//  SDTAppleScriptCommandRunAtPath.m
//  Sketch DevTools Assistant
//
//  Created by Andrey on 20/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTAppleScriptCommandRunScriptAtPath.h"
#import "AppDelegate.h"
#import "NSLogger.h"

#import "SDTActionsController.h"
#import "Constants.h"

#import "NSBundle+OBCodeSigningInfo.h"

@implementation SDTAppleScriptCommandRunScriptAtPath


- (id)performDefaultImplementation {
    
    // Get current running environment.
    // We need to get info what variand of Sketch we are running now (release or beta) and whether it's sandboxed or not to privide script runner with the actual file path in case client used relative script path.
    NSDictionary* env=[self runningEnv];
    if(!env) return nil;
    
    // Checking for relative pathes and replace './' component to the apropriate plugins root folder depending on the current environment.
    NSString* filePath=[self resolveFilePath:self.directParameter env:env];
    if(!filePath) return nil;
    
    // Check if script file exists. If not, we're aboring the launching process and notify user.
    // The notification should be noticeable through user interface since it's a end user issue and he should be informed.
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    
        // If client provided data object, we have to compile a custom script with injected data object and pass it to the launcher.
        // If there is no such object, we're just running the original script file without any vandalization.
        NSString* data=self.arguments[@"data"];
        if(data) {
    
            // Create temporary script file with injected data as '$data' variable at first line of the script.
            NSString* newFileName=[NSString stringWithFormat:@"__%@_sketchdevtools__.js",[[filePath stringByDeletingPathExtension] lastPathComponent]];
            NSString* tempFilePath=[[filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFileName];

            // Escaping quote and backquote symbols.
            data = [data stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            data = [data stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];

            
            NSString* source=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSString* argument=[NSString stringWithFormat:@"var $data = JSON.parse('%@');\n",data];
            
            
            NSString* processedSource=[argument stringByAppendingString:[NSString stringWithFormat:@"var $modifierFlags = %@;\n",[@([NSEvent modifierFlags]) stringValue]]];
            
            processedSource=[processedSource stringByAppendingString:source];
            
            [processedSource writeToFile:tempFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
            
            [SDTActionsController runScriptAtPath:tempFilePath target:env[@"target"]];
            
            // Remove temprary created script.
            [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
        } else {
            [SDTActionsController runScriptAtPath:filePath target:env[@"target"]];
        }
        
    } else {
        NSAlert* alert=[NSAlert alertWithMessageText:@"Error: Could not run script" defaultButton:@"Close" alternateButton:@"" otherButton:nil informativeTextWithFormat:@"The specified script file isn't exist:\n'%@'",filePath];
        [alert runModal];
    }
    
    return nil;
}


@end
