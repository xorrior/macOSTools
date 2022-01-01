# macOSTools
macOS Offensive Tools

### AUnit
Example XCode project for Audio Unit Plugins

### MigrationToolPayload
Migration tool plugin

### SpecialDelivery
Installer plugin

### auth_plugin
Authentication Plugin

### dylibinjection
Source code for dylib injection. Based off of code from Jonathan Levin http://newosxbook.com/src.jl?tree=listings&file=inject.c

### HIDMan
IOHIDManager keylogger

### Script Runners
### jxa_runner

Rust library for in-memory JXA execution

Prerequisites

1. [Rust](https://www.rust-lang.org/tools/install)

2. Mythic JXA Payload. Saved to disk

Build Steps

1. Use the `PAYLOAD` and `KEY` environment variables with `cargo build` to generate the lib. KEY will be used as a static XOR key.
2. `PAYLOAD=apfell.js KEY=SOMEKEY cargo build --release`
3. Release build is in `target/release/libjxa_runner.dylib`

### python_runner
Rust library for in-memory Python execution

Prerequisites

1. [Rust](https://www.rust-lang.org/tools/install)

2. Mythic Medusa (Python) Payload. Saved to disk

Build Steps

1. Use the `PAYLOAD` and `KEY` environment variables with `cargo build` to generate the lib. KEY will be used as a static XOR key.
2. `PAYLOAD=medusa.py KEY=SOMEKEY cargo build --release`
3. Release build is in `target/release/libpython_runner.dylib`
4. For debug versions, a log file is created in `/private/tmp/python_runner.log`