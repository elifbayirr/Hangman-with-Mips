
.macro getline(%wordPos, %dstStr, %delim, %path)
.data
	buff: .space 1
.text
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($t4)
	pushStack($s7)
	pushStack($a0)	
	pushStack($a1)	
	pushStack($a2)
	
        move $t4, %dstStr
        # dstStr substring'imi depoluyorum 
       	move $t1, %wordPos 	# kelimenin konumu ( wordbox'ın icindeki kelimenin pos'u)
        	
	# dosyayi aciyoruz
	li $v0, 13
	la $a0, %path
	li $a1, 0
	li $a2, 0
	syscall
	move $s7, $v0		# dosya tanimlayicisini kaydediyoruz
		
	li $t2, 0	# random int olup olmadigini kontrol ediyoruz

	FindWord:
		# dosyayi okuyoruz
		li $v0, 14
		move $a0, $s7
		la $a1, buff
		la $a2, 1
		syscall
	
		lb $t3, buff
	
		beqz $v0, Error	# kelimeyi bulamadik
		beqz $t1, getWord	# ilk kelime
		beq $t3, %delim, count	# karakteri okurken eger bir delim'le karsilasirsak t2'ye kadar sayacagiz( delim= string'in sonu)
		beq $t1, $t2, getWord	# eger kelimeyi bulursa, getWord'de git

		j FindWord
	
	count:
		addi $t2, $t2, 1
		j FindWord
		
	getWord:
		lb $t3, buff
		sb $t3, ($t4)
		
		addi $t4, $t4, 1
	Loop:
		li $v0, 14
		move $a0, $s7
		la $a1, buff
		la $a2, 1
		syscall
	
		lb $t3, buff
		
		beq $t3, %delim, getWordExit
		beqz $v0, getWordExit

		sb $t3, ($t4)
		
		addi $t4, $t4, 1
		j Loop
		
	getWordExit:
		li $t3, 0x00
		sb $t3, ($t4)
		li $t0, 0
		j end
		
	Error:
		li $t0, -1
		li $t3, 0x00
		sb $t3, ($t4)
	
	end:
	# dosya kapandi 
	li   $v0, 16       # sistem cagrisi ile dosyamizi kapatiyoruz
	move $a0, $s7      # dosya tanimlayicisinida kaptiyoruz
	syscall            # dosya kapali
	move $v0, $t0
	
	popStack($a2)	
	popStack($a1)	
	popStack($a0)
	popStack($s7)		
	popStack($t4)
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro


# karakteri dosyamiza kaydediyoruz 
# flag;0 ise trunc flag;1 ise app

.macro saveChar(%char, %flag, %path)
.data
	storeSaveChar: .byte
.text
	pushStack($s7)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)	
	pushStack($t4)
	pushStack($a0)	
	pushStack($a1)	
	pushStack($a2)	
	
	li $t0, 1
	
	la $t1, %flag
	
	add $t3, $zero, %char
	la $t4, storeSaveChar
	sb $t3, ($t4)
	
	beqz $t1, trunc
	beq $t1, $t0, app
	
	trunc:
		# dosya ac
		li $v0, 13
		la $a0, %path
		li $a1, 1
		li $a2, 0
		syscall
		move $s7, $v0 # dosya tanimlayicisini kaydediyoruz
		
		# dosya yaz
		li $v0, 15
		move $a0, $s7
		move $a1, $t4
		li $a2, 1
		syscall
		
		j exit
	
	app:
		# dosya aciyoruz
		li $v0, 13
		la $a0, %path
		li $a1, 9
		li $a2, 0
		syscall
		move $s7, $v0 # dosya tanimlayicisini kaydediyoruz
		
		# dosyayı ekliyoruz
		li $v0, 15
		move $a0, $s7
		move $a1, $t4
		li $a2, 1
		syscall
	exit:

	# dosyayi kapatiyoruz
	li   $v0, 16       # sistem cagrisi ile dosyamizi kapatiyoruz
	move $a0, $s7      # dosya tanimlayicisinida kaptiyoruz
	syscall            # dosya kapali
	
	popStack($a2)	
	popStack($a1)	
	popStack($a0)	
	popStack($t4)	
	popStack($t3)
	popStack($t2)	
	popStack($t1)
	popStack($t0)
	popStack($s7)

.end_macro

# string'imi dosyama kaydeiyorum
# flag;0 ise trunc dur flag;1 ise app dir
.macro saveString(%string, %flag, %path)
.data 
	storeSaveChar: .byte
.text
	pushStack($s7)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($t4)
	pushStack($t5)	
	pushStack($a0)	
	pushStack($a1)	
	pushStack($a2)	
	
	li $t0, 1
	
	la $t1, %flag
	
	li $t2, 0x00
	add $t3, $zero, %string
	
	beqz $t1, trunc
	beq $t1, $t0, app
	
	trunc:
		la $t4, storeSaveChar	
		
		# dosyayi aciyoruz
		li $v0, 13
		la $a0, %path
		li $a1, 1
		li $a2, 0
		syscall
		move $s7, $v0 # dosya tanimlayicisini kaydediyoruz
		
		loopTrunc:
			# dosyaya yaziyoruz
			lb $t5, ($t3)
			sb $t5, ($t4)
			beq $t5, $t2, loopTruncExit
			
			li $v0, 15
			move $a0, $s7
			move $a1, $t4
			li $a2, 1
			syscall	
			
			addi $t3, $t3, 1
			j loopTrunc
		loopTruncExit:
		
		j exit
	app:
		loopApp:
			lb $t4, ($t3)
			beq $t4, $t2, loopAppExit
			saveChar($t4, 1, %path)
			add $t3, $t3, 1
			j loopApp
		loopAppExit:
	exit:

	# dosyayi kapatiyoruz
	li   $v0, 16       # sistem cagrisi ile dosyamizi kapatiyoruz
	move $a0, $s7      # dosya tanimlayicisinida kaptiyoruz
	syscall            # dosya kapandi
	
	popStack($a2)	
	popStack($a1)	
	popStack($a0)	
	popStack($t5)	
	popStack($t4)	
	popStack($t3)
	popStack($t2)	
	popStack($t1)
	popStack($t0)
	popStack($s7)
.end_macro