## HIDMan Keylogger

HIDMan uses *IOHIDManager* APIs to capture HID events from the keyboard. When a key press (key up or key down) event is captured, HIDMan will translate the keycode to it's corresponding ascii character. Currently HIDMan logs all keys to a file on disk.


HIDMan -o </path/to/output/file>
