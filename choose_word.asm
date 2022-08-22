.macro choose(%size)
        pushStack($t7)
        pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($a0)
	pushStack($a1)
	pushStack($a2)
	pushStack($a3)

   
        add $t7,$0,%size                 # sizeyi t7 ye kaydediyorum 
        la $t1,sizecur
        lw $t1,sizecur
          #kontrol ediyorum ( size <=100) sagliyor mu
        li $t2,101                      
        slt $t2,$t7,$t2
        blez $t2,resize                #  $t2=0  size >100
 
         j RanDom
resize:                       # sizem 100 den buyuk oldugunda size=100 olsun
         li $t7,100

RanDom:        
          la $a2,arr         
          move $a1,$t7       #0'dan boyuta ayarlanan aralık maksimim boyut 100 olabilir anca
          li $v0,42    
          # rastgele sayı üretir ve onu $a0 içine koyar      
          syscall

          beq $t1,$t7,End           #burada kontol ediyoruz 
          li $t0,0 # count 0
        
       
control:                          
          beq $t0,$t1,Exit
          lw $a3,0($a2)
          bne $a0,$a3,incre
          j RanDom
         
          incre:
          addi $a2,$a2,4
          addi $t0,$t0,1
          j control

          #a1 ramdom numarasını kaydet
Exit:
        li $t2,4
        mult $t2,$t0
        mflo $t2
        sw $a0,($a2)   # save -> (a$2)
        sub $a2,$a2,$t2   # $a2 = $a2- 4*($t0)
  
         # indexsimi artırıyorum
         addi $t1,$t1,1
         sw $t1,sizecur
         
         move $v0,$a0  # v0 i kaydediyorum
         j end_marco
End:
         li $v0,10
          syscall
end_marco:
	popStack($a3)
	popStack($a2)
	popStack($a1)
	popStack($a0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
        popStack($t7)	
.end_macro

.data 
#Ssecilen rasgele sayiyi kaydediyoruz
      arr: .word 0:100 
 # secilen rasgele sayinin dizi boyutu
      sizecur:.word 0:100