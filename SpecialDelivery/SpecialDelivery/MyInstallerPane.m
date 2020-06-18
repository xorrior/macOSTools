//
//  MyInstallerPane.m
//  SpecialDelivery
//
//  Created by xorrior on 5/2/20.
//  Copyright © 2020 xorrior. All rights reserved.
//

#import "MyInstallerPane.h"
#include <assert.h>

// This code executes when the bundle is initially loaded by the InstallerRemotePluginService
__attribute__((constructor)) static void detonate()
{
    // Just a message box payload
   NSAlert *alert = [[NSAlert alloc] init];
   [alert setMessageText:@"Install complete"];
   [alert addButtonWithTitle:@"OK"];
   [alert setAlertStyle:NSAlertStyleInformational];
    
   [alert runModal];

}

@implementation MyInstallerPane

- (NSString *)title
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PaneTitle" value:nil table:nil];
}

- (void)willEnterPane:(InstallerSectionDirection)dir {
    // This winodw
}

- (void) willExitPane:(InstallerSectionDirection)dir {
    return;
}

- (BOOL)shouldExitPane:(InstallerSectionDirection)dir
{
    return YES;
}

@end
