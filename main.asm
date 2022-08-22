.include "function.asm"
.include "record.asm"
.include "graphics.asm"
.include "choose_word.asm"
	
.text
main:
	# oyunun sizi karsilayacagi kisim
	la	$a0, helloGame
	messagebox($a0, 1)
	
	# oyuncunun ismini giris yaptigi kisim
	InputPlayerName:
		la	$a0, askPlayerName
		la	$a1, playerName
		#ismi a1 de saklï¿½yorum
		inputmessagebox($a0, $a1, 20)
		num($a1)
		beq	$v0, 0, InputPlayerName
	
	# kelimelerimi sayiyorum yaklasik 25 kelimem bulunmakta
	li	$s0, 0
	la	$a0, tempStr
	
	Dictionary:
		
		getline($s0, $a0, ',', wordbox)
		beq	$v0, -1, EndDictionary
		addi	$s0, $s0, 1
		j	Dictionary
		
	EndDictionary:
	sw	$s0, numWordDictionary

Hangman:
	# bosaltiyoruz ekrani
	li	$a0, 0
	li	$a1, 0
	
	LoopYClearScreen:
		LoopXClearScreen:
			drawPixel($a0, $a1, 0x00000000)
			addi	$a0, $a0, 1
			blt	$a0, 128, LoopXClearScreen
			
		li	$a0, 0
		addi	$a1, $a1, 1
		blt	$a1, 128, LoopYClearScreen
	
	# gizli kelimeyi aliyoruz
	la	$a0, hiddenWord
	lw	$a1, numWordDictionary
	
	choose($a1)
	move	$s0, $v0
	getline($s0, $a0, ',', wordbox)
	
	# tahminde bulunuyoruz
	length($a0)
	move	$t0, $v0
	la	$a0, guessWord 
	
	string($a0, 'x', $t0)
			
	LoopGuessOneWord:
		# gÃ¶steriyoruz
		la	$a0, guessWord
		messagebox($a0, 1)
		
		# secim yapiyoruz
		la	$a0, chooseGuessWord
		confirmbox($a0)
		move	$a0, $v0
		#secimine gore yol izliyoruz char(harf) yada word tahmin etmek icin
		beq	$a0, 0, InputGuessOneWord
		beq	$a0, 1, InputGuessOneChar
		
		j	InputGuessOneChar
		
		InputGuessOneWord:
			la	$a0, askInputWord
			la	$a1, guessWord
			inputmessagebox($a0, $a1, 10)
			# kontol ediyoruz doï¿½ru mu degil mi (kelime icin)
		j	_CheckGuessWord
		
		InputGuessOneChar:
			la	$a0, askInputChar
			la	$a1, tempStr
			inputmessagebox($a0, $a1, 5)
			lb	$a0, 0($a1)
			sb	$a0, guessChar
			# kontol ediyoruz doï¿½ru mu degil mi (harf icin)
			#harf kelimemin iï¿½inde geciyorsa yazarak belirtilir
		j	_CheckGuessChar
			
# kelime icin kontol yaptï¿½gimiz kisim		
_CheckGuessWord:
	la	$a0, hiddenWord # gercek kelimem
	la	$a1, guessWord #kullanicinin tahmini
	
	#oncelikle 2 deger dusunuyorum ki esit olup olmadigini degerlendirebileyim 
	# karsilastir ( gizli kelime ve tahmin edilen kelime )
	
	compare($a0, $a1)
	beq	$v0, 1, GuessWordRight 
	j 	GuessWordWrong
	
	#kelimeyi tekde dogru tahmin ettigimizde	
	GuessWordRight:
		
		# noti right word
		la	$a0, notiRightWord
		messagebox($a0, 1)
		
		# sifirliyoruz
		sb	$zero, playerStatus
		
		# score
		lw	$a0, playerScore
		la	$a1, hiddenWord
		length($a1)
		add	$a0, $a0, $v0
		sw	$a0, playerScore
		
		#  sayisi : right word
		lw	$a0, playerWord
		addi	$a0, $a0, 1
		sb	$a0, playerWord
		
		# oyuna devam edip kullanicinin tekrar oynamasini sagliyoruz
		j Hangman
		
	#yanlis kelimeyi takip ettigimizde adamimiz malesef ki direkt olarak asiliyor 		
	GuessWordWrong:
	
		# oyuncuyu kaydediyoruz
		la	$a0, playerName
		saveString($a0, 1, dataPlayer)
		saveChar('-', 1, dataPlayer)
		
		lw	$a0, playerScore
		la	$a1, tempStr
		toString($a1, $a0)
		saveString($a1, 1, dataPlayer)
		saveChar('-', 1, dataPlayer)
		
		lw	$a0, playerWord
		toString($a1, $a0)
		saveString($a1, 1, dataPlayer)
		saveChar('*', 1, dataPlayer)
		
		# status player = 7
		li	$a0, 7
		sb	$a0, playerStatus
		
		# ekranda gosteriyoruz
		j	_Lose
		
#kullanicinin tahmin ettigi harf bizim kelimemizin icinde var mi yok mi diye kontol ettigimiz kisim	
_CheckGuessChar:

	# tam karakterin dolu olup olmadï¿½ï¿½ï¿½nï¿½ kontrol ediyoruz gizli kelimeyle karsilastiriyoruz
	
	la	$a0, hiddenWord
	la	$a1, guessWord

	find($a1, 0, 'x')  #harf alï¿½yorum kullanicidan guide gordugunuz her x bir harfi temsil etmekte
	beq	$v0, -1, _CheckGuessWord
	  
	# Tahmini karakter iceren gizli kelimeyi kontrol etigimiz kisim
	lb	$a0, guessChar
	la	$a1, hiddenWord
	
	find($a1, 0, $a0)
	
	beq	$v0, -1, Nothidden 
	j	hidden
	
	Nothidden:
		lb	$a0, playerStatus
		addi	$a0, $a0, 1
		sb	$a0, playerStatus
		
		beq	$a0, 7, GuessWordWrong
		
		# yanlis cevabi goster
		la	$a0, notiWrongChar
		messagebox($a0, 0)
		
		# burada yaptigim yanlislar adami asmamda etkili olacak
		
		jal	_DrawPlayerStatus
	
		# jump to Loop Guess One word kelime tahminine geri dï¿½nï¿½yrum 
		j	LoopGuessOneWord
		
	hidden:
		# total degerlerim tahmin edilebilir olan kelimem ve harfim dogru ve sakli olan bir kelimem bunlar uzerinden ilerleyecegiz
		la	$a0, guessWord
		lb	$a1, guessChar
		la	$a2, hiddenWord
		
		li	$t0, -1
		
		LoopFillChar:
			# prevPos + 1 = posStartFind 
			addi	$t0, $t0, 1
			
			# gizli kelimede pos char buluyoruz
			find($a2, $t0, $a1)
			move	$t0, $v0
			
			# tahmin edileni kaydediyoruz
			add	$a0, $a0, $t0
			sb	$a1, ($a0)
			sub	$a0, $a0, $t0
				
			bne	$t0, -1, LoopFillChar
			
		compare($a0, $a2)
		beq	$v0, 1, GuessWordRight
		# kelime tahminine geri deniyorum 
		j	LoopGuessOneWord

# burada kullanicinin yanlis tahminlerine gore adami cizdirecegiz
_Lose:
		
		# adami cizdiriyorum
		jal 	_DrawPlayerStatus
		
		la	$a0, notiLostGame
		messagebox($a0, 0)
		
		# oyuncuya skorunu gosteriyoruz
		la	$a0, notiInfor
		printString($a0)
		la	$a0, notiName   #ismi a0 atiyoruz
		la	$a1, notiScore  #kazandigi scor a1 atiyoruz
		la	$a2, notiWord   #bildigi kelimeler a2 atiyoruz
		#yazdiriyoruz a0,a1,a2
		printString($a0)
		printString($a1)
		printString($a2)
		
		la	$a0, playerName
		lw	$a1, playerScore
		lw	$a2, playerWord
		printString($a0)
		printChar('\t')
		printInt($a1)
		printChar('\t')
		printInt($a2)
		printChar('\n')
		
		# reset 
		sb	$zero, playerStatus
		sw	$zero, playerScore
		sw	$zero, playerWord
		
		# burada kullanicimiza oyundan cikmak ister mi diye soruyoruz
		la	$a0, askStatusGame
		confirmbox($a0)
		
		#eger cikmak isterse bu oyunu oynayanlar arasindan ilk 10 un scorlarini,isimlerini,kac kelime bildiklerini gostermekteyiz
		beq	$v0, 0, Hangman
		
		j	_BestPlayer	
									
_DrawPlayerStatus:
	pushStack($ra)
	pushStack($t0)
	#adamimiz 7 parcadan olusuyor asilacak bolumleri
	lb	$t0, playerStatus
	
	#statusuma gore asma islemini baslatiyorum
	beq	$t0, 1, draw1
	beq	$t0, 2, draw2
	beq	$t0, 3, draw3
	beq	$t0, 4, draw4
	beq	$t0, 5, draw5
	beq	$t0, 6, draw6
	beq	$t0, 7, draw7
	j 	EndDraw
	
	draw7:  gallowsdesign(7)
	draw6:  gallowsdesign(6)
	draw5:  gallowsdesign(5)
	draw4:  gallowsdesign(4)
	draw3:  gallowsdesign(3)
	draw2:  gallowsdesign(2)
	draw1:  gallowsdesign(1)
	
	EndDraw:
	
	popStack($t0)
	popStack($ra)
	
	jr	$ra
	
_BestPlayer:
	# oyuncularini numaralandir
	li	$s0, 0
	la	$a0, tempStr
	
	LoopCountPlayer:
		# oyunculari ayirdigim kisim * ile ayirmaktayim
		getline($s0, $a0, '*', dataPlayer)
		beq	$v0, -1, EndLoopCountPlayer
		addi	$s0, $s0, 1
		j	LoopCountPlayer
		
	EndLoopCountPlayer:
	sw	$s0, numPlayer
	
	# dynamic allocation
	li	$gp, 0x10040000 # heap
	lw	$s0, numPlayer
	
	# oyuncu ismi
	mul	$t0, $s0, 24   # her isim len = 20 bir tane boï¿½
	sw	$gp, allPlayerNameBuffPtr
	add	$gp, $gp, $t0

	# score
	mul	$t0, $s0, 4   # 1 score = 1 word = 4 bytes
	sw	$gp, allPlayerScorePtr
	add	$gp, $gp, $t0
	
	# ptr name
	sw	$gp, allPlayerNamePtr
	add	$gp, $gp, $t0

	# number word
	sw	$gp, allPlayerWordPtr
	add	$gp, $gp, $t0

	# datalarimi yukluyorum
	li	$s1, 0
	la	$a0, tempStr
	lw	$a1, allPlayerNamePtr
	lw	$a2, allPlayerScorePtr
	lw	$a3, allPlayerWordPtr
	lw	$s0, allPlayerNameBuffPtr
	
	# dosyadan okuyorum cunku oyunculari dosyada tutuyordum scorlarini
	LoopReadDataPlayer:
		# her oyuncu * ile ayrï¿½lï¿½yor
		getline($s1, $a0, '*', dataPlayer)
		beq	$v0, -1, EndLoopReadDataPlayer
		
		# ismini aliyorum oyuncunun
		getstr($s0, $a0, '-', 0)
		sw	$s0, ($a1)
		addi	$s0, $s0, 24
		addi	$a1, $a1, 4
		
		# scorunu aliyorum
		getstr($a2, $a0, '-', 1)
		int($a2)
		sw	$v0, ($a2)
		lw	$s3, ($a2)
		addi	$a2, $a2, 4
		
		# kac kelime bildigini aliyorum
		getstr($a3, $a0, '-', 2)
		int($a3)
		sw	$v0, ($a3)
		addi	$a3, $a3, 4
		
		addi	$s1, $s1, 1
		# bunu tekrarlï¿½yorum
		j	LoopReadDataPlayer
		
	EndLoopReadDataPlayer:
	
	# burada oyuncular arasï¿½ siralama yapacagim kisim
	lw	$a0, allPlayerNamePtr
	lw	$a1, allPlayerScorePtr
	lw	$a2, allPlayerWordPtr


	li	$t0, 0 # i
	li	$t1, 0 # j
	li	$t2, 0 # max_index
	lw	$t3, numPlayer
	li	$t4, 0 # address arr[j]
	li	$t5, 0 # address arr[min_index]
	li	$t6, 4
	li	$s0, 0
	li	$s1, 0
	li	$s2, 0
	
	LoopForI:
		move	$t2, $t0
		bge	$t0, $t3, EndLoopForI
		
		move	$t1, $t0
		LoopForJ:
			
			bge	$t1, $t3, EndLoopForJ 
			
			# cal address arrayin elemanlarinin
			mult	$t1, $t6
			mflo	$t4
			
			mult	$t2, $t6
			mflo	$t5
			
			# karsilastirma and degistirme (max_index)
			add	$a1, $a1, $t4
			lw	$s0, ($a1)
			sub	$a1, $a1, $t4
			
			add	$a1, $a1, $t5
			lw	$s1, ($a1)
			sub 	$a1, $a1, $t5
		
			bgt 	$s0, $s1, ChangeMaxIndex 
			j 	IncreaseJ
			
			ChangeMaxIndex:
				move	$t2, $t1
				
			IncreaseJ:
				addi	$t1, $t1, 1
				
			beq	$zero, $zero, LoopForJ
		EndLoopForJ:
		
		# desigtir
		mul	$t4, $t2, 4
		mul	$t5, $t0, 4
		
		# isim degistirdigim kisim
		add	$a0, $a0, $t4
		lw	$s0, ($a0)
		sub	$a0, $a0, $t4
	
		add	$a0, $a0, $t5
		lw	$s1, ($a0)
		sub	$a0, $a0, $t5
		
		swap($s0, $s1)
		
		add	$a0, $a0, $t4
		sw	$s0, ($a0)
		sub	$a0, $a0, $t4
		
		add	$a0, $a0, $t5
		sw	$s1, ($a0)
		sub	$a0, $a0, $t5
		
		#scoru degistirdigim kisim
		add	$a1, $a1, $t4
		lw	$s0, ($a1)
		sub	$a1, $a1, $t4
		
		add	$a1, $a1, $t5
		lw	$s1, ($a1)
		sub	$a1, $a1, $t5
		
		swap($s0, $s1)
		
		add	$a1, $a1, $t4
		sw	$s0, ($a1)
		sub	$a1, $a1, $t4
		
		add	$a1, $a1, $t5
		sw	$s1, ($a1)
		sub	$a1, $a1, $t5
		
		# bildigi kelimelere gore degistigim kisim
		add	$a2, $a2, $t4
		lw	$s0, ($a2)
		sub	$a2, $a2, $t4
		
		add	$a2, $a2, $t5
		lw	$s1, ($a2)
		sub	$a2, $a2, $t5
		
		swap($s0, $s1)
		
		add	$a2, $a2, $t4
		sw	$s0, ($a2)
		sub	$a2, $a2, $t4
		
		add	$a2, $a2, $t5
		sw	$s1, ($a2)
		sub	$a2, $a2, $t5
		
		
		addi	$t0, $t0, 1
		
		beq	$zero, $zero, LoopForI
	EndLoopForI:		
	
	# print header
	printConstString("\n BEST PLAYERS ! \n")
	la	$a0, notiName
	la	$a1, notiScore
	la	$a2, notiWord

	printString($a0)
	printString($a1)
	printString($a2)
	
	# print best players
	li	$t0, 0
	lw	$t1, numPlayer
	lw	$a0, allPlayerNamePtr
	lw	$a1, allPlayerScorePtr
	lw	$a2, allPlayerWordPtr
	bgt	$t1, 10, Assign10
	j 	LoopPrintBest
	
	Assign10:
		li	$t1, 10

	LoopPrintBest:
		# load data
		lw	$s0, ($a0)
		lw	$s1, ($a1)
		lw	$s2, ($a2)
		
		# print data
		printString($s0)
		printChar('\t')
		printInt($s1)
		printChar('\t')
		printInt($s2)
		printChar('\n')
		
		# addresi artiriyorum
		addi	$a0, $a0, 4
		addi	$a1, $a1, 4
		addi	$a2, $a2, 4
		
		
		addi 	$t0, $t0, 1
		
		
		blt	$t0, $t1, LoopPrintBest
	# reset	
	li	$sp, 0x10040000 
.data
#kullanicimiza burada sorular yonetiyoruz..Kullanici isterse harf alabilir ya da risk alarak kelimenin tamamnini tahmin edebilir ama unutmayin ki yanlis tahmin ederse adamimiz tamamen asilir !
	helloGame:		.asciiz 	"Welcome to the game Hangman"
	askPlayerName:		.asciiz		"Pleace enter your name"
	askInputChar:		.asciiz		"Pleace enter the letter"
	askInputWord:		.asciiz		"What is the word??"
	askStatusGame:		.asciiz 	"Do you want to continue the game?"
	chooseGuessWord:	.asciiz		"Do you want to enter words?"
	notiLostGame:		.asciiz		"Is there a problem ? "
	notiRightWord:		.asciiz 	"That's right, you're so good!!"
	notiWrongChar:		.asciiz		"Did you do wrong?"
	wordbox:		.asciiz 	"wordbox.txt"
	dataPlayer:		.asciiz		"playerinfo.txt"                     # oyunumuzu oynayanlarï¿½n bilgilerini burada saklayacagiz
	
	notiInfor:		.asciiz		"Player's infor\n"
	notiName:		.asciiz		"Player Name\t"
	notiScore:		.asciiz		"Player Score\t"
	notiWord:		.asciiz		"Number of word\n"
	
	allPlayerNameBuffPtr:	.word		0
	allPlayerNamePtr:	.word		0	
	allPlayerScorePtr:	.word		0	
	allPlayerWordPtr:	.word		0	
	numWordDictionary:	.word		0
	numPlayer:		.word		0
	
	hiddenWord:		.space		12
	guessWord:		.space		12
	guessChar:		.space		4
	tempStr:		.space		48
	playerName:		.space		24
	playerScore:		.word		0
	playerWord:		.word		0
	playerStatus:		.word		0
