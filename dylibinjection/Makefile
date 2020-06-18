GCC_BIN_OSX=`xcrun --sdk macosx --find gcc`
SDK_OSX=`xcrun --sdk macosx --show-sdk-path`
GCC_OSX=$(GCC_BASE_OSX) -arch x86_64 -fpic
GCC_BASE_OSX = $(GCC_BIN_OSX) -Wimplicit -isysroot $(SDK_OSX) -F$(SDK_OSX)/System/Library/Frameworks -F$(SDK_OSX)/System/Library/PrivateFrameworks

all: dylibinject

dylibinject: libraryinjection.c
	$(GCC_OSX) -o $@ $^
	$(GCC_OSX) -o testpayload.dylib -dynamiclib tester.c

clean:
	rm -f *.o dylibinject