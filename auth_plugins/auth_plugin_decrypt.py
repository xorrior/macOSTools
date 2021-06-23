import base64

def decrypt(var, key):
    return bytes(a ^ b for a, b in zip(var, key))

base64_message = '<INSERT_B64_HERE>'
base64_message_bytes = base64_message.encode('utf-8')
message_bytes = base64.decodebytes(base64_message_bytes)
print(decrypt(message_bytes,b"ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD"))