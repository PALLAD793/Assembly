.data
notImportant: 	.space 4
pixelArraySize:	.space 4
offset:		.space 4
arrayWidth:	.space 4
arrayHeight: 	.space 4
allocMemAddr:	.space 4

bitmapIn:	.asciiz "BitmapIn.bmp"
bitmapOut:	.asciiz "BitmapOut.bmp"
title:		.asciiz "Krzywa Beziera"
errBitmapLoad:  .asciiz "\nNieudane otwarcie bitmapy"
load_x0:	.asciiz "\nPodaj x0\n"
load_y0:	.asciiz "\nPodaj y0\n"
load_x1:	.asciiz "\nPodaj x1\n"
load_y1:	.asciiz "\nPodaj y1\n"
load_x2:	.asciiz "\nPodaj x2\n"
load_y2:	.asciiz "\nPodaj y2\n"

deltaT:
.word 0x000001

.text
.globl main

main:		
		#tytu� projektu
		la $a0, title
		li $v0, 4
		syscall
		
openBitmap:
		#otwarcie bitmapy
		li $v0, 13
		la $a0, bitmapIn
		li $a1, 0
		li $a2, 0
		syscall
		
		#zapisuj� deskryptor pliku do $t0
		move $t0, $v0
		
		bltz $t0, errorBitmap
	
		#zczytanie BM z bitmapy
		li $v0, 14
		move $a0, $t0
		la $a1, notImportant
		li $a2, 2
		syscall
		
		#wczytanie rozmiaru bitmapy
		li $v0, 14
		move $a0, $t0
		la $a1, pixelArraySize
		li $a2, 4
		syscall
		
		#zczytanie zarezerwowanych bajt�w
		li $v0, 14
		move $a0, $t0
		la $a1, notImportant
		li $a2, 4
		syscall
		
		#wczytanie offset'u
		li $v0, 14
		move $a0, $t0
		la $a1, offset
		li $a2, 4
		syscall
		
		#zczytanie DIB header
		li $v0, 14
		move $a0, $t0
		la $a1, notImportant
		li $a2, 4
		syscall
		
		#wczytanie szeroko�ci tablicy pikseli
		li $v0, 14
		move $a0, $t0
		la $a1, arrayWidth
		li $a2, 4
		syscall
		
		#wczytanie wysoko�ci tablicy pikseli
		li $v0, 14
		move $a0, $t0
		la $a1, arrayHeight
		li $a2, 4
		syscall
		
		li $v0, 16
		move $a0, $t0
		syscall
		
allocMemory:
		#zaalokowanie pami�ci, do kt�rej wczytam tablic� pikseli
		lw $s0, pixelArraySize
		move $a0, $s0
		li $v0, 9
		syscall
		
		move $s1, $v0
		sw $s1, allocMemAddr  #w s1 trzymam adres zaalokowanej pami�ci
		
loadPixelArray:
		#otwarcie bitmapy
		li $v0, 13
		la $a0, bitmapIn
		li $a1, 0
		li $a2, 0
		syscall
		
		move $t0, $v0
		
		li $v0, 14
		move $a0, $t0
		la $a1, ($s1)
		la $a2, ($s0)
		syscall
		
		li $v0, 16
		move $a0, $t0
		syscall
		
countPadding:
		#sprawdzam czy jest padding i ile bajt�w
		
		#maska do wyliczenia warto�ci %4
		li $t2, 3

		#mamy bitmap� 3 bajty na piksel, wi�c �eby obliczy� szeroko�� w bajtach mno�ymy przez 3
		lw $s2, arrayWidth  
		lw $s3, arrayHeight #wysoko�� w pikselach
		li $s4, 3
		multu $s2, $s4   #w s2 mam szeroko�� w bajtach
		mflo $s2
		and $s4, $s2, $t2 
		beqz $s4, loadCoordinates
		li $s5, 4
		subu $s4, $s5, $s4 #w s4 mam padding
		
loadCoordinates:
		#za�adowanie koordynat�w do wcze�niej zadeklarowanych p�s��w (t4, t5), (t6, t7), (t8, t9) i przesuni�cie
		#�eby by�y reprezentowane jako 16 bit�w cz�ci ca�kowitej i 16 bit�w cz�ci u�amkowej
		li $v0, 4
		la $a0, load_x0
		syscall
		li $v0, 5
		syscall
		addu $t4, $v0, 0
		
		sll $t4, $t4, 16
		
		li $v0, 4
		la $a0, load_y0
		syscall
		li $v0, 5
		syscall
		addu $t5, $v0, 0
		
		sll $t5, $t5, 16
		
		li $v0, 4
		la $a0, load_x1
		syscall
		li $v0, 5
		syscall
		addu $t6, $v0, 0
		
		sll $t6, $t6, 16
		
		li $v0, 4
		la $a0, load_y1
		syscall
		li $v0, 5
		syscall
		addu $t7, $v0, 0
		
		sll $t7, $t7, 16
		
		li $v0, 4
		la $a0, load_x2
		syscall
		li $v0, 5
		syscall
		addu $t8, $v0, 0
		
		sll $t8, $t8, 16
		
		li $v0, 4
		la $a0, load_y2
		syscall
		li $v0, 5
		syscall
		addu $t9, $v0, 0
		
		sll $t9, $t9, 16
prepareData:
		# t4 - t9 wsp�rz�dne punkt�w
		# s1 - wskazanie na zaalokowan� pami��
		# s2 - szeroko�� w bajtach
		# s3 - wysoko�� w pikselach
		# s4 - padding
		addu $s0, $s2, $s4  # w s0 szeroko��+padding
		sll $s0, $s0, 16
		li $t0, 1 # warto�� 1 od kt�rej b�d� odejmowa�
		sll $t0, $t0, 16
		lw $t1, deltaT # warto�� deltaT
		li $t2, 0  # aktualny czas

drawPoints:
		# szukamy naszego piksela y * (szeroko�� w bajtach + padding) + x * 3
		# (x0, y0)
		multu $t5, $s0
		mfhi $s6
		
		
		li $s7, 3
		sll $s7, $s7, 16
		multu $t4, $s7
		mfhi $s7

		addu $s6, $s6, $s7

		lw $s1, allocMemAddr
		lw $s5, offset
		addu $s1, $s1, $s5
		addu $s1, $s1, $s6
		
		li $s6, 0
		sb $s6, ($s1)
		addiu $s1, $s1, 1
		sb $s6, ($s1)
		addiu $s1, $s1, 1
		sb $s6, ($s1)

		# (x1, y1)
		multu $t7, $s0
		mfhi $s6
		
		
		li $s7, 3
		sll $s7, $s7, 16
		multu $t6, $s7
		mfhi $s7

		addu $s6, $s6, $s7

		lw $s1, allocMemAddr
		lw $s5, offset
		addu $s1, $s1, $s5
		addu $s1, $s1, $s6
		
		li $s6, 0
		sb $s6, ($s1)
		addiu $s1, $s1, 1
		sb $s6, ($s1)
		addiu $s1, $s1, 1
		sb $s6, ($s1)
		
		# (x2, y2)
		multu $t9, $s0
		mfhi $s6
		
		
		li $s7, 3
		sll $s7, $s7, 16
		multu $t8, $s7
		mfhi $s7

		addu $s6, $s6, $s7

		lw $s1, allocMemAddr
		lw $s5, offset
		addu $s1, $s1, $s5
		addu $s1, $s1, $s6
		
		li $s6, 0
		sb $s6, ($s1)
		addiu $s1, $s1, 1
		sb $s6, ($s1)
		addiu $s1, $s1, 1
		sb $s6, ($s1)

		
calculateCoefficients:
		# wz�r (1-t)^2  * P0 + 2(1-t)t * P1 + t^2 * P2  t<0,1>
		# w rejestrze s5 warto�� 1-t
		# w rejestrze s6 warto�� (1-t)^2
		# w rejestrze s7 waro�� 2(1-t)t
		# w rejestrze t3 warto�� t^2
		sub $s5, $t0, $t2
		
		multu $s5, $s5
		mfhi $s6
		sll $s6, $s6, 16
		mflo $a3
		srl $a3, $a3, 16
		or $s6, $s6, $a3
		
		sll $s7, $s5, 1
		multu $s7, $t2
		mfhi $s7
		sll $s7, $s7, 16
		mflo $a3
		srl $a3, $a3, 16
		or $s7, $s7, $a3
		
		multu $t2, $t2
		mfhi $t3
		sll $t3, $t3, 16
		mflo $a3
		srl $a3, $a3, 16
		or $t3, $t3, $a3
		
calculateCoordinates:
		# w a0 wynik (1-t)^2 * x0
		multu $s6, $t4
		mfhi $a0
		sll $a0, $a0, 16
		mflo $a3
		srl $a3, $a3, 16
		or $a0, $a0, $a3
		
		# w a1 wynik 2(1-t)t * x1
		multu $s7, $t6
		mfhi $a1
		sll $a1, $a1, 16
		mflo $a3
		srl $a3, $a3, 16
		or $a1, $a1, $a3
		
		# dodajemy do a0 a1, �eby zyska� rejestr, w a0 s� dwie z trzech cz�ci wzoru
		addu $a0, $a0, $a1
		
		# w a1 wynik t^2 * x2
		multu $t3, $t8
		mfhi $a1
		sll $a1, $a1, 16
		mflo $a3
		srl $a3, $a3, 16
		or $a1, $a1, $a3
		
		# dodajemy do a0 a1 i teraz w a0 mamy wsp�rz�dn� x krzywej
		addu $a0, $a0, $a1
		
		# w a1 wynik (1-t)^2 * y0
		multu $s6, $t5
		mfhi $a1
		sll $a1, $a1, 16
		mflo $a3
		srl $a3, $a3, 16
		or $a1, $a1, $a3
		
		# w a1 wynik 2(1-t)t * y1
		multu $s7, $t7
		mfhi $a2
		sll $a2, $a2, 16
		mflo $a3
		srl $a3, $a3, 16
		or $a2, $a2, $a3
		
		# dodajemy do a1 a2, �eby zyska� rejestr, w a1 s� dwie z trzech cz�ci wzoru
		addu $a1, $a1, $a2
		
		# w a2 wynik t^2 * x2
		multu $t3, $t9
		mfhi $a2 
		sll $a2, $a2, 16
		mflo $a3
		srl $a3, $a3, 16
		or $a2, $a2, $a3
		
		# dodajemy do a1 a2 i teraz w a1 mamy wsp�rz�dn� y krzywej
		addu $a1, $a1, $a2
		
		# interesuje nas tylko cz�� ca�owita wi�c ucinamy cz�� u�amkow�
		# mamy teraz x i y na 16 bitach
		srl $a0, $a0, 16
		srl $a1, $a1, 16
		sll $a0, $a0, 16
		sll $a1, $a1, 16
		
		# szukamy naszego piksela y * (szeroko�� w bajtach + padding) + x * 3
		multu $a1, $s0
		mfhi $s6		
		
		li $s7, 3
		sll $s7, $s7, 16
		multu $a0, $s7
		mfhi $s7
		
		addu $s6, $s6, $s7
		
		lw $s1, allocMemAddr
		lw $s5, offset
		addu $s1, $s1, $s5
		addu $s1, $s1, $s6
		
		li $s6, 0
		sb $s6, ($s1)
		addiu $s1, $s1, 1
		sb $s6, ($s1)
		addiu $s1, $s1, 1
		sb $s6, ($s1)
		
		add $t2, $t2, $t1
		ble $t2, $t0, calculateCoefficients
		

saveBitmap:
		li $v0, 13
		la $a0, bitmapOut
		li $a1, 1
		li $a2, 0
		syscall
		
		move $t0, $v0
		
		bltz $t0, errorBitmap
		
		lw $s0, pixelArraySize
		lw $s1, allocMemAddr
		
		li $v0, 15
		move $a0, $t0
		la $a1, ($s1)
		la $a2, ($s0)
		syscall
		
		li $v0, 16
		move $a0, $t0
		syscall
		
end:
		li $v0, 10
		syscall

errorBitmap:
		la $a0, errBitmapLoad
		li $v0, 4
		syscall
