section .data
   userMsg db "Please enter a password: ", 0xa           ; Ask the user to enter a password
   lenUserMsg equ $-userMsg                              ; the userMsg Length
   pass db "password", 0                                 ; password
   lenPass equ $-pass                                    ; password Length 
   okMsg db "Access Granted", 0xa                        ; success message
   lenOkMsg equ $-okMsg + 1                              ; Include the newline character
   errMsg db "Incorrect password", 0xa                   ; Error  message
   lenErrMsg equ $-errMsg + 1                            ; Include the newline character

section .bss
   buffer resb 16                            ; resb 16 reservse 16 bytes of uninitialized space for the buffer which will be used to store user input

section .text
   global _start                             ; telling the linker this is the start point

_start:
                                             ; User prompt
   mov eax, 4                                ; this is system call telling the kernal to write.(sys_write), eax is used to hold the syscall number
   mov ebx, 1                                ; the file discriptor (stdout)
   mov ecx, userMsg                          ; the buffer that will be written  to stdin
   mov edx, lenUserMsg                       ; the buffer length
   int 0x80                                  ; syscall

                                             ; Read and store the user input
   mov eax, 3                                ; this is the system call telling the kernal to read.(sys_read) eax is used to hold the syscall number
   mov ebx, 0                                ; this is the file discriptor(stdin);
   lea ecx, [buffer]                         ; loading the address to the buffer where we are goign to write.
   mov edx, 16                               ; the buffer length;
   int 0x80                                  ; syscall

                                             ; Check the password
   mov esi, pass                             ; moving the pass variable to the source index register
   mov edi, buffer                           ; moving the user entered buffer to the destination index register
   mov ecx, 16                               ; the buffer length of the user data 

compare_loop:                                ; loop to compare two strings
   cmp byte [esi], 0                         ; this condition checks for the end of the null-terminated string
   je strings_equal                          ; we reached to the end of the string and ERR_MSGFunction wasn't triggered, that means Success.
   cmpsb                                     ; cmpare the values at esi,edi, this compares one byte at a time.
   jne ERR_MSG                               ; jump not equal to this functionto print err msg
   jmp compare_loop                          ; call the loop function again

strings_equal:
                                             ; Success message
   mov eax, 4                                ; system call for write (sys_write) to the kernal eax is used to hold the syscall number
   mov ebx, 1                                ; file descriptor (stdout)
   mov ecx, okMsg                            ; the success message
   mov edx, lenOkMsg                         ; length on success message
   int 0x80                                  ; syscall 
   jmp _exit                                 ; jump to the exit function

ERR_MSG:
                                             ; Error message
   mov eax, 4                                ; system call for write (sys_write) to the kernal eax is used to hold the syscall number
   mov ebx, 1                                ; file descriptor (stdout)
   mov ecx, errMsg                           ; the error message
   mov edx, lenErrMsg                        ; length of the error message
   int 0x80                                  ; syscall

_exit:
                                             ; Exit code
   mov eax, 1                                ; system call for exit(sys_exit) eax is used to hold the syscall number
   mov ebx, 0                                ; file descriptor
   int 0x80                                  ; syscall invokes the kernal
