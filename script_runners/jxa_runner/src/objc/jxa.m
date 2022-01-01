
#import <Foundation/Foundation.h>
#import <Appkit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <OSAKit/OSAKit.h>
#import <Cocoa/Cocoa.h>
#import <OSAKit/OSALanguage.h>
#import <Foundation/NSString.h>
#include <string.h>

void runjxa(const char* code) {
    NSString *codeStr = [[NSString alloc] initWithCString:code encoding:NSUTF8StringEncoding];
    OSALanguage *lang = [OSALanguage languageForName:@"JavaScript"];
    OSAScript *script = [[OSAScript alloc] initWithSource:codeStr language:lang];
    NSDictionary *__autoreleasing compileError;
    NSDictionary *__autoreleasing runError;
    [script compileAndReturnError:&compileError];
    NSAppleEventDescriptor *res = [script executeAndReturnError:&runError];
}