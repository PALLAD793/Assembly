;spis

;rdi - wskaznik na wskaznik na pierwszy piksel
;rsi - szerokosc okna
;rdx - wysokosc okna

;xmm0 - x0
;xmm1 - y0
;xmm2 - x1
;xmm3 - y1
;xmm4 - x2
;xmm5 - y2
;xmm6 - x3
;xmm7 - y3
;xmm8 - x4
;xmm9 - y4
;xmm10 - t
;xmm11 - (1-t)
;xmm13 - deltaT



section .text
	global BezierCurve

default rel
section .data
	_1: dq 1.0
	_4: dq 4.0
	_6: dq 6.0

BezierCurve:
	push rbp
	mov rbp, rsp
	
	mov r11, [rbp+72]

	movsd xmm13, xmm0

	xorpd xmm10, xmm10

drawPoints:
	; draw P0
	cvtsi2sd xmm0, rcx
	cvtsi2sd xmm1, r8
	cvtsi2sd xmm2, rsi
	mulsd xmm1, xmm2
	cvtsd2si rax, xmm1
	mov r13, [rdi]
	add r13, rax
	cvtsd2si r14, xmm0
	add r13, r14
	mov [r13], r11b

	; draw P1
	cvtsi2sd xmm2, r9
	cvtsi2sd xmm3, [rbp+16]
	cvtsi2sd xmm4, rsi
	mulsd xmm3, xmm4
	cvtsd2si rax, xmm3
	mov r13, [rdi]
	add r13, rax
	cvtsd2si r14, xmm2
	add r13, r14
	mov [r13], r11b

	; draw P2
	cvtsi2sd xmm4, [rbp+24]
	cvtsi2sd xmm5, [rbp+32]
	cvtsi2sd xmm6, rsi
	mulsd xmm5, xmm6
	cvtsd2si rax, xmm5
	mov r13, [rdi]
	add r13, rax
	cvtsd2si r14, xmm4
	add r13, r14
	mov [r13], r11b

	; draw P3
	cvtsi2sd xmm6, [rbp+40]
	cvtsi2sd xmm7, [rbp+48]
	cvtsi2sd xmm8, rsi
	mulsd xmm7, xmm8
	cvtsd2si rax, xmm7
	mov r13, [rdi]
	add r13, rax
	cvtsd2si r14, xmm6
	add r13, r14
	mov [r13], r11b

	; draw P4
	cvtsi2sd xmm8, [rbp+56]
	cvtsi2sd xmm9, [rbp+64]
	cvtsi2sd xmm0, rsi
	mulsd xmm9, xmm0
	cvtsd2si rax, xmm9
	mov r13, [rdi]
	add r13, rax
	cvtsd2si r14, xmm8
	add r13, r14
	mov [r13], r11b

whileTime:
	; 1-t
	movsd xmm11, [_1]
	subsd xmm11, xmm10

	; x0 * (1-t)^4
	cvtsi2sd xmm0, rcx
	mulsd xmm0, xmm11
	mulsd xmm0, xmm11
	mulsd xmm0, xmm11
	mulsd xmm0, xmm11

	; y0 * (1-t)^4
	cvtsi2sd xmm1, r8
	mulsd xmm1, xmm11
	mulsd xmm1, xmm11
	mulsd xmm1, xmm11
	mulsd xmm1, xmm11
	
	; x1 * 4 * (1-t)^3 * t
	cvtsi2sd xmm2, r9
	mulsd xmm2, [_4]
	mulsd xmm2, xmm11
	mulsd xmm2, xmm11
	mulsd xmm2, xmm11
	mulsd xmm2, xmm10
	
	; y1 * 4 * (1-t)^3 * t
	cvtsi2sd xmm3, [rbp+16]
	mulsd xmm3, [_4]
	mulsd xmm3, xmm11
	mulsd xmm3, xmm11
	mulsd xmm3, xmm11
	mulsd xmm3, xmm10

	; x2 * 6 * (1-t)^2 * t^2
	cvtsi2sd xmm4, [rbp+24]
	mulsd xmm4, [_6]
	mulsd xmm4, xmm11
	mulsd xmm4, xmm11
	mulsd xmm4, xmm10
	mulsd xmm4, xmm10

	; y2 * 6 * (1-t)^2 * t^2
	cvtsi2sd xmm5, [rbp+32]
	mulsd xmm5, [_6]
	mulsd xmm5, xmm11
	mulsd xmm5, xmm11
	mulsd xmm5, xmm10
	mulsd xmm5, xmm10

	; x3 * 4 * (1-t) * t^3
	cvtsi2sd xmm6, [rbp+40]
	mulsd xmm6, [_4]
	mulsd xmm6, xmm11
	mulsd xmm6, xmm10
	mulsd xmm6, xmm10
	mulsd xmm6, xmm10

	; y3 * 4 * (1-t) * t^3
	cvtsi2sd xmm7, [rbp+48]
	mulsd xmm7, [_4]
	mulsd xmm7, xmm11
	mulsd xmm7, xmm10
	mulsd xmm7, xmm10
	mulsd xmm7, xmm10

	; x4 * t^4
	cvtsi2sd xmm8, [rbp+56]
	mulsd xmm8, xmm10
	mulsd xmm8, xmm10
	mulsd xmm8, xmm10
	mulsd xmm8, xmm10

	; y4 * t^4
	cvtsi2sd xmm9, [rbp+64]
	mulsd xmm9, xmm10
	mulsd xmm9, xmm10
	mulsd xmm9, xmm10
	mulsd xmm9, xmm10

	; xmm0 = x0 + x1 + x2 + x3 + x4
	addsd xmm0, xmm2
	addsd xmm0, xmm4
	addsd xmm0, xmm6
	addsd xmm0, xmm8

	; xmm1 = y0 + y1 + y2 + y3 + y4
	addsd xmm1, xmm3
	addsd xmm1, xmm5
	addsd xmm1, xmm7
	addsd xmm1, xmm9

	cvtsd2si r12, xmm1
	mov rax, rsi
	mul r12

	mov r13, [rdi]
	add r13, rax


	cvtsd2si r12, xmm0
	
	
	add r13, r12


	; r13 = bitmapBegin + y * width + x
	inc r13
	mov [r13], r11b


	; t
	addsd xmm10, xmm13

	comisd xmm10, [_1]
	jna whileTime

exit:
	mov rsp, rbp
	pop rbp
	ret	

















