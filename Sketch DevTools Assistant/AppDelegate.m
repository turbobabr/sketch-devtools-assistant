//
//  AppDelegate.m
//  Sketch DevTools Assistant
//
//  Created by Andrey on 08/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "AppDelegate.h"
#import "SDTProtocolHandler.h"

@interface AppDelegate ()
@property (unsafe_unretained) IBOutlet NSTextView *logView;

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.logView.string=@"Hello!";
    
}

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)getURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)reply
{
    NSURL* url=[NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    if(url && [url.host isEqualToString:@"open"]) {
        
        
        [self logEvent:url];
        
        NSArray* parts=[url.query componentsSeparatedByString:@"&"];
        NSMutableDictionary* params=[NSMutableDictionary dictionary];
        for(NSString* part in parts) {
            NSArray* param=[part componentsSeparatedByString:@"="];
            if(param.count==2) {
                params[param[0]]=param[1];
            }
        }
        
        if(params[@"url"]) {
            NSDictionary* schemeMap =
            @{
              @"skdttmate": @"textmate",
              @"skdtwstorm": @"webstorm",
              @"skdtappcode": @"appcode",
              @"skdtsubl": @"sublime",
              @"skdtatom": @"atom",
              @"skdtxcode": @"xcode",
              @"skdtatom": @"atom",
              @"skdtmvim": @"macvim",
              };
            
            [SDTProtocolHandler openFile:[[NSURL URLWithString:params[@"url"]] path] withIDE:schemeMap[url.scheme] atLine:[params[@"line"] integerValue]];
        }
    }
}

-(void)logEvent:(NSURL*)url {
    self.logView.string=[NSString stringWithFormat:@"%@\n%@",self.logView.string,url];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
