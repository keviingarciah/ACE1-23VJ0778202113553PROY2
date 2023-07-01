.MODEL SMALL
.RADIX 16
.STACK

; mueve el cursor a una posición
_MoveCursor MACRO xpos,ypos
    mov AH,02h  ; establecer la posición del cursor
    mov BH,00h  ; número de página, sólo utilizaremos la 0
    mov DH,ypos ; fila 
    mov DL,xpos ; columna
    int 10h
ENDM

_GetCursorPos MACRO
    mov AH,03h  ; get posicions del cursor; DH: row , DL: col
    mov BH,0h   ; en modo gráfico
    int 10h
ENDM

; Para imprimir una cadena de texto en una posición definida
_PrintTextAt MACRO xpos, ypos, stringbuffer, color
    push SI
    _MoveCursor xpos,ypos
    lea SI,stringbuffer 
    mov BL,color
    call PrintStr 
    pop SI
ENDM

_PutSprite MACRO sprite,col,row
    lea SI, sprite
    mov DH,col
    mov DL,row
    call RenderSprite
    
ENDM

_ClearBuffer MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    mov AL,0
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM

_ClearGameBuffer MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    mov AL,0FFh
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM

_ClearKBBuffer MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    add DI,02h
    mov AL,0
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM

_AtoiBuffer MACRO buffer_str, buffer_num
    push BX
    xor SI,SI
    xor AH,AH
    lea SI, buffer_str
    call atoi
    mov BH,00h
    mov [buffer_num],BL
    pop BX
ENDM

_itoaBuffer MACRO buffer1,buffer2
    xor AX,AX
    mov AX,[buffer1]
    mov BX,offset buffer2
    call itoa
    mov AX,[buffer1]
    call zeroPadding
    _addtoTMPbuffer buffer2,20h,0
    _clearBuffer buffer2,20h
    lea DI,buffer2
    _addtoTMPbuffer g_buffer,20h,0 
ENDM

_addtoTMPbuffer MACRO inp,len_inp,skip_inp
    xor CX,CX
    xor SI,SI
    mov SI,offset inp
    mov CX,len_inp
    add SI,skip_inp
    rep movsb 
ENDM

_PrintStr MACRO buffer
    mov SI, offset buffer
    call printstr
ENDM

_RenderPos MACRO thingX,thingY,skip
    xor SI,SI
    mov tmp_x,00h
    mov tmp_y,00h

    lea SI,thingX
    add SI,skip
    lodsb
    mov [tmp_x],AL
    cmp tmp_x,0FFh
    je FinishFloor

    xor SI,SI
    lea SI,thingY
    add SI,skip
    lodsb
    mov [tmp_y],AL
ENDM

.DATA
    ; constantes de colores 
    C_BLACK     EQU 00h
    C_WHITE     EQU 0Fh
    C_GRAY      EQU 08h
    C_DCYAN     EQU 03h
    C_LCYAN     EQU 0Bh
    C_LRED      EQU 0Ch
    C_DMAGE     EQU 05h
    C_LMAGE     EQU 23h


    ;posicion de la flecha
    POS_PLAY    EQU 08h
    POS_LOAD    EQU 0Ah
    POS_CONF    EQU 0Ch
    POS_HSCR    EQU 0Eh
    POS_EXIT    EQU 10h

    BOTTOM_LINE EQU 18h

    POS_CONT    EQU 0Ah
    POS_LEAV    EQU 0Eh

    ; teclas del menú
    F_1         EQU 3Bh
    UP_KEY      EQU 48h
    DOWN_KEY    EQU 50h

    F_2         EQU 3Ch

    ;
    DESP_U  EQU 01h
    DESP_D  EQU 02h 
    DESP_L  EQU 03h
    DESP_R  EQU 04h
    V_DESP  db 0

    start_game  db "INICIAR JUEGO",0
    load_level  db "CARGAR NIVEL",0
    config      db "CONFIGURACION",0
    hi_scores   db "PUNTAJES ALTOS",0
    salir       db "SALIR",0
    datos       db "Kevin Garcia - 202113553",0
    short_datos db "KEGH- 202113553",0
    empty       db " ",0

    youwon      db "GANASTE!",0
    continue    db "CONTINUAR",0
  
    arrow       db 10h,0

    ;controles por defecto: flechas (arriba,izquierda,derecha,abajo)
    key_up      db 48h
    key_down    db 50h
    key_right   db 4Dh
    key_left    db 4Bh

    ; archivos de nivel
    lvl1_name   db "NIV.00",0
    lvl2_name   db "NIV.01",0
    lvl3_name   db "NIV.10",0
    lvlA_name   db 20h dup (0),0
    lvlA_kbIn   db 21h,20h,22h dup (0),0
    lvlA_text   db "Escriba el nombre de archivo:",0
    lvl_handle  dw 0000
    g_counter   dw 0000
    g_counter2  dw 0000
    g_buffer    db 20h dup(0),0
    g_buffer2   db 20h dup(0),0

    ; 30 cajas - 30 objetivos (coordenadas en columnas y lineas)
    box_xpos    db 1Eh  dup (0FFh),0FFh
    box_ypos    db 1Eh  dup (0FFh),0FFh
    obj_xpos    db 1Eh  dup (0FFh),0FFh
    obj_ypos    db 1Eh  dup (0FFh),0FFh
    ; Suelo y paredes, ¿hasta 255 de cada?
    wal_xpos    db 0FFh dup (0FFh),0FFh
    wal_ypos    db 0FFh dup (0FFh),0FFh
    flo_xpos    db 0FFh dup (0FFh),0FFh
    flo_ypos    db 0FFh dup (0FFh),0FFh

    ; contador del número de objetos existentes de cada tipo
    n_box       db 0,0
    n_obj       db 0,0
    n_wal       db 0,0
    n_flo       db 0,0
    
    ; Posición del jugador
    ply_xpos    db 0
    ply_ypos    db 0
    ; guarda en que cosa se está parando el jugador, para redibujarla en caso de movimiento
    ply_over    db 0,0 ; 00h -> piso  01h -> objetivo

    ; varibles temporales para la asiganción de coordenadas
    tmp_x       db 0,0
    tmp_y       db 0,0
    tmp_xp      db 0
    tmp_yp      db 0

    tmp_xb      db 0
    tmp_yb      db 0
    
    tmp_char    db 0a dup (0),0

    curr_lvl    db 0 ; primer nivel
    curr_scr    dw 0000
    
    timer       db 0
    secs        db 0
    mins        db 0
    hrs         db 0
    secs2b      dw 0000
    mins2b      dw 0000
    hrs2b       dw 0000
    zeropad     db "0",0
    pad2        db "00",0
    pad3        db "000",0
    colon       db ":",0

.CODE
.STARTUP

Start:
    mov AX, @DATA
    mov DS,AX
    mov ES,AX

    mov AH,00h
    call InitVideo
    jmp Intro
    ;jmp MainMenu

Intro:
    _PrintTextAt 00h,BOTTOM_LINE,datos,0f
    mov AH,86h      ; wait CX:DX microsegundos 
    mov CX, 80h
    mov DX, 1E84h   ; 1E8480 -> 2 millones us (2 segundos)
    int 15h 

    call InitVideo  ; usandolo como clear screen xd
    jmp MainMenu

MainMenu:
    _PrintTextAt 0Ch,POS_PLAY,start_game,C_WHITE
    _PrintTextAt 0Ch,POS_LOAD,load_level,C_WHITE
    _PrintTextAt 0Ch,POS_CONF,config,C_WHITE
    _PrintTextAt 0Ch,POS_HSCR,hi_scores,C_WHITE
    _PrintTextAt 0Ch,POS_EXIT,salir,C_WHITE
    _PrintTextAt 00h,BOTTOM_LINE,datos,C_GRAY           ;imprimir datos en la última linea
    _PrintTextAt 0Ah,POS_PLAY,arrow,28
MenuLoop:
    jmp GetKeyMenu

; leer los teclazos en el menú
GetKeyMenu:
    mov AH,12h ;test Control/Shift (resultado en AX)
    int 16h
    mov BX,AX ; guardar AX

    mov AH,10h ; Leer teclado (espera input) en AX -> AH : Scan Code , AL : ASCII
    int 16h

CheckMenuKey:
    cmp AH,UP_KEY  ; flecha arriba
    je CheckArrowUpMenu
    cmp AH,DOWN_KEY  ; flecha abajo
    je CheckArrowDownMenu
    cmp AH,F_1
    je MenuSelected
    jmp MenuLoop

CheckArrowUpMenu:
    _GetCursorPos
    _PrintTextAt 0Ah,DH,empty,C_DCYAN
    cmp DH,POS_PLAY
    je MoveToPos5
    sub DH,02h
    _PrintTextAt 0Ah,DH,arrow,28
    jmp FinalCheckArrowUp
    MoveToPos5:
        _PrintTextAt 0Ah,DH,empty,C_DCYAN
        _PrintTextAt 0Ah,POS_EXIT,arrow,28
        jmp FinalCheckArrowUp
    FinalCheckArrowUp:
        jmp MenuLoop

CheckArrowDownMenu:
    _GetCursorPos
    _PrintTextAt 0Ah,DH,empty,C_DCYAN
    cmp DH,POS_EXIT
    je MoveToPos1
    add DH,02h
    _PrintTextAt 0Ah,DH,arrow,28
    jmp FinalCheckArrowDown
    MoveToPos1:
        _PrintTextAt 0Ah,DH,empty,C_DCYAN
        _PrintTextAt 0Ah,POS_PLAY,arrow,28
        jmp FinalCheckArrowUp
    FinalCheckArrowDown:
        jmp MenuLoop
        
MenuSelected:
    _GetCursorPos
    cmp DH,POS_PLAY
    je StartGame
    cmp DH,POS_LOAD
    je StartArbitraryGame
    cmp DH,POS_EXIT
    je Final
    jmp MenuLoop

StartGame:
    mov AH,00h  ; nivel 1
    mov curr_lvl,AH
    call ParseLevel 
    jmp GameLoop

StartArbitraryGame:
    call InitVideo
    _ClearKBBuffer lvlA_kbIn,20h
    _PrintTextAt 3h,8h,lvlA_text,C_GRAY
    _MoveCursor 3h,0Ah
    mov AH,0Ah
    mov DX,offset lvlA_kbIn
    int 21h

    lea SI, lvlA_kbIn
    add SI,02h
    lea DI, lvlA_name
    ; Remover retorno de carro/línea nueva del nombre del archivo
    RemoveCarriage:
        lodsb
        cmp AL,0d
        je ContinueArbi
        cmp AL,0a
        je ContinueArbi
        cmp AL,0h
        je ContinueArbi
        stosb
        jmp RemoveCarriage
    ContinueArbi:
    mov AH,03h  ; opción arbitraria
    call ParseLevel 
    jmp GameLoop

GameLoop:
    call GetTime
    mov ah,11h
    int 16h
    jz GameLoop ; si no se presiona nada
    ;call RenderTiles
    mov V_DESP,00h
    call PlayerSteppingOn
    mov AH,10h
    int 16h
    cmp AH,F_2
    je PauseMenu
    cmp AH,key_up
    jnz NotUP
    dec ply_ypos
    mov V_DESP,DESP_U
    jmp FinalPosition 
    NotUp: ; abajo?
        cmp AH,key_down
        jnz NotDown
        inc ply_ypos
        mov V_DESP,DESP_D
    NotDown:; izquierda?
        cmp AH,key_left
        jnz NotLeft
        dec ply_xpos
        mov V_DESP,DESP_L
    NotLeft:; derecha?
        cmp AH,key_right
        jnz FinalPosition
        inc ply_xpos
        mov V_DESP,DESP_R
    FinalPosition:    
        call CheckCollision 
        call UpdateScore
        call RenderPlayer

    jmp GameLoop

; SI:Sprite DH:posX (columna) DL:posY (linea) 
; Renderiza el sprite en una posición Columna,Fila (40x25)
RenderSprite:		
    push ES
    push DS
	mov AX,0A000h
	mov ES,AX
	mov AX,@CODE
	mov DS,AX
	
	push DX	
    mov AX,08h
    mul DH
    mov DI,AX
        
    mov AX,0A00h
    mov BX,00h
    add BL,DL
    mul BX
    add DI,AX

	pop DX
	
	mov CL,08h			;Altura 8px
DrawY:
	push DI
    mov CH,08h		    ;Longitud 8px
DrawX:				
    mov AL,DS:[SI]
    ;xor AL,ES:[DI]	;Si se imprime el mismo sprite en el mismo lugar, se "borra"
    mov ES:[DI],AL
    inc SI
    inc DI
    dec CH
    jnz DrawX ; Siguiente pixel horizontal 
	pop DI
	add DI,0140h			; Ir una línea hacia abajo (320px)
	inc BL
	dec CL
	jnz DrawY
    pop ES
    pop DS
	ret		

; -> AH  00 -> LV.00  01 -> LV.01 02 -> LV.10 03 -> Arbitrario (?)
ParseLevel:
    call ClearLevelAssets 
    cmp AH,00h
    je LvlOne
    cmp AH,01h
    je LvlTwo
    cmp AH,02h
    je LvlThree
    cmp AH,03h
    je LvlArb
 
    LvlOne:    
        mov DX, offset lvl1_name
        jmp LoadFile

    LvlTwo:
        mov DX, offset lvl2_name
        jmp LoadFile

    LvlThree:
        mov DX, offset lvl3_name
        jmp LoadFile

    LvlArb:
        lea DX, lvlA_name
        jmp LoadFile

    LoadFile:
        mov AL, 2
        mov AH, 3Dh
        int 21h
        mov [lvl_handle], AX
        mov BX,[lvl_handle]
        jc MainMenu ; el archivo a abrir no fue encontrado
        call InitVideo
    ReadChar:
        _ClearBuffer tmp_char,0a
        mov AH,3Fh
        mov CX,01h
        mov DX,offset tmp_char
        int 21h
        jc FinishedReading  ; carry flag si hay error, no parece funcionar como yo esperaba xd
        cmp AX,0000h      ; si no lee nada
        je FinishedReading

        call SkipSpace
        cmp tmp_char,'c' ; c aja
        je ReadBox
        cmp tmp_char,'j' ; j ugador
        je ReadPlayer
        cmp tmp_char,'p' ; p ared
        je ReadWall
        cmp tmp_char,'o' ; o bjetivo
        je ReadObjective
        cmp tmp_char,'s' ; s uelo
        je ReadFloor
        ret
    ;; Suponiendo que el archivo no contendrá errores sintácticos/léxicos
    ReadBox:
        mov AH,42h
        mov AL,01h
        mov DX,0003h ; saltarse la palabra (c) aja
        mov CX,0000h 
        int 21h

        call ReadXY

        cmp n_box,1Eh 
        je ObjError
        
        push SI
        push DI

        lea SI,box_xpos
        lea DI, tmp_x
        call AppendToArray

        lea SI,box_ypos
        lea DI, tmp_y
        call AppendToArray

        inc n_box

        pop SI
        pop DI
        jmp ReadChar
    ReadPlayer:
        mov AH,42h
        mov AL,01h
        mov DX,0006h ; saltarse la palabra (j) ugador
        mov CX,0000h 
        int 21h

        call ReadXY

        mov AL,[tmp_x] 
        mov AH,[tmp_y] 
        mov [ply_xpos],AL
        mov [ply_ypos],AH
        jmp ReadChar
    ReadWall:
        mov AH,42h
        mov AL,01h
        mov DX,0004h ; saltarse la palabra (p) ared
        mov CX,0000h 
        int 21h

        call ReadXY

        cmp n_wal,0FFh 
        je ObjError
        
        push SI
        push DI

        lea SI,wal_xpos
        lea DI, tmp_x
        call AppendToArray

        lea SI,wal_ypos
        lea DI, tmp_y
        call AppendToArray

        pop SI
        pop DI
        jmp ReadChar
    ReadObjective:
        mov AH,42h
        mov AL,01h
        mov DX,0007h ; saltarse la palabra (o) bjetivo
        mov CX,0000h 
        int 21h

        call ReadXY

        cmp n_obj,1Eh 
        je ObjError
        
        push SI
        push DI

        lea SI,obj_xpos
        lea DI, tmp_x
        call AppendToArray

        lea SI,obj_ypos
        lea DI, tmp_y
        call AppendToArray

        pop SI
        pop DI
        jmp ReadChar
    ReadFloor:
        mov AH,42h
        mov AL,01h
        mov DX,0004h ; saltarse la palabra (s) uelo
        mov CX,0000h 
        int 21h

        call ReadXY

        cmp n_flo,0FFh 
        je ObjError
        
        push SI
        push DI

        lea SI,flo_xpos
        lea DI, tmp_x
        call AppendToArray

        lea SI,flo_ypos
        lea DI, tmp_y
        call AppendToArray

        pop SI
        pop DI
        jmp ReadChar

    ObjError:
        ret

    FinishedReading:
        call RenderTiles
        ret

RenderTiles:
    call InitVideo  ; usandolo como clearsecreen
    call RenderWalls
    call RenderFloor
    call RenderObjectives
    call RenderBoxes
    call RenderPlayer
    _PrintTextAt 00h,BOTTOM_LINE,short_datos,C_GRAY 
    ret

RenderFloor:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderFloorTile:
    ; flo_xpos , flo_ypos

    _RenderPos flo_xpos,flo_ypos,g_counter

    xor AX,AX
    xor SI,SI
    lea SI,floor
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    inc g_counter
    jmp RenderFloorTile
    FinishFloor:
        mov g_counter,0000h
        ret

RenderWalls:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderWallTile:
    ; wal_xpos , wal_ypos

    _RenderPos wal_xpos,wal_ypos,g_counter
    
    xor AX,AX
    xor SI,SI
    lea SI,wall
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    add g_counter,0001h
    jmp RenderWallTile
    FinishWalls:
        mov g_counter,0000h
        ret

RenderBoxes:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderBoxTile:
    ; wal_xpos , wal_ypos

    _RenderPos box_xpos,box_ypos,g_counter
    
    xor AX,AX
    xor SI,SI
    lea SI,box
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    add g_counter,0001h
    jmp RenderBoxTile
    FinishBoxes:
        mov g_counter,0000h
        ret

RenderObjectives:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderObjTile:
    ; wal_xpos , wal_ypos

    _RenderPos obj_xpos,obj_ypos,g_counter
    
    xor AX,AX
    xor SI,SI
    lea SI,target
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    add g_counter,0001h
    jmp RenderObjTile
    FinishObjs:
        mov g_counter,0000h
        ret

RenderPlayer:
    lea SI,player
    mov DH,[ply_xpos]
    mov DL,[ply_ypos]
    mov tmp_xp,DH
    mov tmp_yp,DL
    call RenderSprite
    ret
 

CheckCollision: 
    call FindWall
    call BoxHitbox
    call CheckWinState
    ret

; Verifica si hay una pared, impidiendo el moviento o no dado el caso
FindWall:
    mov g_counter,0000h
    lea SI,wal_xpos
    FindXWall:
        lodsb
        cmp AL,ply_xpos
        je FindYWall
        cmp AL,0FFh
        je AbleMoveWall
        inc g_counter
        jmp FindXWall
    FindYWall:
        push SI
        xor SI,SI
        lea SI,wal_ypos
        add SI,g_counter
        lodsb
        cmp AL,ply_ypos
        je CantMoveToWall
        pop SI
        inc g_counter
        jmp FindXWall
    CantMoveToWall:
        pop SI
        xor AX,AX
        mov AH,tmp_xp
        mov AL,tmp_yp
        mov ply_xpos,AH
        mov ply_ypos,AL
    AbleMoveWall:
        ret
        
    ret

; revisar los movimientos de la caja
BoxHitbox: 
    ; verificar si el jugador toca una caja con un potencial movimiento
    ; ply_xpos , ply_ypos
    FindBox:
    mov g_counter,0000h
    lea SI,box_xpos
    FindXBox:
        lodsb
        cmp AL,ply_xpos
        je FindYBox
        cmp AL,0FFh
        je NotFoundBox
        inc g_counter
        jmp FindXBox
    FindYBox:
        push SI
        xor SI,SI
        lea SI,box_ypos
        add SI,g_counter
        lodsb
        cmp AL,ply_ypos
        je FoundBox
        pop SI
        inc g_counter
        jmp FindXBox
    NotFoundBox:
        ret
    FoundBox:
        pop SI
        lea SI,box_xpos
        add SI,g_counter
        lodsb
        mov tmp_xb,AL
        lea SI,box_ypos
        add SI,g_counter
        lodsb

        ; verificar la dirección del movimiento
        mov tmp_yb,AL
        cmp V_DESP,DESP_U
        je CheckMoveUp
        cmp V_DESP,DESP_D
        je CheckMoveDown
        cmp V_DESP,DESP_L
        je CheckMoveLeft
        cmp V_DESP,DESP_R
        je CheckMoveRight
        ret
    ; suma o resta respectiva de acuerdo a la dirección del movimiento
    CheckMoveUp: ; movimiento hacia arriba
        dec tmp_yb
        jmp CheckBoxMoves
    CheckMoveDown: ; movimiento hacia abajo
        inc tmp_yb
        jmp CheckBoxMoves
    CheckMoveLeft: ; movimiento hacia la izquierda
        dec tmp_xb
        jmp CheckBoxMoves
    CheckMoveRight: ; movimiento hacia la derecha
        inc tmp_xb
        jmp CheckBoxMoves
    ; verificación de la validez de los movimientos
    CheckBoxMoves:
        call FindBoxNextAt
        cmp AH,01h
        je DoNotMoveBox
        call FindWallNextAt
        cmp AH,01h
        je DoNotMoveBox

        ; el movimiento es válido

        ;modificar el valor de la posición X de la caja
        lea BX,box_xpos
        add BX,g_counter
        mov AH,tmp_xb
        mov [BX],AH

        ;modificar el valor de la posición Y de la caja
        lea BX,box_ypos
        add BX,g_counter
        mov AH,tmp_yb
        mov [BX],AH
        
        ; renderiza caja en su nueva posición
        mov DH,tmp_xb
        mov DL,tmp_yb
        lea SI,box
        call RenderSprite

        ret
    DoNotMoveBox:
        ; el movimiento no es válido, resetear la posición del jugador
        pop SI
        xor AX,AX
        mov AH,tmp_xp
        mov AL,tmp_yp
        mov ply_xpos,AH
        mov ply_ypos,AL
        ret

; revisa si hay una caja bloqueando o no algún movimiento (sólo se puede mover una caja, no múltiples en fila)
; tmp_xb , tmp_yb posiciones potenciales de la caja
; -> AH : 01h no puede moverse,  00h puede moverse
FindBoxNextAt:
    mov g_counter2,0000h
    lea SI,box_xpos
    FindXBoxAt:
        lodsb
        cmp AL,tmp_xb
        je FindYBoxAt
        cmp AL,0FFh
        je NotFoundBoxAt
        inc g_counter2
        jmp FindXBoxAt
    FindYBoxAt:
        push SI
        xor SI,SI
        lea SI,box_ypos
        add SI,g_counter2
        lodsb
        cmp AL,tmp_yb
        je FoundBoxAt
        pop SI
        inc g_counter2
        jmp FindXBoxAt
    NotFoundBoxAt:
        mov AH,00h
        ret
    FoundBoxAt:
        pop SI
        mov AH,01h
        ret

; Se asegura de que una caja no pueda atravesar una pared
; tmp_xb , tmp_yb posiciones potenciales de la caja
; -> AH : 01h no puede moverse,  00h puede moverse
FindWallNextAt:
    mov g_counter2,0000h
    lea SI,wal_xpos
    FindXWallAt:
        lodsb
        cmp AL,tmp_xb
        je FindYWallAt
        cmp AL,0FFh
        je AbleMoveWallAt
        inc g_counter2
        jmp FindXWallAt
    FindYWallAt:
        push SI
        xor SI,SI
        lea SI,wal_ypos
        add SI,g_counter2
        lodsb
        cmp AL,tmp_yb
        je CantMoveToWallAt
        pop SI
        inc g_counter2
        jmp FindXWallAt
    CantMoveToWallAt:
        pop SI
        mov AH,01h
        ret
    AbleMoveWallAt:
        mov AH,00h
        ret

; compara las posiciones de las cajas con la de los objetivos, para determinar la victoria
CheckWinState:
    mov g_counter,0000h
    WinStateLoop:
        lea SI,box_xpos
        add SI,g_counter
        lodsb
        mov tmp_xb,AL

        cmp tmp_xb,0FFh ; si llega al final del arreglo, ganó
        je Won

        lea SI,box_ypos
        add SI,g_counter
        lodsb
        mov tmp_yb,AL

        mov g_counter2,0000h
        FindXWinState:
            lea SI,obj_xpos
            add SI,g_counter2
            lodsb
            cmp tmp_xb,AL
            je FindYWinState
            cmp AL,0FFh
            je NotWinYet
            inc g_counter2
            jmp FindXWinState
        FindYWinState:
            lea SI,obj_ypos
            add SI,g_counter2
            lodsb
            cmp tmp_yb,AL
            je FoundOne
            inc g_counter2
            jmp FindXWinState
        FoundOne:
            inc g_counter
            jmp WinStateLoop

    NotWinYet:
        ret

    Won:
        jmp YouWin

YouWin:
    ;_PrintTextAt 10h,0Bh,youwon,C_WHITE      
    cmp curr_lvl,02h
    jb GoToNextLevel
    mov curr_lvl,00h
    call InitVideo
    jmp MainMenu
    GoToNextLevel:
        inc curr_lvl
        mov AH,curr_lvl
        call ParseLevel
        ret

UpdateScore:
    mov AH,tmp_xp
    cmp AH,ply_xpos
    je CompareY
    inc curr_scr 
    jmp RenderScore
    CompareY:
        mov AL,tmp_yp
        cmp AL,ply_ypos
        je RenderScore
        inc curr_scr
    RenderScore:
        cmp curr_scr,0064h
        jb TriplePad
        cmp curr_scr,03E8h
        jb DoublePad
        cmp curr_scr,2710h
        jb SinglePad
        ;no pad
        _itoaBuffer curr_scr,g_buffer2
        _PrintTextAt 22h,00h,g_buffer2,C_WHITE
        ret
        TriplePad:
            _PrintTextAt 22h,00h,pad3,C_WHITE
            _itoaBuffer curr_scr,g_buffer2
            _PrintTextAt 25h,00h,g_buffer2,C_WHITE
            ret
        DoublePad:
            _PrintTextAt 22h,00h,pad2,C_WHITE
            _itoaBuffer curr_scr,g_buffer2
            _PrintTextAt 24h,00h,g_buffer2,C_WHITE
            _PrintTextAt 27h,00h,empty,C_WHITE
            ret
        SinglePad:
            _PrintTextAt 22h,00h,zeropad,C_WHITE
            _itoaBuffer curr_scr,g_buffer2
            _PrintTextAt 23h,00h,g_buffer2,C_WHITE
            ret
    ret

; re-renderizar el bloque de suelo u objetivo sobre el que se estaba parando el jugador
PlayerSteppingOn:
    mov g_counter,0000h
    lea SI,obj_xpos
    FindXStepping:
        lodsb
        cmp AL,tmp_xp
        je FindYStepping
        cmp AL,0FFh
        je SteppingFloor
        inc g_counter
        jmp FindXStepping
    FindYStepping:
        push SI
        xor SI,SI
        lea SI,obj_ypos
        add SI,g_counter
        lodsb
        cmp AL,tmp_yp
        je SteppingObj
        pop SI
        inc g_counter
        jmp FindXStepping

    SteppingObj:
        pop SI
        xor AX,AX
        lea SI, target
        mov DH,tmp_xp
        mov DL,tmp_yp
        call RenderSprite
        ret
    SteppingFloor:
        lea SI, floor
        mov DH,tmp_xp
        mov DL,tmp_yp
        call RenderSprite
        ret
        
    ret

PauseMenu:
    call InitVideo
    _PrintTextAt 0Ch,POS_CONT,continue,C_WHITE
    _PrintTextAt 0Ch,POS_LEAV,salir,C_WHITE
    _PrintTextAt 0Ah,POS_CONT,arrow,28
    jmp GetPauseKey

GetPauseKey:
    mov AH,12h ;test Control/Shift (resultado en AX)
    int 16h
    mov BX,AX ; guardar AX

    mov AH,10h ; Leer teclado (espera input) en AX -> AH : Scan Code , AL : ASCII
    int 16h

CheckPauseKey:
    cmp AH,UP_KEY  ; flecha arriba
    je CheckArrowPause
    cmp AH,DOWN_KEY  ; flecha abajo
    je CheckArrowPause
    cmp AH,F_1
    je PauseSelected
    jmp GetPauseKey

CheckArrowPause:
    _GetCursorPos
    _PrintTextAt 0Ah,DH,empty,C_DCYAN
    cmp DH,POS_LOAD
    je MoveToLeave
    _PrintTextAt 0Ah,POS_LEAV,empty,C_DCYAN
    _PrintTextAt 0Ah,POS_CONT,arrow,28
    jmp FinalCheckArrowPause
    MoveToLeave:
        _PrintTextAt 0Ah,POS_CONT,empty,C_DCYAN
        _PrintTextAt 0Ah,POS_LEAV,arrow,28
        jmp FinalCheckArrowPause
    FinalCheckArrowPause:
        jmp GetPauseKey
 
PauseSelected:
    _GetCursorPos
    cmp DH,POS_CONT
    je RenderAndContinue
    cmp DH,POS_LEAV
    je ClearAndLeave
    jmp CheckPauseKey
    RenderAndContinue:
        call RenderTiles
        jmp GameLoop
    ClearAndLeave:
        call InitVideo
        jmp MainMenu

; tmp_char : caracter a comparar
SkipSpace:
    CompareSpace:
        cmp tmp_char, 0a
        je DoSkip
        cmp tmp_char,' '
        jne FinishSkipSpace
    DoSkip:
        mov AH,3Fh
        mov CX,01h
        mov DX,offset tmp_char
        int 21h

        jc FinishedReading  ; carry flag si hay error, no parece funcionar como yo esperaba xd
        cmp AX,0000h      ; si no lee nada
        je FinishedReading

        jmp CompareSpace
    FinishSkipSpace:
        ret

; BX : handle del archivo
; -> tmp_x : X tmp_y : Y
; Leer coordenadas X,Y del archivo
ReadXY:
    _ClearBuffer tmp_char,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    int 21h
    
    call SkipSpace

    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    inc DX  ; el último caracter es un número
    int 21h
    
    _AtoiBuffer tmp_char,tmp_x


    _ClearBuffer tmp_char,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    int 21h
    
    call SkipSpace
    ; saltar la coma
    mov AH,42h
    mov AL,01h
    mov DX,0001h
    mov CX,0000h 
    int 21h

    _ClearBuffer tmp_char,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    int 21h

    call SkipSpace

    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    inc DX  ; el último caracter es un número
    int 21h
    _AtoiBuffer tmp_char,tmp_y
    inc tmp_y
    _ClearBuffer tmp_char,0a
    ret

; SI: información a adjuntar
; DI: buffer al que se adjunta
; Agrega la información de SI en desde el primer 255 que encuentre
AppendToArray:
    push DI 
    push SI

    mov DI,SI   ; lodsb usa SI para cargar el caracter...
    mov AH,00h  ;contador de posiciones
    FindZero:   ; encontrar la posición del 255
        lodsb
        cmp AL,0FFh      ;  comparar si el caracter cargado en AL es FF (255)
        je FoundZero
        inc AH          ; incrementa condator
        jmp FindZero
    FoundZero:
        pop DI
        pop SI
        mov AL,AH   ; mover parta alta a parte baja 
        mov AH,00h  ; limpiar parte alta

        add DI,AX   ; 00NNh
        movsb       ; no se usa rep porque los datos que se agregan son de un byte, es innecesario
        ret


; SI : cadena de texto a imprimir
; BL : color del texto
; Imprime la cadena de texto en la posición del cursor
PrintStr:
    getChar: 
        lodsb       ; carga un caracter en AL
        cmp AL,0    
        je finishedPrint ; si llega a un caracter NUL, termina
        
        mov AH,0Eh  ; imprime el caracter en AL en la posición del cursor
        mov BH,00h  ; página 0
        int 10h

        jmp getChar
    finishedPrint:
        ret

; cadena de texto a número
; SI: Cadena de texto 
; -> BX: número 
atoi:
    xor BX,BX
    atoi_1:
        lodsb   

        cmp AL,'0'
        jb noascii
        cmp AL,'9'
        ja noascii

        sub AL,30h
        cbw
        push AX
        mov AX,BX
        jc of
        mov CX,0Ah
        mul CX
        jc of
        mov BX,AX
        pop AX
        add BX,AX
        jc of
        jmp atoi_1
    noascii:
        ret 
    of:
        pop AX      ; NO hacer pop a esto hace que el programa se haga popó xd
        mov AH,01h
        ret

; Número a cadena de texto
; AX: Número BX: Offset de donde se colocará la cadena 
itoa: 
    xor CX,CX  ;CX = 0
    itoa_1:
        cmp AX,0
        je itoa_2            
        xor DX,DX
        push BX
        mov BX,0Ah
        div BX
        pop BX
        push DX
        inc CX
        jmp itoa_1

    itoa_2:
        cmp CX,0
        ja itoa_3
        mov AX,'0'
        mov [BX],AX
        inc BX
        jmp itoa_4

    itoa_3:
        pop AX
        add AX,30h
        mov [BX],AX
        inc BX
        loop itoa_3
    itoa_4:
        mov AX,0
        mov [BX],AX
        ret

; Modo de vídeo 13h 320x200
InitVideo:
    mov AH, 00h
    mov AL, 13h
    int 10h
    ret

; Regresar al modo de texto 03h
RestoreVideo:
    mov AH,00h
    mov AL,03h
    int 10h
    ret

; limpia todaa las posiciones de cajas, objetivos, paredes y del jugador
ClearLevelAssets:
    _ClearGameBuffer box_xpos,1Eh
    _ClearGameBuffer box_ypos,1Eh
    _ClearGameBuffer obj_xpos,1Eh
    _ClearGameBuffer obj_ypos,1Eh
    _ClearGameBuffer wal_xpos,0FFh
    _ClearGameBuffer wal_ypos,0FFh
    _ClearGameBuffer flo_xpos,0FFh
    _ClearGameBuffer flo_ypos,0FFh
    mov ply_xpos,00h
    mov ply_ypos,00h
    mov n_obj,00h
    mov n_box,00h
    mov n_wal,00h
    mov n_flo,00h
    mov secs,00h
    mov mins,00h
    mov hrs,00h
    mov timer,00h
    mov curr_scr,0000h
    ret

GetTime:
    mov AH,2Ch
    int 21h
    cmp DH,timer
    jne UpdateTimer
    ret
    UpdateTimer:
        mov timer,DH
        inc secs
        cmp secs,3Ch ; comparar con 60
        jge UpdateMinutes
        jmp PrintNewHour
    UpdateMinutes:
        mov secs,00h
        inc mins
        cmp mins,3Ch
        jge UpdateHrs
        jmp PrintNewHour
    UpdateHrs:
        mov mins,00h
        inc hrs     ; ya mucho engase si esto se pasa de 24 xd
    PrintNewHour:
        mov AL,secs
        cbw
        mov secs2b,AX
        mov AL,mins
        cbw
        mov mins2b,AX
        mov AL,hrs
        cbw
        mov hrs2b,AX
        _PrintTextAt 24h,BOTTOM_LINE,colon,C_WHITE

        _itoaBuffer secs2b,g_buffer2
        _PrintTextAt 25h,BOTTOM_LINE,g_buffer2,C_WHITE

        _PrintTextAt 21h,BOTTOM_LINE,colon,C_WHITE

        _itoaBuffer mins2b,g_buffer2
        _PrintTextAt 22h,BOTTOM_LINE,g_buffer2,C_WHITE
        

        _itoaBuffer hrs2b,g_buffer2
        _PrintTextAt 1Fh,BOTTOM_LINE,g_buffer2,C_WHITE
        ret

; numero AX; padding con un 0 si el numero es menor a 10
zeroPadding:
    cmp AX,0Ah
    jb addZeroPadding
    _clearBuffer g_buffer,20h
    lea DI,g_buffer 
    ret
addZeroPadding: 
    _clearBuffer g_buffer,20h
    lea DI,g_buffer 
    _addtoTMPbuffer zeropad,01h,0 
    ret

TextModePrintstr:
    TMgetchar:
        lodsb
        cmp AL,0a
        je nline 
        cmp AL,0
        je TMfinished
        mov AH, 0Eh
        int 10h
        jmp TMgetchar
    
    nline:              ;convertir un \n en \r\n
        mov AL, 0d
        mov AH, 0Eh
        int 10h
        mov AL, 0a
        mov AH, 0Eh
        int 10h
        jmp TMgetchar

    TMfinished:
        ret

Final:
;    call RestoreVideo
    .EXIT

;;;;;;; Sprites 8x8 ;;;;;;;;;

wall:    
    db 12,12,0f,0f,0f,0f,0f,12
    db 0f,12,12,18,17,17,17,12
    db 0f,0f,12,12,18,17,17,12
    db 0f,17,0f,12,12,18,17,12
    db 0f,17,17,0f,12,12,18,12
    db 12,17,17,17,0f,12,12,12
    db 12,12,17,17,17,0f,12,12
    db 12,12,12,12,12,12,12,12

box:
    db 18,15,18,18,18,18,15,18
    db 15,18,15,15,15,15,18,15
    db 18,15,18,15,15,18,15,18
    db 18,15,15,18,18,15,15,18
    db 18,15,15,18,18,15,15,18
    db 18,15,18,15,15,18,15,18
    db 15,18,15,15,15,15,18,15
    db 18,15,18,18,18,18,15,18

floor:
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c

target:
    db 1c,1c,28,28,28,28,1c,1c
    db 1c,28,1c,1c,1c,1c,28,1c
    db 28,1c,28,1c,1c,28,1c,28
    db 28,1c,1c,28,28,1c,1c,28
    db 28,1c,1c,28,28,1c,1c,28
    db 28,1c,28,1c,1c,28,1c,28
    db 1c,28,1c,1c,1c,1c,28,1c
    db 1c,1c,28,28,28,28,1c,1c

player:
    db 1c,14,14,14,14,14,14,1c
    db 14,4c,00,4c,4c,00,4c,14
    db 14,4c,4c,00,00,4c,4c,14
    db 1c,14,14,14,14,14,14,1c
    db 1c,1c,14,14,14,14,1c,1c
    db 1c,1c,00,14,14,00,1c,1c
    db 1c,1c,1c,14,14,1c,1c,1c
    db 1c,00,14,14,14,14,00,1c 
    
;;;;;;;;;;;;;;;;;;;;;;;;

END
