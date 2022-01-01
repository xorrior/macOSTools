extern crate cc;

use cc::Build;
use std::env;
use std::fs::File;
use std::fs;
use std::io::{Read, Write};
use std::path::Path;

// https://github.com/codeSamuraii/PrettyBadPrivacy/blob/master/src/main.rs
fn xor_routine<'a>(val: &[u8], key: &[u8]) -> Vec<u8> {
    let encrypted_buffer: Vec<u8> = val.iter().zip(Vec::from(key).iter().cycle()).map(|(&x, &y)| x ^ y).collect();
    return encrypted_buffer;
}

fn main() {
    // Compile jxa runner
    println!("cargo:rustc-link-lib=framework=Foundation");
    println!("cargo:rustc-link-lib=framework=OSAKit");
    Build::new()
        .file("src/objc/jxa.m")
        .include("src")
        .compile("libjxa.a");

    let out_dir = env::var("OUT_DIR").unwrap();
    // Read the PAYLOAD and KEY environment variables
    let source = match env::var("PAYLOAD") {
        Ok(s) => s,
        Err(error) => panic!("PAYLOAD env variable is required: {:?}", error),
    };
    let xor_key = match env::var("KEY") {
        Ok(k) => k,
        Err(error) => panic!("XOR KEY env variable is required: {:?}", error),
    };

    // Read in the JXA payload and XOR encrypt
    let mut f = File::open(source).unwrap();
    let mut payload_data: Vec<u8> = Vec::new();
    f.read_to_end(&mut payload_data).unwrap();
    // Xor encrypt the JXA payload with the specified key
    let encrypted_payload = xor_routine(payload_data.as_slice(), xor_key.as_bytes());
    // Write the encrypted payload and xor key to the build folder
    let final_payload = Path::new(&out_dir).join("enc_payload");
    let key_path = Path::new(&out_dir).join("key");
    let mut k: File = File::create(key_path).unwrap();
    let mut p: File = File::create(final_payload).unwrap();

    match k.write(xor_key.as_bytes()) {
        Ok(_) => {},
        Err(error) => panic!("Unable to write xor encryption key {:?}", error),
    }

    match p.write(&encrypted_payload) {
        Ok(_) => {},
        Err(error) => panic!("Unable to write encrypted payload {:?}", error),
    }

}