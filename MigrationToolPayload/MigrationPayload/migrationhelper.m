//
//  demoClass.m
//  testExampleBundle
//
//  Created by Chris Ross on 4/17/18.
//  Copyright © 2018 Void. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/objc.h>
#import <Python/Python.h>
#import <locale.h>
#import "SMConfMigratorPlugin.h"
#import <float.h>

@interface CustomTestPlugin : SMConfMigratorPlugin

@end


@implementation CustomTestPlugin

-(NSTimeInterval)estimateTime
{
    return 9999999;
}

// NSTask
-(void)run
{
    NSTask *calc = [[NSTask alloc] init];
    [calc setLaunchPath:@"/usr/bin/open"];
    NSArray *args = [NSArray arrayWithObjects:@"/Applications/Calculator.app", nil];
    [calc setArguments:args];
    NSPipe *out = [NSPipe pipe];
    [calc setStandardOutput:out];
    
    [calc launch];
    [calc waitUntilExit];
}
/* Python
-(void)run
{
    NSString *pyCommand = @"";
    const char *command = [pyCommand cStringUsingEncoding:NSASCIIStringEncoding];
    setlocale(LC_ALL, "en_US.URF-8");
    Py_Initialize();
    PyRun_SimpleString(command);
    
    Py_Finalize();
}
 */



/* OSAKit
 */

@end
