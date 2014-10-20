//
//  SDTAppleScriptCommandRunScriptBase.h
//  Sketch DevTools Assistant
//
//  Created by Andrey on 20/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDTAppleScriptCommandRunScriptBase : NSScriptCommand

-(NSString*)resolveFilePath:(NSString*)filePath env:(NSDictionary*)env;
-(NSDictionary*)runningEnv;

@end
