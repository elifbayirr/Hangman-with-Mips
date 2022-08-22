# burada content register'i stack'a push'luyoruz
.macro pushStack(%regIn)
	addi	$sp, $sp, -4
	sw	%regIn, ($sp)
.end_macro

# kayit olmak icin 
.macro popStack(%regOut)
	lw	%regOut, ($sp)
	addi	$sp, $sp, 4
.end_macro

# iki register'i (a ve b) degistiriyoruz
.macro swap(%a, %b)
	pushStack($t0)
	move	$t0, %a
	move 	%a, %b
	move	%b, $t0
	popStack($t0)
.end_macro

# integer'i strging'e ceviriyoruz
.macro toString(%regStr, %int)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	# init
	add	$t0, $zero, %int
	move 	$s0, %regStr
	li	$t1, 10
	abs	$t0, $t0
	
	LoopIntToString:
		# div 10
		div 	$t0, $t1
			
		# bolum
		mflo	$t0
			
		# kalan
		mfhi	$t2
		
		# kaydediyoruz
		addi	$t2, $t2, 48
		sb	$t2, ($s0)
			
		# inc address
		addi	$s0, $s0, 1
		
		# t0= null ise LoopIntToString don
		bne	$t0, $zero, LoopIntToString
			
	# negatifleri kontrol ediyoruz
	add	$t0, $zero, %int
	blt 	$t0, $zero, AddMinusAfterString
	sb	$zero, ($s0) # null ekliyoruz
	j 	EndCheckNegative
	
	AddMinusAfterString:
		li	$t0, '-'
		sb	$t0, ($s0)
		addi	$s0, $s0, 1
	
	EndCheckNegative:
		
	# ters
	strReverse(%regStr)
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# regStr kayit dizimizin adresini icerir
.macro length(%regStr)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	
	# Init
	li	$t0, -1
	move	$s0, %regStr
	lb	$t1, ($s0)
	
	# kontrol ediyoruz  length=0
	li	$v0, 0	
	beq	$t1, 0, EndStrlen
	
	LoopStrlen:
		addi	$t0, $t0, 1
		lb 	$t1, ($s0)
		addi	$s0, $s0, 1
		
		bne	$t1, $zero, LoopStrlen
	move	$v0, $t0
	
	EndStrlen:
	
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro

# str tum alfa numaralarini kontrol ediyoruz
.macro num(%regStr)
	pushStack($t0)
	pushStack($s0)
	
	# loop sayisini hesapliyoruz
	li	$t0, 0
	move	$s0, %regStr
	
	LoopCheckAlnum:
		# break
		lb	$t0, ($s0)
		
		# sifirdan kucuk olmasini kontrol ediyoryz
		blt	$t0, 48, alnumFalse
		
		# kontrol ediyoruz > '9' & < 'A' ( alfa numberic kurali )
		bgt	$t0, 57, CheckSmallerA
		j CheckNext1
		CheckSmallerA:
			blt	$t0, 65, alnumFalse
		
		CheckNext1:
		# kontrol ediyoruz > 'Z' & < 'a'	
		bgt	$t0, 90, CheckSmallera
		j CheckNext2
		CheckSmallera:
			blt	$t0, 97, alnumFalse
			
		# kontrol ediyoruz > 'z'
		CheckNext2:	
		bgt	$t0, 122, alnumFalse
			
		# address
		addi	$s0, $s0, 1
		lb	$t0, ($s0)
		
		# loop
		bne	$t0, $zero, LoopCheckAlnum
	
	alnumTrue:
		li	$v0, 1
		j EndCheckAlnum
	
	alnumFalse:
		li	$v0, 0
		j EndCheckAlnum
		
	EndCheckAlnum:
	
	popStack($s0)
	popStack($t0)
.end_macro

# dizideki tum ogeler esittir char 
.macro string(%regStr, %char, %len)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	add	$t0, $zero, %len
	beq	$t0, $zero, EndInitString
	
	li	$t2, 0
	add	$t1, $zero, %char
	move	$s0, %regStr
	
	LoopInitString:
		#  char'i kaydediyoruz
		sb	$t1, ($s0)
		
		# sayimi bir arttiriyoruz
		addi	$t2, $t2, 1
		
		# address' i bir arttiriyoruz 
		addi	$s0, $s0, 1
		
		# loop
		blt	$t2, $t0, LoopInitString

	sb	$zero, ($s0)
	
	EndInitString:
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# burada string'leri karsilastiriyoruz ( regStr1 birinci string'im regStr2 ikinci string'im)
# v0 = 0 ise esit degil v0=1 ise esittir (return)
.macro compare(%regStr1, %regStr2)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	pushStack($s1)
	
	# ilk
	move	$s0, %regStr1
	move	$s1, %regStr2
	
	# kontrol ediyoruz length
	length($s0)
	move	$t0, $v0
	
	length($s1)
	move	$t1, $v0
	bne 	$t0, $t1, StrNotEqual

	LoopStrCmp:
		# yukluyoruz
		lb	$t0, ($s0)
		lb	$t1, ($s1)
		
		# address
		addi	$s0, $s0, 1
		addi 	$s1, $s1, 1
		
		# break
		bne	$t0, $t1, StrNotEqual
		
		# loop
		bne	$t0, $zero, LoopStrCmp
	
	StrEqual:	
		li	$v0, 1
		j EndStrCmp
		
	StrNotEqual:	
		li	$v0, 0
		j EndStrCmp
		
	EndStrCmp:
	
	popStack($s1)
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro

# dizide gorunen ilk karakteri buluyoruz 
# bunu yaparken input'umuzun konumundan basliyoruz
.macro find(%regStr, %posStart, %char)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	# Init
	add	$t0, $zero, %posStart
	add	$t1, $zero, %char
	move	$s0, %regStr
	add	$s0, $s0, %posStart
	
	addi	$t0, $t0, -1
	lb	$t2, ($s0)
		
	# Check null
	li	$v0, -1
	beq	$t2, $zero, EndStrFind
	LoopStrFind:
		# load char
		lb	$t2, ($s0)
		
		# inc count
		addi	$t0, $t0, 1
		
		# inc address
		addi 	$s0, $s0, 1
		
		# condition break
		beq	$t2, $t1, CharFound
	
		# condition loop
		bne	$t2, $zero, LoopStrFind
	
	beq	$t2, $zero, CharNotFound
	
	CharFound:
		move	$v0, $t0
		j EndStrFind
		
	CharNotFound:
		li	$v0, -1
		j EndStrFind
		
	EndStrFind:
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# posStart'dan posend' e string'i kopyaliyorum 
.macro substr(%dstStr, %srcStr, %posStart, %num)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	pushStack($s1)
	
	# init
	move	$s0, %dstStr
	# dstStr destional string'in adresi 
	move	$s1, %srcStr
	# srcStr kaynak string'in adresi 
	add	$s1, $s1, %posStart
	li	$t0, 0
	
	# loop'umu kopyaliyorum
	LoopSubstr:
		#  char'imi kaydediyorum
		lb	$t1, ($s1)
		sb	$t1, ($s0)
		
		# kaydedilen char'larimin sayisi
		addi	$t0, $t0, 1
		
		# address
		addi	$s0, $s0, 1
		addi	$s1, $s1, 1
		
		# loop
		bne	$t0, %num, LoopSubstr
	
	# sonlandiriyorum
	sb	$zero, ($s0)	
	
	popStack($s1)
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro

# string'lerimi tersine ceviriyorum
.macro strReverse(%regStr)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($s0)
	pushStack($s1)
	
	# baslangic bitis
	move	$s0, %regStr
	move	$s1, %regStr
	
	# string'imin uzunlugu
	length(%regStr)
	move	$t1, $v0
	
	# adresim bitisi
	add	$s1, $s1, $t1
	addi	$s1, $s1, -1
	
	# dongu sayim
	addi 	$t1, $t1, -1
	srl	$t1, $t1, 1

	# dongumu sayiyorum
	li	$t0, -1
	
	LoopStrReverse:
		# yukluyorum
		lb	$t2, ($s0)
		lb	$t3, ($s1)
		
		# swap'liyorum
		swap($t2, $t3)
		
		# kaydediyorrum
		sb	$t2, ($s0)
		sb	$t3, ($s1)
		
		# count
		addi	$t0, $t0, 1
		
		# address 'imi bir azaltiyorum (s1)
		addi	$s0, $s0, 1
		addi 	$s1, $s1, -1
		
		#  loop
		bne	$t0, $t1, LoopStrReverse
		
	popStack($s1)
	popStack($s0)
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# string'den dizi aliyorum
.macro getstr(%dstString, %srcString, %delim, %num)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	pushStack($s1)
	pushStack($s2)
	pushStack($s3)
	
	move	$s0, %dstString
	move	$s1, %srcString
	add	$s2, $zero, %delim
	add	$s3, $zero %num
	
	li	$t0, -1 # bir onceki pos'um
	li	$t1, 0 # anlik Pos
	li	$t2, 0 # sayiyorum
	LoopGetStr:
		addi	$t0, $t0, 1
		find($s1, $t0, $s2)
		move	$t1, $v0
		
		beq	$t1, -1, NotFoundDelim
		beq	$t2, $s3, FoundDelim
		
		move	$t0, $t1
		addi	$t2, $t2, 1
		
		beq	$zero, $zero, LoopGetStr
		
	NotFoundDelim:
		length($s1)
		move	$t1, $v0
		li	$v0, -1
		j 	EndLoopGetStr
		
	FoundDelim:
		li	$v0, 1	
		
	EndLoopGetStr:
		sub	$t2, $t1, $t0
		substr($s0, $s1, $t0, $t2)
	
	popStack($s3)
	popStack($s2)
	popStack($s1)
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# kullaniciye mesaj kutucugumu gosteriyorum
.macro messagebox(%msgIn, %typeMsg)
	pushStack($a0)
	pushStack($a1)
	
	li	$v0, 55
	move	$a0, %msgIn
	add	$a1, $zero, %typeMsg
	syscall
	
	popStack($a1)
	popStack($a0)
.end_macro


# kullaniciden input aliyorum
.macro inputmessagebox(%msgIn, %msgOut, %maxNum)
	pushStack($a0)
	pushStack($a1)
	pushStack($a2)
	
	li	$v0, 54
	move	$a0, %msgIn
	# msgIn gosterilecek mesajin adresi
	move	$a1, %msgOut
	# msgOut adres buffer'im 
	add	$a2, $zero, %maxNum
	# maxNum maksimum okudugum karakter sayisi 
	syscall
	move	$v0, $a1
		
	popStack($a2)
	popStack($a1)
	popStack($a0)
	
	pushStack($s0)
	pushStack($t0)
	
	move	$s0, %msgOut
	LoopCheckNewLine:
		#  break
		lb	$t0, ($s0)
		beq	$t0, 10, EndCheckNewLine
		
		# address'e bir ekliyoruz
		addi	$s0, $s0, 1
		
		bne	$t0, $zero, LoopCheckNewLine
	
	EndCheckNewLine:
		sb	$zero, ($s0)
		
	popStack($t0)	
	popStack($s0)
	
.end_macro

# kullaniciya onay kutumu gosteriyorum
.macro confirmbox(%msgIn)
	pushStack($a0)
	
	li	$v0, 50
	move	$a0, %msgIn
	syscall
	move 	$v0, $a0
	
	popStack($a0)
.end_macro

# str int 'i integere ceviriyorum
.macro int(%intStr)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	move	$s0, %intStr
	li	$t0, 0
	li	$t1, 10
	li	$t2, 0
	
	LoopConvertStrToInt:
		lb	$t0, ($s0)
		beq	$t0, $zero, EndLoopConvertStrToInt
		
		subi	$t0, $t0, 48
		mult	$t2, $t1
		mflo	$t2
		add	$t2, $t2, $t0 
		
		addi	$s0, $s0, 1
		beq	$zero, $zero, LoopConvertStrToInt
	
	EndLoopConvertStrToInt:
	
	move	$v0, $t2
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# char'imi print ediyorum
.macro printChar(%char)
	pushStack($a0)
	
	li	$v0, 11
	add	$a0, $zero, %char
	syscall
	
	popStack($a0)
.end_macro

# string'imi print ediyorum
.macro printString(%string)
	pushStack($a0)
	
	li	$v0, 4
	move	$a0, %string
	syscall
	
	popStack($a0)
.end_macro

# integer'imi print ediyorum
.macro printInt(%int)
	pushStack($a0)
	
	li	$v0, 1
	add	$a0, $zero, %int
	syscall
	
	popStack($a0)
.end_macro

# const string'imi print ediyorum
.macro printConstString(%string)
	.data
		str:	.asciiz		%string
	.text
		pushStack($a0)
	
		li	$v0, 4
		la	$a0, str
		syscall
	
		popStack($a0)
.end_macro


