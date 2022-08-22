
# dar agaci tasarimi
.macro gallowsdesign(%num)
	pushStack($t0)
	pushStack($s0)
	pushStack($s1)
	pushStack($s2)
	pushStack($s3)
	pushStack($s4)
	pushStack($t9)
	
	#Init
	add $t0,$zero,%num
	
	DrawGallowsSC:
	
	beq $t0,1,gallowsdesign_1
	beq $t0,2,gallowsdesign_2
	beq $t0,3,gallowsdesign_3
	beq $t0,4,gallowsdesign_4
	beq $t0,5,gallowsdesign_5
	beq $t0,6,gallowsdesign_6
	beq $t0,7,gallowsdesign_7
	
	j EndDrawGallows
	
	gallowsdesign_1:
		# dar agaci
		li $s0,10  #x basliyor
		li $s1,40  #x bitti
		li $s2,120 #y 
		li $t9, 0xFF0000 # rengim kirmizi (hexa tabanli)
		line_horizontal($s0, $s2, $s1, $t9)	
	
		li $s0,20 	#x1
		li $s1,30	#x2
		li $s2,20	#y1
		li $s3,120	#y2
		rectangle($s0,$s2,$s1,$s3,$t9)
		
		li $t9, 0x008000 # rengim yesil (hexa tabanli)
		li $s0,30	#x basliyor
		li $s1,80	#x bitti
		li $s2,20	#y
		line_horizontal($s0, $s2, $s1, $t9)
		# dar agacimin tahtasi
		li $s0,65	#x
		li $s1,20	#y basliyor
		li $s2,30	#y bitti
		line_vertical($s0,$s1,$s2,$t9)
		j EndDrawGallows
	gallowsdesign_2:
		# adamimin kafasi
		li $t9, 0x00FFFF # rengim yesil (hexa tabanli)
		li $s0,65	#x
		li $s1,40	#y
		li $s2,10	# adamimin kafasinin capi 
		
		circle($s0,$s1,$s2,$t9)
		
		li $t9, 0xFFFFFF # rengim camgöbeği 
		
		# sol goz
		li $s3,63	#x
		li $s4,38	#y
		
		drawPixel($s3,$s4,$t9)
		
		# sag goz
		li $s3,67	#x
		li $s4,38	#y
		
		drawPixel($s3,$s4,$t9)
		
		# agiz
		li $t9, 0xFF0000 # rengim kirmizi
		li $s0,62	#x basliyor
		li $s1,69	#y
		li $s2,43	#x bitti 
		
		line_horizontal($s0, $s2, $s1, $t9)
		
		j EndDrawGallows
	gallowsdesign_3:
		# vucud
		li $t9, 0xFFFF00
		li $s0,65	#x
		li $s1,50	#y basliyor
		li $s2,80	#y bitti
		
		line_vertical($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	gallowsdesign_4:
		# sag el 
		li $s0,65	#x
		li $s1,55	#y
		li $s2,13	#l uzunluk 
		li $t9, 0x800080
		
		lefttoright($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	gallowsdesign_5:
		# sol el
		li $s0,65	#x
		li $s1,55	#y
		li $s2,13	# uzunluk 
		li $t9, 0x800080
		
		righttoleft($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	gallowsdesign_6:
		# sag bacak
		li $s0,65	#x
		li $s1,80	#y
		li $s2,15	# uzunluk 
		li $t9, 0x800080
		
		lefttoright($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	gallowsdesign_7:
		# sol bacak
		li $s0,65	#x
		li $s1,80	#y
		li $s2,15	# uzunluk 
		li $t9, 0x800080
		
		righttoleft($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	
	EndDrawGallows:
	
	popStack($t9)
	popStack($s4)
	popStack($s3)
	popStack($s2)
	popStack($s1)
	popStack($s0)
	popStack($t0)
.end_macro

#Yatay bir çizgi çizin
.macro line_horizontal(%xStart, %y, %xEnd, %color)
	pushStack($t0)
	pushStack($t1)
	
	# init
	add	$t0, $zero, %xStart
	
	LoopDrawHorizontalLine:
		# pixel ciziyoruz
		drawPixel($t0, %y, %color)
		
		# x ' i bir arttiriyoruz
		addi	$t0, $t0, 1
		
		# loop
		blt	$t0, %xEnd, LoopDrawHorizontalLine
	
	popStack($t1)
	popStack($t0)
.end_macro

# dikey bir cizgi ciziyoruz
.macro line_vertical(%x, %yStart, %yEnd, %color)
	pushStack($t0)
	pushStack($t1)
	
	# init
	add	$t1, $zero, %yStart
	
	LoopDVL:
		# pixel ciziyoruz
		drawPixel(%x,$t1, %color)
		#  y ' yi bir arttiriyoruz
		addi	$t1, $t1, 1
		# loop
		blt	$t1, %yEnd, LoopDVL
	popStack($t1)
	popStack($t0)
.end_macro

.macro rectangle(%x1, %y1, %x2, %y2, %color)
	line_horizontal(%x1,%y1,%x2,%color)
	line_horizontal(%x1,%y2,%x2,%color)
	line_vertical(%x1, %y1, %y2, %color)
	line_vertical(%x2, %y1, %y2, %color)
.end_macro

# bir daire ciziyoruz
.macro circle(%x,%y,%radius,%color)
	
	pushStack($s0)
	pushStack($s1)
	pushStack($s2)
	pushStack($s3)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($t4)
	pushStack($t5)
	pushStack($t6)
	pushStack($t7)
	pushStack($t8)
	pushStack($t9)
    
    	#Init
    	add $s0,$zero,%x
	add $s1,$zero,%y
	add $s3,$zero,%radius
	
 
   	move $t0, $s0            #x0
   	move $t1, $s1            #y0
   	move $t2, $s3            # cap
   	addi $t3, $t2, -1        #x
   	li   $t4, 0              #y
   	li   $t5, 1              #dx
   	li   $t6, 1              #dy
   	li   $t7, 0              #Err

   	# ERR 'i hesapliyoruz (dx - (cap << 1))
   	sll  $t8, $t2, 1         # cap 'i bir sola kaydiriyoruz 
   	subu $t7, $t5, $t8           # dx den cikariyoruz

   	#While(x >= y)
    	circleLoop:
    	blt  $t3, $t4, skipCircleLoop    #If x < y, skip circleLoop

    	# pixel ciziyoruz (x0 + x, y0 + y)
    	addu $s0, $t0, $t3
    	addu $s1, $t1, $t4
    	
	drawPixel($s0,$s1,%color)

        # pixel ciziyoruz (x0 + y, y0 + x)
        addu $s0, $t0, $t4
        addu $s1, $t1, $t3
       	
	drawPixel($s0,$s1,%color)            

        # pixel ciziyoruz (x0 - y, y0 + x)
        subu $s0, $t0, $t4
        addu $s1, $t1, $t3
        
	drawPixel($s0,$s1,%color)           

        # pixel ciziyoruz (x0 - x, y0 + y)
        subu $s0, $t0, $t3
        addu $s1, $t1, $t4
      
      	drawPixel($s0,$s1,%color)         

        # pixel ciziyoruz (x0 - x, y0 - y)
        subu $s0, $t0, $t3
        subu $s1, $t1, $t4
      	
	drawPixel($s0,$s1,%color)           

        # pixel ciziyoruz (x0 - y, y0 - x)
        subu $s0, $t0, $t4
        subu $s1, $t1, $t3
       
       	drawPixel($s0,$s1,%color)           

        # pixel ciziyoruz (x0 + y, y0 - x)
        addu $s0, $t0, $t4
        subu $s1, $t1, $t3
      
      	drawPixel($s0,$s1,%color)          

        # pixel ciziyoruz (x0 + x, y0 - y)
        addu $s0, $t0, $t3
        subu $s1, $t1, $t4
       	
	drawPixel($s0,$s1,%color)           

    	# err <= 0 ise 
   	bgtz $t7, doElse
   	addi $t4, $t4, 1     #y++
   	addu $t7, $t7, $t6       #err += dy
    	addi $t6, $t6, 2     #dy += 2
    	j    circleContinue      #Skip else stmt

    	# err > 0 ise
    	doElse:
    	addi  $t3, $t3, -1        #x--
    	addi  $t5, $t5, 2     #dx += 2
    	sll   $t8, $t2, 1     # cap 'i bir sola kaydiriyoruz
    	subu  $t9, $t5, $t8       # dx den cikariyoruz
    	addu  $t7, $t7, $t9       #err += $t9

    	circleContinue:
    	# loop
    	j   circleLoop

    	#devam 
    	skipCircleLoop:     

    	popStack($t9)
	popStack($t8)
	popStack($t7)
	popStack($t6)
	popStack($t5)
	popStack($t4)
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
    	popStack($s3)
   	popStack($s2)
    	popStack($s1)
   	popStack($s0)
	
	
.end_macro

# soldan saga bir capraz ciziyoruz
.macro lefttoright(%x,%y,%length,%color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	
	
	#Init
	add $t0,$zero,%x
	add $t1,$zero,%y
	
	li $t2,0
	looplDrawlrdia:
		drawPixel($t0,$t1,%color)
		#  x ' i bir arttiriyoruz
		addi $t0,$t0,1
		
		# y ' i bir arttiriyoruz
		addi $t1,$t1,1
		
		# loop
		addi $t2,$t2,1
		blt	$t2,%length,looplDrawlrdia
		
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
	
.end_macro

# sagdan sola doru bir capraz ciziyoruz
.macro righttoleft(%x,%y,%length,%color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	
	add $t0,$zero,%x
	add $t1,$zero,%y
	
	li $t2,0
	looplDrawrldia:
		
		drawPixel($t0,$t1,%color)
		
		#  x ' i bir arttiriyoruz
		addi $t0,$t0,-1
		
		# y ' i bir arttiriyoruz
		addi $t1,$t1,1
		
		# loop
		addi $t2,$t2,1
		blt	$t2,%length,looplDrawrldia
	
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
	
.end_macro

.macro drawPixel(%x, %y, %color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	
	add	$t0, $zero, %x
	add	$t1, $zero, %y

	li	$t2, 128
	mult	$t1, $t2
	mflo	$t1
	
	# sonuc + x
	add	$t1, $t1, $t0
	
	#  $gp konumu
	li	$t2, 4
	mult	$t1, $t2
	mflo	$t1
	
	
	# rengi kaydediyoruz
	add	$t2, $zero, %color
	li	$t3, 0x10000000
	add	$t3, $t3, $t1
	sw	$t2, ($t3)
	sub	$t3, $t3, $t1
	
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro
