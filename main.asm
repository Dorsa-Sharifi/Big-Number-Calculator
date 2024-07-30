segment .data
    operator:       db          0
    first:         times 256   db  0    
    second:        times 256   db  0
    answer         times 256   db  0
    num1:           dq 0, 0, 0, 10
    num2:           dq 0, 0, 0, 4
    answer256:      dq 0, 0, 0, 0
    backupNum:      dq 0, 0, 0, 0
    Remainder:      dq 0, 0, 0, 0
    Quotient:       dq 0, 0, 0, 0
    toBeAdded:      dq 0, 0, 0, 0
    ONEONE:         dq 0, 0, 0, 1
    shiftValue:     db          0
    newline:        db          0
    firstSign:      db          0 
    secondSign:     db          0
    answerSign:     db          0  
    firstBit:       dd          0
    secondBit:      dd          0
    length1:        db          0
    length2:        db          0
    dividable:      dq          0  
    lengthAnswer:   db          0 
    carryFlag:      db          0
    borrowFlag:     db          0
    biggerValue:    db          0
    counterOfLoop:  db          0
    firstNumSeen:   db          0
    NewLine:        db 0x0A, 0x0D, 0

    OneFound:       dq          0   
    shiftSize:      db          0
    BIGGERONEIS:    dq          0
    print_int_format: db        "%ld", 0
segment .text
extern scanf
extern printf
extern getchar
extern putchar
global asm_main

%macro write_char 2
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, %1
    mov     edx, %2
    int     0x80
%endmacro


%macro  read_char 2
    mov     eax, 3
    mov     ebx, 2
    mov     ecx, %1
    mov     edx, %2
    int     0x80
%endmacro


asm_main:
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    main_Loop:

        read_char  operator,1                   ;Read and store the operator
        read_char  newline, 1                   ;Read the \n after operator       
        clc     
        mov         al, 0                   
        mov         [carryFlag], al             ; initializing carrayFlag to 0
        mov         [borrowFlag], al            ; initializing borrowFlag to 0
        mov         [firstSign], al             ; initializing signs to 0
        mov         [secondSign], al
        mov         [lengthAnswer], al
        mov         [firstNumSeen], al
        mov         [counterOfLoop], al
        mov         [biggerValue], al
        mov         [length1], al
        mov         [length2], al
        mov         [answerSign], al
        mov         [shiftValue], al  
        mov         [answerSign], al 
        mov         [firstBit], al    
        mov         [secondBit], al 
        mov         [dividable], al      
        mov         [lengthAnswer], al 
        mov         [OneFound], al   
        mov         [shiftSize], al
        mov         [BIGGERONEIS], rax               
        
        mov         al, [operator]      
        cmp         al, 113                     ; if operator = q then terminate
        je          terminate_code

        cmp         al, 42                      ; if operator = * 
        je          getInputVersion
        cmp         al, 47                      ; if operator = / 
        je          getInputVersion        
        cmp         al, 37                      ; if operator = % 
        je          getInputVersion
        mov         esi, first                  ; esi = first         

    getFirst:
        read_char   newline, 1                  ; getting every byte of the first num  
        mov         al, [newline]
        cmp         al, 10                      ; if newline == \n then get the second num 
        je          getReadySecond  
        cmp         al, 45                      ; if it's - then we ignore the sign
        je          firstIsNegative 

        mov         [esi], eax                  ; loading the new char into array        
        inc         esi                         ; updating to the next element
        mov         al, [length1]               ; updating length1
        inc         al
        mov         [length1], al
        jmp         getFirst                    ; go back to get the next char
    firstIsNegative:
        mov         al, 1
        mov         [firstSign], al             ;if sign = 1 so it's -             
        jmp         getFirst

    getReadySecond:
        mov         esi, second                 ; set pointer to first
    getSecond:
        read_char   newline, 1                  ; getting every byte of the second num  
        mov         al, [newline]
        cmp         al, 10                      ; if newline == \n then time to calculate 
        je          calculation_prep
        cmp         al, 45                      ; if it's - then we ignore the sign
        je          secondIsNegative 
        mov         [esi], eax                  ; loading the new char into array
        inc         esi                         ; updating to the next element
        mov         al, [length2]               ; updating length2
        inc         al
        mov         [length2], al
        jmp         getSecond                   ; go back to get the next char 
    secondIsNegative:
        mov         al, 1
        mov         [secondSign], al            ;if sign = 1 so it's -             
        jmp         getSecond               ; go back to get the next char       

    calculation_prep:
        mov         al, [operator]     
        cmp         al, 43                 ; if operator = + 
        je          main_add
     
        cmp         al, 45                 ; if operator = - 
        je          main_sub
    
   
        cmp         al, 47                 ; if operator = / 
        ;je          main_div        
     
        cmp         al, 37                 ; if operator = % 
        ;je          main_div


        
    main_add: 
        mov         al, [firstSign]
        mov         bl, [secondSign]
        xor         al, bl
        cmp         al, 1
        je          startOfSub    
        mov         al, [firstSign]
        mov         [answerSign], al
    startOfAdd:
        call        setPointersToArrays
    additionPosPos:
        mov         bl, byte[edx]       ; current bit of first
        mov         al, byte[esi]       ; current bit of second    
        sub         bl, '0'             ; char 1 ---> int 1
        sub         al, '0'             ; char 2 ---> int 2
        add         bl, al              ; bl = 1 + 2
        mov         al, [carryFlag]     ; if there's any carry we add it here
        cmp         al, 0
        je          noCarry
        inc         bl
        mov         al, 0
        mov         [carryFlag], al 
    noCarry:
        cmp         bl, 10              ; if add provides carry we set it here
        jl          continueOfAPP
        sub         bl, 10
        mov         al, 1
        mov         [carryFlag], al
    continueOfAPP:
        add         bl, '0'             ; int sum ---> char sum
        mov         [ecx], ebx          ; save the sum bit in the answer array
        mov         al, [lengthAnswer]  ; updating lengthAnswer
        inc         al
        mov         [lengthAnswer], al
        
        mov         al, [length1]       ; updating length1
        dec         al
        mov         [length1], al

        mov         al, [length2]       ; updating length2
        dec         al
        mov         [length2], al
 
        mov         al, [length1]       ; if we reach l1 = l2 = 0 it means 
        mov         bl, [length2]       ; that we've done all summations 
        or          al, bl              ; it's time for final printing
        cmp         al, 0
        je          sameLengthAPP

        mov         al, [length1]
        cmp         al, 0               ; if only l1 = 0 then we have to copy
        je          copySecondAPP       ; rest of the bits from 2 into answer

        cmp         bl, 0               ; if only l2 = 0 then we have to copy
        je          copyFirstAPP        ; rest of the bits from 1 into answer
        dec         edx                 ; if l1 != 0 then we can go backward in 1st
        
        dec         esi                 ; if l2 != 0 then we can go backward in 2nd
        inc         ecx                 ; next index in answer
        jmp         additionPosPos

    sameLengthAPP:
        mov         al, [carryFlag]     ; if there exists any carry
        cmp         al, 0
        je          print_result
        mov         al, 0
        mov         [carryFlag], al
        inc         ecx                 ; we have a carry so we move to the next index
        mov         bl, 1
        add         bl, '0'             ; int ---> char
        mov         [ecx], ebx
        mov         al, [lengthAnswer]  ; updating lengthAnswer
        inc         al
        mov         [lengthAnswer], al
        jmp         print_result
    copySecondAPP:
        mov         al, [length2]
        cmp         al, 0
        je          print_result
        dec         esi                 ; moving backward in second
        inc         ecx
        mov         bl, byte[esi]
        sub         bl, '0'             ; char 2 ---> int 2 
        mov         al, [carryFlag]     ; checking for carry
        cmp         al, 0
        je          restOfCSAPP
        mov         al, 0
        mov         [carryFlag], al
        inc         bl                  ; carry added to bl
    restOfCSAPP:
        add         bl, '0'
        mov         [ecx], ebx
        mov         al, [lengthAnswer]  ; updating lengthAnswer
        inc         al
        mov         [lengthAnswer], al
        mov         al, [length2]
        dec         al
        mov         [length2], al
        jmp         copySecondAPP
    copyFirstAPP:
        mov         al, [length1]
        cmp         al, 0
        je          print_result
        dec         edx
        inc         ecx
        mov         bl, byte[edx]
        sub         bl, '0'
        mov         al, [carryFlag]
        cmp         al, 0
        je          restOfCFAPP
        mov         al, 0
        mov         [carryFlag], al
        inc         bl
    restOfCFAPP:
        add         bl, '0'
        mov         [ecx], ebx
        mov         al, [lengthAnswer]  ; updating lengthAnswer
        inc         al
        mov         [lengthAnswer], al
        mov         al, [length1]
        dec         al
        mov         [length1], al
        jmp         copyFirstAPP 

    main_sub:
        mov         al, [firstSign]
        mov         bl, [secondSign]
        xor         al, bl
        cmp         al, 1
        je          startOfAdd
    startOfSub:    
        mov         ecx, answer             ; ecx = answer    
        mov         edx, first              ; edx = first
        mov         esi, second             ; esi = second
        mov         al, 0
        mov         [counterOfLoop], al     ; counter = 0 
        mov         [borrowFlag], al        ; borrowFlag = 0            
        call        findGreater
        call        setPointersToArrays
        mov         al, [biggerValue]
        cmp         al, 0
        je          answerIsZero
        cmp         al, 1
        je          additionPosNegOneGR
        cmp         al, 2
        je          additionPosNegTwoGR
    additionPosNegOneGR:
        mov         bl, byte[edx]           ; first into bl
        sub         bl, '0'                 ; char 1 ---> int 1
        mov         al, [borrowFlag]
        cmp         al, 0
        je          noBorrowReservedOneGR
        mov         al, 0
        mov         [borrowFlag], al
        dec         bl                      ; decreasing borrow
    noBorrowReservedOneGR:    
        mov         al, byte[esi]           ; second into al
        sub         al, '0'                 ; char 2 ---> int 2
        sub         bl, al                  ; doing subtraction
        cmp         bl, 0
        jge         noBorrowOneGR           ; if bl < 0 then we have a borrow
        mov         al, 1
        mov         [borrowFlag], al        ; setting borrow for next subtract
        add         bl, 10
    noBorrowOneGR:
        add         bl, '0'                 ; int sum ---> char sum
        mov         [ecx], ebx              ; mov sum into ecx
        mov         al, [lengthAnswer]      ; updating lengthAnswer
        inc         al
        mov         [lengthAnswer], al

        mov         al, [length1]           ; updating length1
        dec         al
        mov         [length1], al

        mov         al, [length2]           ; updating length2
        dec         al
        mov         [length2], al
 
        cmp         al, 0                   ; if only l2 = 0 then we have to copy
        je          copyFirstAPN            ; rest of the bits from 1 into answer
    
        dec         edx                     ; if l1 != 0 then we can go backward in 1st
        dec         esi                     ; if l2 != 0 then we can go backward in 2nd
        inc         ecx                     ; next index in answer
        jmp         additionPosNegOneGR
    
    copyFirstAPN:
        mov         al, [length1]
        cmp         al, 0                   ; if length1 = 0 so we've done everything
        je          print_result            ; and it's time for printing
        inc         ecx                     ; next index of answer
        dec         edx                     ; prev index of 1
        mov         bl, byte[edx]
        sub         bl, '0'
        mov         al, [borrowFlag]
        cmp         al, 0
        je          restOfCopyAPN
        sub         bl, al
        mov         al, 0
        mov         [borrowFlag], al
        cmp         bl, 0
        jge         restOfCopyAPN
        add         bl, 10
        mov         al, 1
        mov         [borrowFlag],al
    restOfCopyAPN: 
        add         bl, '0'   
        mov         [ecx], ebx              ; saving into answer
        mov         al, [lengthAnswer]      ; updating lengthAnswer
        inc         al
        mov         [lengthAnswer], al
        mov         al, [length1]           ; updating length
        dec         al
        mov         [length1], al
        jmp         copyFirstAPN
    additionPosNegTwoGR:
        mov         bl, byte[esi]           ; second into bl
        sub         bl, '0'                 ; char 1 ---> int 1
        mov         al, [borrowFlag]
        cmp         al, 0
        je          noBorrowReservedTwoGR
        mov         al, 0
        mov         [borrowFlag], al
        dec         bl                      ; decreasing borrow
    noBorrowReservedTwoGR:    
        mov         al, byte[edx]           ; first into al
        sub         al, '0'                 ; char 2 ---> int 2
        sub         bl, al                  ; doing subtraction
        cmp         bl, 0
        jge         noBorrowTwoGR                ; if bl < 0 then we have a borrow
        mov         al, 1
        mov         [borrowFlag], al        ; setting borrow for next subtract
        add         bl, 10
    noBorrowTwoGR:
        add         bl, '0'                 ; int sum ---> char sum
        mov         [ecx], ebx              ; mov sum into ecx
        mov         al, [lengthAnswer]      ; updating lengthAnswer
        inc         al
        mov         [lengthAnswer], al

        mov         al, [length2]           ; updating length2
        dec         al
        mov         [length2], al

        mov         al, [length1]           ; updating length1
        dec         al
        mov         [length1], al
 
        cmp         al, 0                   ; if only l1 = 0 then we have to copy
        je          copySecondAPN            ; rest of the bits from 2 into answer
    
        dec         edx                     ; if l1 != 0 then we can go backward in 1st
        dec         esi                     ; if l2 != 0 then we can go backward in 2nd
        inc         ecx                     ; next index in answer
        jmp         additionPosNegTwoGR
    copySecondAPN:
        mov         al, [length2]
        cmp         al, 0                   ; if length2 = 0 so we've done everything
        je          print_result            ; and it's time for printing
        inc         ecx                     ; next index of answer
        dec         esi                     ; prev index of 2
        mov         bl, byte[esi]
        sub         bl, '0'
        mov         al, [borrowFlag]
        cmp         al, 0
        je          restOfCopyAPNTwo
        sub         bl, al
        mov         al, 0
        mov         [borrowFlag], al
        cmp         bl, 0
        jge         restOfCopyAPNTwo
        add         bl, 10
        mov         al, 1
        mov         [borrowFlag],al
    restOfCopyAPNTwo: 
        add         bl, '0'   
        mov         [ecx], ebx              ; saving into answer
        mov         al, [lengthAnswer]      ; updating lengthAnswer
        inc         al
        mov         [lengthAnswer], al
        mov         al, [length2]           ; updating length
        dec         al
        mov         [length2], al
        jmp         copySecondAPN    

    answerIsZero:
        xor         eax, eax
        mov         al,0
        mov         [ecx], eax
        mov         al, [lengthAnswer]  ; updating lengthAnswer
        inc         al
        mov         [lengthAnswer], al
        jmp         print_result




    print_result:
        call        setAnswerSign
        mov         esi, answer
        mov         al, [lengthAnswer]
        add         esi, eax
        dec         esi
        mov         al, [answerSign]
        cmp         al, 0
        je          finalAnswer
        mov         al, [answerSign]
        cmp         al, 0
        jne         printNeg
        jmp         finalAnswer
    printNeg:
        mov         al, '-'
        mov         [newline], al
        write_char  newline, 1
    finalAnswer:    
        mov         al, byte[esi]
        cmp         al, '0'
        jne         noZeroBehind
        mov         bl, [firstNumSeen]
        cmp         bl, 0
        je          zeroBehindNum
    noZeroBehind:    
        mov         [newline], al 
        write_char   newline, 1
        mov         bl, 1
        mov         [firstNumSeen], bl
    zeroBehindNum:
        mov         al, [lengthAnswer]
        dec         al 
        mov         [lengthAnswer], al
        cmp         al, 0
        je          setTheNewLine 
        dec         esi
        jmp         finalAnswer
    setTheNewLine:
        write_char  NewLine, 1
        jmp         main_Loop  
    terminate_code:
    

    add     rsp, 8

	pop     r15
	pop     r14
	pop     r13
	pop     r12
    pop     rbx
    pop     rbp

	ret

detect_sign1:
    mov         al, [first]
    cmp         al, 45                  ; compare the leading byte with -
    je          first_neg  
    mov         al, 0
    mov         [firstSign], al         ; if sign = 0 so it's positive           
    jmp         detect_sign2
first_neg:
    mov         al, 1
    mov         byte [firstSign], al    ; if sign = 1 so it's negative

detect_sign2:
    mov         bl, [second]
    cmp         bl, 45                 ; compare the leading byte with -
    je          second_neg
    mov         bl, 0
    mov         [secondSign], bl       ; if sign = 0 so it's positive    
    ret
    
second_neg: 
    mov         bl, 1
    mov         [secondSign], bl        ; if sign = 1 so it's negative 
    ret 
setPointersToArrays:
    mov         ecx, answer             ; ecx = answer    
    mov         edx, first              ; edx = first      
    mov         al, [length1]
    dec         al
    add         edx, eax                ; go to the index of lsb
    mov         esi, second             ; esi = second
    mov         al, [length2]
    dec         al   
    add         esi, eax                ; go to the index of lsb  
    ret    

findGreater:
    mov         al, [length1] 
    mov         bl, [length2]
    cmp         al, bl   
    jg          firstIsGreater
    jl          secondIsGreater 
    mov         al, byte[edx]           ; msb of 1 in al
    mov         bl, byte[esi]           ; msb of 2 in bl
    cmp         al, bl                  
    je          equalNumsNext
    jg          firstIsGreater
    jmp         secondIsGreater          
    ret
firstIsGreater:
    mov         al, 1                   ; if 1 > 2 then biggerValue = 1
    mov         [biggerValue], al
    ret
secondIsGreater:
    mov         al, 2                   ; if 1 < 2 then biggerValue = 2
    mov         [biggerValue], al
    ret
equalNumsNext:
    mov         al,[counterOfLoop]
    inc         al
    mov         [counterOfLoop], al
    mov         bl, [length1]
    cmp         al, bl
    je          literallyEqual
    inc         esi
    inc         edx
    jmp         findGreater
literallyEqual: 
    mov         al, 0
    mov         [biggerValue], al        ; if 1 = 2 then biggerValue = 0
    ret    
setAnswerSign:
    mov         al, [operator]
    cmp         al, 43
    je          answerOfSUM
    cmp         al, 45
    je          answerSignOfSub
    cmp         al, 42
    je          answerOfMul
    cmp         al, 47
    je          answerOfDiv
    cmp         al, 37
    je          answerOfMod
    ret


answerOfMod:
    mov         al, [firstSign]
    mov         [answerSign], al
    ret
answerOfDiv:
    mov         al, [firstSign]
    mov         bl, [secondSign]
    xor         al, bl
    cmp         al, 1
    je          answerIsNeg
    mov         al, 0
    mov         [answerSign], al
    ret   

answerIsNeg:
    mov         al, 1
    mov         [answerSign], al
    ret
answerOfSUM :
    mov         al, [firstSign]
    mov         bl, [secondSign]
    xor         al, bl
    cmp         al, 1
    je          unknownSignSum
    ret
unknownSignSum:
    mov         al, [biggerValue]
    cmp         al, 1
    je          answerIsDueFirst
    cmp         al, 2
    je          answerIsDueSecSum
    ret
answerIsDueSecSum:
    mov         al, [secondSign]
    mov         [answerSign], al
    ret    
answerOfMul:
    mov         al, [firstSign]
    mov         bl, [secondSign]
    xor         al, bl         
    cmp         al, 0
    je          answerIsPos
    mov         al, 1
    mov         [answerSign], al
    ret
answerIsPos:
    mov         al, 0
    mov         [answerSign], al
    ret    
answerIsDueFirst:
    mov         al, [firstSign]
    mov         [answerSign], al
    ret    

answerIsDueSec:
    mov         al, [secondSign]
    cmp         al, 0
    je          makeItOne
    mov         al, 0
    mov         [answerSign],al 
    ret 
makeItOne:
    mov         al, 1
    mov         [answerSign], al
    ret    

answerSignOfSub:
    mov         al, [firstSign]
    mov         bl, [secondSign]
    xor         al, bl
    cmp         al , 0
    je          unknownSign
    mov         al, [firstSign]
    mov         [answerSign], al
    ret
unknownSign:
    mov         al, [biggerValue]    
    cmp         al, 1
    je          answerIsDueFirst
    cmp         al, 2
    je          answerIsDueSec
    ret                     
;115792089237316195423570985008687907853269984665640564039457584007913129639935 
getInputVersion: 
        
    ; Logic: We multiply the number saved in a 
    ; varible by 10 and add the current input to it
    call            InitializeEverything
    getNum1:                            ; number is in the num1
        xor         rax, rax
        read_char   newline, 1          ; getting every byte of the first num  
        mov         al, [newline]
        cmp         al, 10              ; if newline == \n then get the second num 
        je          getNum2  
        cmp         al, 45              ; if it's - then we ignore the sign
        je          Num1IsNegative 

        sub         al, '0'             ; char ---> int
        mov         qword[toBeAdded + 24], rax ; save the new input
        mov         rax, 24[num1]
        mov         rbx, num1           ; A
        mov         rax, backupNum      ; B
        mov         rdx, 10
        mov         24[backupNum], rdx
        mov         rdx, 24[rax]
        mov         rdx, answer256      ; destination
        mov         rcx, 256            ; counter
        mov         r15, 0
        call        multiply_function   ; A = A * B
        mov         rdx, 24[answer256]
        mov         qword[num1 + 24], rdx
        mov         rdx, 16[answer256]
        mov         qword[num1 + 16], rdx
        mov         rdx, 8[answer256]
        mov         qword[num1 + 8], rdx
        mov         rdx, 0[answer256]
        mov         qword[num1], rdx 

        mov         r12, num1           ; r12 = source 1
        mov         r13, toBeAdded      ; r13 = source 2
        mov         r14, num1           ; r14 = destination
        call        add256Bytes         ; new input
        mov         rdx, 0
        mov         qword[backupNum + 24], rdx
        mov         qword[backupNum + 16], rdx 
        mov         qword[backupNum + 8], rdx 
        mov         qword[backupNum], rdx
        mov         qword[toBeAdded + 24], rdx
        mov         qword[toBeAdded + 16], rdx 
        mov         qword[toBeAdded + 8], rdx 
        mov         qword[toBeAdded], rdx  
        mov         qword[answer256 + 24], rdx
        mov         qword[answer256 + 16], rdx 
        mov         qword[answer256 + 8], rdx 
        mov         qword[answer256], rdx                      

        jmp         getNum1            ; go back to get the next char
    Num1IsNegative:
        mov         al, 1
        mov         [firstSign], al     ;if sign = 1 so it's -             
        jmp         getNum1

    getNum2:
    mov         rdx, 0
    mov         qword[toBeAdded + 24], rdx
    mov         qword[toBeAdded + 16], rdx 
    mov         qword[toBeAdded + 8], rdx 
    mov         qword[toBeAdded], rdx  
    mov         qword[answer256 + 24], rdx
    mov         qword[answer256 + 16], rdx 
    mov         qword[answer256 + 8], rdx 
    mov         qword[answer256], rdx     
    mov         qword[num2 + 24], rdx
    mov         qword[num2 + 16], rdx 
    mov         qword[num2 + 8], rdx 
    mov         qword[num2], rdx 
    mov         qword[backupNum + 24], rdx
    mov         qword[backupNum + 16], rdx 
    mov         qword[backupNum + 8], rdx 
    mov         qword[backupNum], rdx     

    getNum2Start:                            ; number is in the num1
        xor         rax, rax
        read_char   newline, 1          ; getting every byte of the first num  
        mov         al, [newline]
        cmp         al, 10              ; if newline == \n then get the second num 
        je          detectOperator  
        cmp         al, 45              ; if it's - then we ignore the sign
        je          Num2IsNegative 

        sub         al, '0'             ; char ---> int
        mov         qword[toBeAdded + 24], rax ; save the new input
        ;mov         rax, 24[num1]
        mov         rbx, num2           ; A
        mov         rax, backupNum      ; B
        mov         rdx, 10
        mov         24[backupNum], rdx
        ;mov         rdx, 24[rax]
        mov         rdx, answer256      ; destination
        mov         rcx, 256            ; counter
        mov         r15, 0
        call        multiply_function   ; A = A * B
        mov         rdx, 24[answer256]
        mov         qword[num2 + 24], rdx
        mov         rdx, 16[answer256]
        mov         qword[num2 + 16], rdx
        mov         rdx, 8[answer256]
        mov         qword[num2 + 8], rdx
        mov         rdx, 0[answer256]
        mov         qword[num2], rdx 

        mov         r12, num2           ; r12 = source 1
        mov         r13, toBeAdded      ; r13 = source 2
        mov         r14, num2           ; r14 = destination
        call        add256Bytes         ; new input
        mov         rdx, 0
        mov         qword[backupNum + 24], rdx
        mov         qword[backupNum + 16], rdx 
        mov         qword[backupNum + 8], rdx 
        mov         qword[backupNum], rdx
        mov         qword[toBeAdded + 24], rdx
        mov         qword[toBeAdded + 16], rdx 
        mov         qword[toBeAdded + 8], rdx 
        mov         qword[toBeAdded], rdx  
        mov         qword[answer256 + 24], rdx
        mov         qword[answer256 + 16], rdx 
        mov         qword[answer256 + 8], rdx 
        mov         qword[answer256], rdx                      

        jmp         getNum2Start            ; go back to get the next char
    Num2IsNegative:
        mov         al, 1
        mov         [secondSign], al     ;if sign = 1 so it's -             
        jmp         getNum2Start

    detectOperator:
        mov         al, [operator]
        cmp         al, 42                     ; if operator = * 
        je          readyToMul
        cmp         al, 47                 ; if operator = / 
        je          readyToDiv        
        cmp         al, 37                 ; if operator = % 
        je          readyToMod   

    readyToMul:
        mov         rbx, num1           ; A
        mov         rax, num2           ; B
        mov         rdx, answer256      ; destination
        mov         rcx, 256            ; counter
        mov         r15, 0    
        call        multiply_function
        call        setAnswerSign
        mov         esi, answer
        mov         rbx, answer256
        jmp         printAnswerDiv
    readyToDiv:
        mov         rbx, num1           ; A
        mov         rax, num2           ; B
        call        division_function
        call        setAnswerSign
        mov         rdx, 0
        mov         qword[Remainder + 24], rdx
        mov         qword[Remainder + 16], rdx 
        mov         qword[Remainder + 8], rdx 
        mov         qword[Remainder], rdx 
        mov         rdx, 24[Quotient]
        mov         qword[answer256 + 24], rdx
        mov         rdx, 16[Quotient]
        mov         qword[answer256 + 16], rdx 
        mov         rdx, 8[Quotient]
        mov         qword[answer256 + 8], rdx 
        mov         rdx, 0[Quotient]
        mov         qword[answer256], rdx 
        mov         rdx, 0
        mov         qword[Quotient + 24], rdx
        mov         qword[Quotient + 16], rdx 
        mov         qword[Quotient + 8], rdx 
        mov         qword[Quotient], rdx                                  
        mov         rbx, answer256
        mov         esi, answer
        jmp        printAnswerDiv    

    readyToMod:
        mov         rbx, num1           ; A
        mov         rax, num2           ; B
        call        division_function
        call        setAnswerSign
        mov         rdx, 24[Remainder]
        mov         qword[answer256 + 24], rdx
        mov         rdx, 16[Remainder]
        mov         qword[answer256 + 16], rdx 
        mov         rdx, 8[Remainder]
        mov         qword[answer256 + 8], rdx 
        mov         rdx, 0[Remainder]
        mov         qword[answer256], rdx 

        mov         rdx, 0
        mov         qword[Remainder + 24], rdx
        mov         qword[Remainder + 16], rdx 
        mov         qword[Remainder + 8], rdx 
        mov         qword[Remainder], rdx 
        mov         qword[Quotient + 24], rdx
        mov         qword[Quotient + 16], rdx 
        mov         qword[Quotient + 8], rdx 
        mov         qword[Quotient], rdx                                                  
        mov         rbx, answer256
        mov         esi, answer
        jmp         printAnswerDiv 

    ; mov         esi, answer         ; pointer to answer
    ; mov         rbx, num2
    printAnswerDiv:
    ; rbx = points to the answer    r15 = 24
    mov     rax, backupNum
    mov     rdx, 10
    mov     qword[rax + 24], rdx
    call    division_function
    mov     rcx, 0[Remainder + 24]  ; the value we wanted
    add     ecx, '0'
    mov     [esi], ecx              ; mov into the array
    mov     cl, [length1]
    inc     cl
    mov     [length1], cl
    mov     rbx, Quotient           ; new value to be divided
    call    CanWeStillDivide
    mov     rdx, 0
    mov     rax, [dividable]
    cmp     rdx, rax
    je      finalPrintAndReturn
    mov     [dividable], rdx
    mov     rbx, 24[Quotient]      ; new answer
    mov     qword[answer256 + 24], rbx
    mov     rbx, 16[Quotient]
    mov     qword[answer256 + 16], rbx
    mov     rbx, 8[Quotient]
    mov     qword[answer256 + 8], rbx
    mov     rbx, 0[Quotient]
    mov     qword[answer256], rbx
   
    inc     esi                     ; next index of array
    mov     rbx, answer256          ; new N
    mov     rdx, 0
    mov     qword[backupNum + 24], rdx
    mov     qword[backupNum + 16], rdx 
    mov     qword[backupNum + 8], rdx 
    mov     qword[backupNum], rdx   
    jmp     printAnswerDiv
    finalPrintAndReturn:
    mov     al, [answerSign]
    cmp     al, 0
    je      print_Rest
    mov     al, '-'
    mov     [newline], al
    write_char  newline, 1    
    print_Rest:
    mov     ecx, [esi]
    mov     [newline], ecx
    write_char  newline, 1
    mov     cl,[length1]
    dec     cl
    mov     [length1], cl
    cmp     cl, 0
    je      endOfMulDiv
    dec    esi
    jmp     print_Rest
    endOfMulDiv:
       write_char  NewLine, 1
       jmp         main_Loop     

InitializeEverything:
    mov         rdx, 0
    mov         qword[toBeAdded + 24], rdx
    mov         qword[toBeAdded + 16], rdx 
    mov         qword[toBeAdded + 8], rdx 
    mov         qword[toBeAdded], rdx  
    mov         qword[answer256 + 24], rdx
    mov         qword[answer256 + 16], rdx 
    mov         qword[answer256 + 8], rdx 
    mov         qword[answer256], rdx     
    mov         qword[num1 + 24], rdx
    mov         qword[num1 + 16], rdx 
    mov         qword[num1 + 8], rdx 
    mov         qword[num1], rdx  
    mov         qword[num2 + 24], rdx
    mov         qword[num2 + 16], rdx 
    mov         qword[num2 + 8], rdx 
    mov         qword[num2], rdx 
    mov         qword[backupNum + 24], rdx
    mov         qword[backupNum + 16], rdx 
    mov         qword[backupNum + 8], rdx 
    mov         qword[backupNum], rdx     
    mov         qword[Remainder + 24], rdx
    mov         qword[Remainder + 16], rdx 
    mov         qword[Remainder + 8], rdx 
    mov         qword[Remainder], rdx  
    mov         qword[Quotient + 24], rdx
    mov         qword[Quotient + 16], rdx 
    mov         qword[Quotient + 8], rdx 
    mov         qword[Quotient], rdx 
    ret

CanWeStillDivide:
    mov     rdx, 0
    cmp     rdx, 0[rbx]
    jne     yesWeCan
    cmp     rdx, 8[rbx]
    jne     yesWeCan
    cmp     rdx, 16[rbx]
    jne     yesWeCan
    cmp     rdx, 24[rbx]
    jne     yesWeCan
    mov     rdx, 0
    mov     [dividable], rdx        ; we can't
    ret
    yesWeCan:   
    mov     rdx, 1
    mov     [dividable], rdx        ; we can
    ret

multiply_function:
    ; ########################################
    ; Assumption: A * B = Sigma [A << i] * bi
    ; rbx = A                   ; rdx =  answer         
    ; rax = B                   ; rcx = keeps track of the index  
    ; ########################################
    mulLoop:
        mov     r11, 24[rax]
        mov     r12, 1
        and     r12, r11
        cmp     r12, 0
        je      skipAddition
        mov     r12, rdx
        mov     r13, rbx
        mov     r14, rdx
        call    add256Bytes
    skipAddition:
        mov     r15, rcx
        mov     rcx, 1
        mov     r12, rbx
        call    shiftLeft256
        mov     r12, rax
        mov     rcx, 1
        call    shiftRight256
        mov     rcx, r15
        dec     rcx
        cmp     rcx, 0
        jg      mulLoop

    doneMul:
    ret


division_function:  

    ; ########################################
    ; rbx = A                       
    ; rax = B                   ; rcx = keeps track of the index  
    ; ########################################    
    mov     rdi, 63             ; bit index in every register
    mov     rcx, 255            ; main counter of the loop
    mov     r15, 0
    mov     r11, 0
    mov     qword[Remainder + 24], r11      ; resetting Remainder
    mov     qword[Remainder + 16], r11  
    mov     qword[Remainder + 8], r11  
    mov     qword[Remainder], r11           ; resetting Quotient
    mov     qword[Quotient + 24], r11  
    mov     qword[Quotient + 16], r11  
    mov     qword[Quotient + 8], r11 
    mov     qword[Quotient], r11 
    divLoop:
        mov     r12, Remainder      ; shift remainder one bit to the left
        mov     r11, rcx
        mov     rcx, 1
        call    shiftLeft256
        mov     rcx, r11
        mov     r11, 1
        mov     r12, rdi
        cmp     r12, 0
        je      endShiftLoop        
        shiftLoop: 
            shl     r11, 1          ; r11 = 1 in i index
            dec     r12
            cmp     r12, 0
            jg     shiftLoop
        endShiftLoop:    
        mov     r12, rbx
        and     r11, 0[r12 + r15]
        cmp     r11, 0
        jz      restOfDiv
        mov     r12, Remainder
        mov     r13, ONEONE
        mov     r14, Remainder
        call    add256Bytes         
    restOfDiv:    
        mov     r12, Remainder      ; if  Remainder < Division
        mov     r13, rax            ; continue
        call    compare256Byte      
        mov     r11, [BIGGERONEIS]
        cmp     r11, 2
        je      justContinue      
        mov     r12, Remainder  
        mov     r13, rax    
        mov     r14, Remainder
        call    subtract256Bytes    ; else :  R = R - D
        mov     r11, 1
        mov     r12, rdi
        cmp     r12, 0
        je      noLoadNeeded
        loadIntoQ:
            shl     r11, 1          ; r11 = 1 in index i
            dec     r12
            cmp     r12, 0
            jg      loadIntoQ
        noLoadNeeded:    
        mov     r12, Quotient
        mov     r10, 0[r12 + r15]
        or      r11, r10            ; Q(i) = 1
        mov     qword[r12 + r15], r11
    justContinue:
        dec     rcx                 ; rcx --
        dec     rdi                 ; shift rdi to right 1 bit
        cmp     rdi, 0
        jge     divLoop
        cmp     rcx, 0
        jl      doneDiv
        add     r15, 8              ; next Quarter
        mov     rdi, 63             ; MSB of new Quarter
        jmp     divLoop

    doneDiv:
    ret
add256Bytes:
    push    rax
    push    rbx
    push    rcx
    push    rdx
    push    r15
    push    r11
    sub     rsp, 24

    mov     r15, 24
    add     r12, r15            ; r12 = source one
    add     r13, r15            ; r13 = source two
    add     r14, r15            ; r14 = destination
    mov     r15, 8
    xor     rcx, rcx            ; counter of loop which exceeds 4
    xor     rdx, rdx            ; keeps possible carry
    addLoop:
        mov     r10, 0[r12]
        mov     r11, 0[r13]
        cmp     rdx, 0
        je      noCarryExists
        xor     rdx, rdx
        stc                     ; set carry flag
    noCarryExists:
        adc     r10, r11
        jnc     restOfAdd256
        mov     rdx, 1
    restOfAdd256:
        mov     qword[r14], r10
        inc     rcx
        sub     r12, 8
        sub     r13, 8
        sub     r14, 8
        cmp     rcx, 4
        jl      addLoop


    add     rsp, 24
    pop     r11
    pop     r15 
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
    
    ret


subtract256Bytes:
    push    rax
    push    rbx
    push    rcx
    push    rdx
    push    r15


    clc 
    mov     r15, 24
    add     r12, r15            ; r12 = source one
    add     r13, r15            ; r13 = source two
    add     r14, r15            ; r14 = destination = r12 - r13
    mov     r15, 8
    xor     rcx, rcx            ; counter of loop which exceeds 4
    xor     rdx, rdx            ; keeps possible borrow
    mov     r10, 0[r12]
    mov     r11, 0[r13]
    sub     r10, r11
    mov     qword[r14], r10
    sub     r12, 8
    sub     r13, 8
    sub     r14, 8
    subtractLoop:
        mov     r10, 0[r12]
        mov     r11, 0[r13]
        cmp     rdx, 0
        je      noBorrowExists
        xor     rdx, rdx
        stc                     ; set carry flag
    noBorrowExists:
        sbb     r10, r11
        jnc     restOfBorrow256
        mov     rdx, 1          ; there's a borrow
    restOfBorrow256:
        mov     qword[r14], r10
        inc     rcx
        sub     r12, 8
        sub     r13, 8
        sub     r14, 8
        cmp     rcx, 3
        jl      subtractLoop

    pop     r15 
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
    ret

shiftRight256:
    push    rax
    push    rbx
    push    rcx
    push    rdx
    push    r10
    push    r13
    sub     rsp, 24

    clc                                 ; clear carry flag for rcr
    mov     r10, 0[r12]                 ; r12 + 24 = last element of num
    rcr     r10, cl                      ; shift to right 1 bit and save the lsb into carry flag
    mov     qword[r12], r10             ; saving it into the variable

    mov     r10, 8[r12]                 ; doing the same process for the 3rd element
    rcr     r10, cl
    mov     qword[r12 + 8], r10

    mov     r10, 0[r12 + 16]            ; doing the same process for the 2nd element
    rcr     r10, cl
    mov     qword[r12 + 16], r10

    mov     r10, 0[r12 + 24]            ; doing the same process for the 1st element
    rcr     r10, cl
    mov     qword[r12 + 24], r10

    add     rsp, 24
    pop     r13
    pop     r10
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
    ret


shiftLeft256:
    push    rax
    push    rbx
    push    rcx
    push    rdx
    push    r10
    push    r13
    sub     rsp, 24
    
    clc                                 ; clear carry flag for rcr
    mov     r10, 0[r12 + 24]            ; r12 + 24 = last element of num
    rcl     r10, cl                      ; shift to right 1 bit and save the lsb into carry flag
    mov     qword[r12 + 24], r10        ; saving it into the variable

    mov     r10, 0[r12 + 16]            ; doing the same process for the 3rd element
    rcl     r10, cl
    mov     qword[r12 + 16], r10

    mov     r10, 0[r12 + 8]             ; doing the same process for the 2nd element
    rcl     r10, cl
    mov     qword[r12 + 8], r10

    mov     r10, 0[r12]                 ; doing the same process for the 1st element
    rcl     r10, cl
    mov     qword[r12], r10

    add     rsp, 24
    pop     r13
    pop     r10
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
    ret


compare256Byte:
    push    rax
    push    rbx
    push    rcx
    push    rdx
    push    r10
    push    r13
    sub     rsp, 24

    mov     r10, 0[r12]             ; r12 = Remainder
    mov     r11, 0[r13]             ; r13 = Dividend
    cmp     r10, r11                ; compares from MSB
    jg      first256Bigger
    jl      Second256Bigger
    mov     r10, 8[r12]
    mov     r11, 8[r13]
    cmp     r10, r11
    jg      first256Bigger
    jl      Second256Bigger
    mov     r10, 16[r12]
    mov     r11, 16[r13]
    cmp     r10, r11
    jg      first256Bigger
    jl      Second256Bigger
    mov     r10, 24[r12]
    mov     r11, 24[r13]
    cmp     r10, r11
    jg      first256Bigger
    jl      Second256Bigger 
    jmp     equalValues

    first256Bigger:
        mov     rax, 1
        mov     [BIGGERONEIS], rax
        jmp     doneCompare
    Second256Bigger:
        mov     rax, 2
        mov     [BIGGERONEIS], rax
        jmp     doneCompare
    equalValues:
        mov     rax, 0
        mov     [BIGGERONEIS], rax    
    doneCompare:


    add     rsp, 24
    pop     r13
    pop     r10
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
    ret        





print_int:
    sub rsp, 8

    mov rsi, rdi

    mov rdi, print_int_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call printf
    
    add rsp, 8 ; clearing local variables from stack

    ret


 