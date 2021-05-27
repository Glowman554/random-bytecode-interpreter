[section .data]

%include "code.asm"

buffer: dq 0

[section .text]
[global _start]

; eax = instruction pointer
; ebx = work register
; stack = call stack

_start:
	mov eax, 0
	mov ebx, 0

.read_loop:
	xor ecx, ecx
	mov cl, [code + eax]

	cmp cl, max_instruction
	ja .skip

	lea edx, [instruction_table + ecx * 8]
	jmp [edx]

	jmp .read_loop

.skip:
	inc eax
	jmp .read_loop

.load_arg_to_edx:
	xor edx, edx
	mov dh, [code + eax]
	inc eax
	mov dl, [code + eax]
	inc eax
	ret

nop_i:
	inc eax
	jmp _start.read_loop

load_i:
	inc eax
	call _start.load_arg_to_edx
	mov bl, byte [code + edx]
	jmp _start.read_loop

store_i:
	inc eax
	call _start.load_arg_to_edx
	mov byte [code + edx], bl
	jmp _start.read_loop

call_i:
	inc eax
	call _start.load_arg_to_edx
	push eax
	mov eax, edx
	jmp _start.read_loop

return_i:
	pop eax
	jmp _start.read_loop

out_i:
	inc eax
	mov [buffer], ebx
	mov edi, eax
	mov esi, ebx
	mov edx, 1
	mov ecx, buffer
	mov ebx, 1
	mov eax, 4
	int 0x80
	mov eax, edi
	mov ebx, esi
	jmp _start.read_loop

exit_i:
	mov ebx, 0
	mov eax, 1
	int 0x80

mov_i:
	inc eax
	call _start.load_arg_to_edx
	mov bl, dl
	jmp _start.read_loop

add_i:
	inc eax
	call _start.load_arg_to_edx
	add bl, dl
	jmp _start.read_loop

compare_i:
	inc eax
	call _start.load_arg_to_edx
	cmp bl, dl
	je .pass
	jne .fail

.fail:
	add eax, 2
	jmp _start.read_loop

.pass:
	call _start.load_arg_to_edx
	mov eax, edx
	jmp _start.read_loop


sub_i:
	inc eax
	call _start.load_arg_to_edx
	sub bl, dl
	jmp _start.read_loop

jump_i:
	inc eax
	call _start.load_arg_to_edx
	mov eax, edx
	jmp _start.read_loop

compare_reverse_i:
	inc eax
	call _start.load_arg_to_edx
	cmp bl, dl
	jne .pass
	je .fail

.fail:
	add eax, 2
	jmp _start.read_loop

.pass:
	call _start.load_arg_to_edx
	mov eax, edx
	jmp _start.read_loop

instruction_table:
	dq nop_i
	dq load_i
	dq store_i
	dq call_i
	dq return_i
	dq out_i
	dq exit_i
	dq mov_i
	dq add_i
	dq compare_i
	dq sub_i
	dq jump_i
	dq compare_reverse_i
instruction_table_end:

max_instruction equ ((instruction_table_end - instruction_table) / 8) -1