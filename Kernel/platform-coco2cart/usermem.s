	.module usermem

;
;	6809 + Cartridge copy to and from userspace
;	Assumes the irq handler saves/restores cartridge/ram correctly
;	Assumes we never copy to/from ROM space
;

	include "kernel.def"
        include "../kernel09.def"

	; exported
	.globl __ugetc
	.globl __ugetw
	.globl __uget
	.globl __ugets
	.globl __uputc
	.globl __uputw
	.globl __uput
	.globl __uzero

	.area .common

__ugetc:
	jsr map_process_always
	ldb ,x
	clra
	tfr d,x
	jmp map_kernel

__ugetw:
	jsr map_process_always
	ldx ,x
	jmp map_kernel

__uget:
	pshs u,y
	ldu 6,s		; user address
	ldy 8,s		; count
	jsr map_process_always
ugetl:
	lda ,x+
	sta ,u+
	leay -1,y
	bne ugetl
	ldx #0
	jsr map_kernel
	puls u,y,pc

__ugets:
	pshs u,y
	ldu 6,s		; user address
	ldy 8,s		; count
	jsr map_process_always
ugetsl:
	lda ,x+
	beq ugetse
	sta ,u+
	leay -1,y
	bne ugetsl
	jsr map_kernel
	ldx #0xffff	; unterminated - error
	lda #0
	sta -1,u	; force termination
	puls u,y,pc
ugetse:
	sta ,u
	ldx #0
	jsr map_kernel
	puls u,y,pc


__uputc:
	ldd 2,s
	jsr map_process_always
	exg d,x
	stb ,x
	ldx #0
	jmp map_kernel

__uputw:
	ldd 2,s
	jsr map_process_always
	exg d,x
	std ,x
	ldx #0
	jmp map_kernel

;	X = source, user, size on stack
__uput:
	pshs u,y
	ldu 6,s		; user address
	ldy 8,s		; count
	jsr map_process_always
uputl:
	lda ,x+
	sta ,u+
	leay -1,y
	bne uputl
	ldx #0
	jsr map_kernel
	puls u,y,pc

__uzero:
	pshs y
	lda #0
	ldy 4,s
	jsr map_process_always
uzloop:
	sta ,x+
	leay -1,y
	bne uzloop
	jsr map_kernel
	ldx #0
	puls y,pc
