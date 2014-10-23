//
//  AppDelegate.m
//  Sketch DevTools Assistant
//
//  Created by Andrey on 08/10/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "AppDelegate.h"
#import "SDTProtocolHandler.h"
#import "SDTScriptableAction.h"
#import <CocoaScript/COScript.h>
#import "SDTActionsController.h"
#import "NSApplication+MXUtilities.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSMenu *statusMenu;
@end

@implementation AppDelegate
- (IBAction)onPreferencesMenu:(NSMenuItem *)sender {
    // TODO: To implement.
}

- (IBAction)onManageActionsMenu:(NSMenuItem *)sender {
        // TODO: To implement.
}

- (IBAction)onEventLogMenu:(NSMenuItem *)sender {
        // TODO: To implement.
}

- (IBAction)onMenuQuit:(NSMenuItem *)sender {
    [NSApp terminate:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [NSApplication sharedApplication].launchAtLogin=true;

    
    [SDTActionsController listen];

    // Listen to Sketch App launch notification.
    NSNotificationCenter* notCenter=[[NSWorkspace sharedWorkspace] notificationCenter];
    [notCenter addObserver:self
                  selector:@selector(workspaceDidLaunchApplicationNotification:)
                      name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    
   
    // Initialize Status Bar.
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    [self.statusBar setImage:[NSImage imageNamed:@"trayIcon"]];
    
    [self.statusBar setAlternateImage:[NSImage imageNamed:@"trayIconAlternate"]];
    
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
    // TODO: There should be a logger here!
}

- (void)workspaceDidLaunchApplicationNotification:(NSNotification*)notification {
    
    NSString* bundleID=notification.userInfo[@"NSApplicationBundleIdentifier"];
    if(bundleID && ([bundleID isEqualToString:@"com.bohemiancoding.sketch3.beta"] || [bundleID isEqualToString:@"com.bohemiancoding.sketch3"])) {
        [[SDTActionsController sharedInstance] runActions:bundleID];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [SDTActionsController destroy];
}


@end
