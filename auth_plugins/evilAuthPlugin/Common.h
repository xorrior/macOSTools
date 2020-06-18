//
//  Common.h
//  evilAuthPlugin
//
//  Created by Chris Ross on 9/25/18.
//

#ifndef Common_h
#define Common_h
#import <Foundation/Foundation.h>

BOOL ValidateLoginPassword(NSString *newPassword);
BOOL ValidateLoginKeychainPassword(NSString *OldPassword);

#endif /* Common_h */
