.MODEL SMALL
.RADIX 16
.STACK

MoverPuntero MACRO xpos,ypos
    mov AH,02h  
    mov BH,00h  
    mov DH,ypos 
    mov DL,xpos 
    int 10h
ENDM

TomarPosicionCursor MACRO
    mov AH,03h  
    mov BH,0h   
    int 10h
ENDM

ImprimirTextoEspecifico MACRO xpos, ypos, stringbuffer, color
    push SI
    MoverPuntero xpos,ypos
    lea SI,stringbuffer 
    mov BL,color
    call Imprimir_Str 
    pop SI
ENDM

PonerSprite MACRO sprite,col,row
    lea SI, sprite
    mov DH,col
    mov DL,row
    call Renderizar_sprite
    
ENDM

LimpiarBuffer MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    mov AL,0
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM

LimpiarBufferJuego MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    mov AL,0FFh
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM

LimpiarBufferKB MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    add DI,02h
    mov AL,0
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM

BufferAtoi MACRO buffer_str, buffer_num
    push BX
    xor SI,SI
    xor AH,AH
    lea SI, buffer_str
    call atoi
    mov BH,00h
    mov [buffer_num],BL
    pop BX
ENDM

BufferItoa MACRO buffer1,buffer2
    xor AX,AX
    mov AX,[buffer1]
    mov BX,offset buffer2
    call itoa
    mov AX,[buffer1]
    call padCeroding
    AnadirBufferTMP buffer2,20h,0
    LimpiarBuffer buffer2,20h
    lea DI,buffer2
    AnadirBufferTMP buffer_g,20h,0 
ENDM

AnadirBufferTMP MACRO inp,len_inp,skip_inp
    xor CX,CX
    xor SI,SI
    mov SI,offset inp
    mov CX,len_inp
    add SI,skip_inp
    rep movsb 
ENDM

ImprimirString MACRO buffer
    mov SI, offset buffer
    call Imprimir_Str
ENDM

RenderizarPos MACRO thingX,thingY,skip
    xor SI,SI
    mov x_temportal,00h
    mov y_temporal,00h

    lea SI,thingX
    add SI,skip
    lodsb
    mov [x_temportal],AL
    cmp x_temportal,0FFh
    je Finalizar_suelo

    xor SI,SI
    lea SI,thingY
    add SI,skip
    lodsb
    mov [y_temporal],AL
ENDM

.DATA
    COLOR_BLANCO        EQU 0Fh
    COLOR_GRIS          EQU 08h
    COLOR_ROJO          EQU 28h
    COLOR_VERDE         EQU 1Fh

    POS_INICIAR         EQU 08h
    POS_CARGAR          EQU 0Ah
    POS_CONF            EQU 0Ch
    POS_PUNTOS          EQU 0Eh
    POS_SALIR           EQU 10h

    LINEA_BOTON         EQU 18h

    POS_CONTADOR        EQU 0Ah
    POS_LEAV            EQU 0Eh

    TECLA_F1            EQU 3Bh
    CLAVE_ARRIBA        EQU 48h
    CLAVE_ABAJO         EQU 50h

    TECLA_F2            EQU 3Ch

    DESP_U  EQU 01h
    DESP_D  EQU 02h 
    DESP_L  EQU 03h
    DESP_R  EQU 04h
    V_DESP  db 0
    
    iniciar_juego       db "NUEVO JUEGO",0
    cargar_nivel        db "CARGAR NIVEL",0
    config              db "CONFIGURACION",0
    puntajes            db "TABLA DE PUNTUACIONES",0
    salir               db "SALIR",0
    datos               db "Kevin Garcia - 202113553",0
    datos_pantalla      db "KEGH - 202113553",0
    vacio               db " ",0

    msg_continuar       db "CONTINUAR",0
  
    arrow               db 10h,0

    tecla_arriba        db 48h
    tecla_abajo         db 50h
    tecla_derecha       db 4Dh
    tecla_izquierda     db 4Bh

    nombre_nivel1   db "NIV.00",0
    nombre_nivel2   db "NIV.01",0
    nombre_nivel3   db "NIV.10",0
    nombre_nivelA   db 20h dup (0),0
    KbIn_nivel      db 21h,20h,22h dup (0),0
    prompt_nivel    db "Escriba el nombre de archivo:",0
    handle_nivel    dw 0000
    counter_g       dw 0000
    counter_g2      dw 0000
    buffer_g        db 20h dup(0),0
    buffer_g2       db 20h dup(0),0

    posx_caja       db 1Eh  dup (0FFh),0FFh
    posy_caja       db 1Eh  dup (0FFh),0FFh
    posx_obj        db 1Eh  dup (0FFh),0FFh
    posy_obj        db 1Eh  dup (0FFh),0FFh

    posx_pared      db 0FFh dup (0FFh),0FFh
    posy_pared      db 0FFh dup (0FFh),0FFh
    posx_suelo      db 0FFh dup (0FFh),0FFh
    posy_suelo      db 0FFh dup (0FFh),0FFh

    cont_cajas      db 0,0
    cont_obj        db 0,0
    cont_pared      db 0,0
    cont_suelo      db 0,0
    
    posx_jugador    db 0
    posy_jugador    db 0

    over_jugador    db 0,0

    x_temportal         db 0,0
    y_temporal          db 0,0
    x_temportalP        db 0
    y_temporalP         db 0

    x_temportalB        db 0
    y_temporalB         db 0
    
    char_temporal       db 0a dup (0),0

    curr_nivel      db 0
    curr_scr        dw 0000
    
    timer           db 0
    segundos        db 0
    minutos         db 0
    horas           db 0
    segundos2b      dw 0000
    minutos2b       dw 0000
    horas2b         dw 0000
    padCero         db "0",0
    pad2            db "00",0
    pad3            db "000",0
    puntos          db ":",0

.CODE
.STARTUP

Comienzo:
    mov AX, @DATA
    mov DS,AX
    mov ES,AX

    mov AH,00h
    call Iniciar_video

    jmp menu_principal

Inicio:
    ImprimirTextoEspecifico 00h,LINEA_BOTON,datos,COLOR_GRIS
    mov AH,86h 
    mov CX, 80h
    mov DX, 1E84h
    int 15h 

    call Iniciar_video                               
    jmp menu_principal

menu_principal:
    ImprimirTextoEspecifico 0Ch,POS_INICIAR,iniciar_juego, COLOR_BLANCO
    ImprimirTextoEspecifico 0Ch,POS_CARGAR,cargar_nivel,COLOR_BLANCO
    ImprimirTextoEspecifico 0Ch,POS_CONF,config,COLOR_BLANCO
    ImprimirTextoEspecifico 0Ch,POS_PUNTOS,puntajes,COLOR_BLANCO
    ImprimirTextoEspecifico 0Ch,POS_SALIR,salir,COLOR_BLANCO
    ImprimirTextoEspecifico 00h,LINEA_BOTON,datos,COLOR_BLANCO
    ImprimirTextoEspecifico 0Ah,POS_INICIAR,arrow,COLOR_ROJO

Loop_menu:
    jmp Tomar_llave_menu

Tomar_llave_menu:
    mov AH,12h
    int 16h
    mov BX,AX

    mov AH,10h                                              
    int 16h

Verificar_menu_llave:
    cmp AH,CLAVE_ARRIBA                                         
    je Verificar_flecha_arriba_menu
    cmp AH,CLAVE_ABAJO                                        
    je Verificar_flecha_abajo_menu
    cmp AH,TECLA_F1
    je Seleccion_menu
    jmp Loop_menu

Verificar_flecha_arriba_menu:
    TomarPosicionCursor
    ImprimirTextoEspecifico 0Ah,DH,vacio,COLOR_ROJO
    cmp DH,POS_INICIAR
    je Pasar_a_pos5
    sub DH,02h
    ImprimirTextoEspecifico 0Ah,DH,arrow,COLOR_ROJO
    jmp Verificar_flecha_arriba_final
    Pasar_a_pos5:
        ImprimirTextoEspecifico 0Ah,DH,vacio,COLOR_ROJO
        ImprimirTextoEspecifico 0Ah,POS_SALIR,arrow,COLOR_ROJO
        jmp Verificar_flecha_arriba_final
    Verificar_flecha_arriba_final:
        jmp Loop_menu

Verificar_flecha_abajo_menu:
    TomarPosicionCursor
    ImprimirTextoEspecifico 0Ah,DH,vacio,COLOR_ROJO
    cmp DH,POS_SALIR
    je Pasar_a_pos1
    add DH,02h
    ImprimirTextoEspecifico 0Ah,DH,arrow,COLOR_ROJO
    jmp Verficar_flecha_abajo_final
    Pasar_a_pos1:
        ImprimirTextoEspecifico 0Ah,DH,vacio,COLOR_ROJO
        ImprimirTextoEspecifico 0Ah,POS_INICIAR,arrow,COLOR_ROJO
        jmp Verificar_flecha_arriba_final
    Verficar_flecha_abajo_final:
        jmp Loop_menu
        
Seleccion_menu:
    TomarPosicionCursor
    cmp DH,POS_INICIAR
    je Iniciar_partida
    cmp DH,POS_CARGAR
    je Inicio_juego_arbitrario
    cmp DH,POS_SALIR
    je Final
    jmp Loop_menu

Iniciar_partida:
    mov AH,00h                                                           
    mov curr_nivel,AH
    call Analizar_nivel 
    jmp Lopp_juego

Inicio_juego_arbitrario:
    call Iniciar_video
    LimpiarBufferKB KbIn_nivel,20h
    ImprimirTextoEspecifico 3h,8h,prompt_nivel,COLOR_BLANCO
    MoverPuntero 3h,0Ah
    mov AH,0Ah
    mov DX,offset KbIn_nivel
    int 21h

    lea SI, KbIn_nivel
    add SI,02h
    lea DI, nombre_nivelA

    Quitar_retorno:
        lodsb
        cmp AL,0d
        je msg_continuarArbi
        cmp AL,0a
        je msg_continuarArbi
        cmp AL,0h
        je msg_continuarArbi
        stosb
        jmp Quitar_retorno
    msg_continuarArbi:
    mov AH,03h                                     
    call Analizar_nivel 
    jmp Lopp_juego

Lopp_juego:
    call Tomar_tiempo
    mov ah,11h
    int 16h
    jz Lopp_juego                                  

    mov V_DESP,00h
    call Jugador_parado_en
    mov AH,10h
    int 16h
    cmp AH,TECLA_F2
    je Menu_pausa
    cmp AH,tecla_arriba
    jnz No_arriba
    dec posy_jugador
    mov V_DESP,DESP_U
    jmp Posicion_final 
    No_arriba:                                    
        cmp AH,tecla_abajo
        jnz No_abajo
        inc posy_jugador
        mov V_DESP,DESP_D
    No_abajo:                                       
        cmp AH,tecla_izquierda
        jnz No_izquierda
        dec posx_jugador
        mov V_DESP,DESP_L
    No_izquierda:                                
        cmp AH,tecla_derecha
        jnz Posicion_final
        inc posx_jugador
        mov V_DESP,DESP_R
    Posicion_final:    
        call Verificar_colision 
        call Actualizar_puntaje
        call Renderizar_jugador

    jmp Lopp_juego


Renderizar_sprite:		
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
	
	mov CL,08h			                                              
DibujarY:
	push DI
    mov CH,08h		                                                  
DibujarX:				
    mov AL,DS:[SI]

  
    mov ES:[DI],AL
    inc SI
    inc DI
    dec CH
    jnz DibujarX                                                     
	pop DI
	add DI,0140h			                                         
	inc BL
	dec CL
	jnz DibujarY
    pop ES
    pop DS
	ret		

Analizar_nivel:
    call Limpiar_assets_nivel 
    cmp AH,00h
    je Nivel_uno
    cmp AH,01h
    je Nivel_dos
    cmp AH,02h
    je Nivel_tres
    cmp AH,03h
    je Nivel_arbitrario
 
    Nivel_uno:    
        mov DX, offset nombre_nivel1
        jmp Cargar_archivo

    Nivel_dos:
        mov DX, offset nombre_nivel2
        jmp Cargar_archivo

    Nivel_tres:
        mov DX, offset nombre_nivel3
        jmp Cargar_archivo

    Nivel_arbitrario:
        lea DX, nombre_nivelA
        jmp Cargar_archivo

    Cargar_archivo:
        mov AL, 2
        mov AH, 3Dh
        int 21h
        mov [handle_nivel], AX
        mov BX,[handle_nivel]
        jc menu_principal                                                
        call Iniciar_video
    Leer_caracter:
        LimpiarBuffer char_temporal,0a
        mov AH,3Fh
        mov CX,01h
        mov DX,offset char_temporal
        int 21h
        jc Finalizar_lectura                                            
        cmp AX,0000h                                                       
        je Finalizar_lectura

        call Saltar_espacio
        cmp char_temporal,'c'
        je Leer_caja
        cmp char_temporal,'j'
        je Leer_jugador
        cmp char_temporal,'p'
        je Leer_pared
        cmp char_temporal,'o'
        je Leer_objetivo
        cmp char_temporal,'s'
        je Leer_suelo
        ret

    Leer_caja:
        mov AH,42h
        mov AL,01h
        mov DX,0003h 
        mov CX,0000h 
        int 21h

        call LeerXY

        cmp cont_cajas,1Eh 
        je Error_obj
        
        push SI
        push DI

        lea SI,posx_caja
        lea DI, x_temportal
        call Agregar_al_arreglo

        lea SI,posy_caja
        lea DI, y_temporal
        call Agregar_al_arreglo

        inc cont_cajas

        pop SI
        pop DI
        jmp Leer_caracter
    Leer_jugador:
        mov AH,42h
        mov AL,01h
        mov DX,0006h 
        mov CX,0000h 
        int 21h

        call LeerXY

        mov AL,[x_temportal] 
        mov AH,[y_temporal] 
        mov [posx_jugador],AL
        mov [posy_jugador],AH
        jmp Leer_caracter
    Leer_pared:
        mov AH,42h
        mov AL,01h
        mov DX,0004h 
        mov CX,0000h 
        int 21h

        call LeerXY

        cmp cont_pared,0FFh 
        je Error_obj
        
        push SI
        push DI

        lea SI,posx_pared
        lea DI, x_temportal
        call Agregar_al_arreglo

        lea SI,posy_pared
        lea DI, y_temporal
        call Agregar_al_arreglo

        pop SI
        pop DI
        jmp Leer_caracter
    Leer_objetivo:
        mov AH,42h
        mov AL,01h
        mov DX,0007h 
        mov CX,0000h 
        int 21h

        call LeerXY

        cmp cont_obj,1Eh 
        je Error_obj
        
        push SI
        push DI

        lea SI,posx_obj
        lea DI, x_temportal
        call Agregar_al_arreglo

        lea SI,posy_obj
        lea DI, y_temporal
        call Agregar_al_arreglo

        pop SI
        pop DI
        jmp Leer_caracter
    Leer_suelo:
        mov AH,42h
        mov AL,01h
        mov DX,0004h 
        mov CX,0000h 
        int 21h

        call LeerXY

        cmp cont_suelo,0FFh 
        je Error_obj
        
        push SI
        push DI

        lea SI,posx_suelo
        lea DI, x_temportal
        call Agregar_al_arreglo

        lea SI,posy_suelo
        lea DI, y_temporal
        call Agregar_al_arreglo

        pop SI
        pop DI
        jmp Leer_caracter

    Error_obj:
        ret

    Finalizar_lectura:
        call Renderizar_mapa
        ret

Renderizar_mapa:
    call Iniciar_video                                         
    call Renderizar_pared
    call Renderizar_suelo
    call Renderizar_objetivo
    call Renderizar_caja
    call Renderizar_jugador
    ImprimirTextoEspecifico 00h,LINEA_BOTON,datos_pantalla,COLOR_BLANCO 
    ret

Renderizar_suelo:
    mov counter_g,0000h                                        
    Renderizar_sueloTile:

    RenderizarPos posx_suelo,posy_suelo,counter_g

    xor AX,AX
    xor SI,SI
    lea SI,suelo
    mov DH,[x_temportal]
    mov DL,[y_temporal]
    call Renderizar_sprite

    inc counter_g
    jmp Renderizar_sueloTile
    Finalizar_suelo:
        mov counter_g,0000h
        ret

Renderizar_pared:
    mov counter_g,0000h                                       
    Renderizar_pared_tile:

    RenderizarPos posx_pared,posy_pared,counter_g
    
    xor AX,AX
    xor SI,SI
    lea SI,pared
    mov DH,[x_temportal]
    mov DL,[y_temporal]
    call Renderizar_sprite

    add counter_g,0001h
    jmp Renderizar_pared_tile
    Finalizar_pared:
        mov counter_g,0000h
        ret

Renderizar_caja:
    mov counter_g,0000h                                        
    Renderizar_caja_tile:

    RenderizarPos posx_caja,posy_caja,counter_g
    
    xor AX,AX
    xor SI,SI
    lea SI,caja
    mov DH,[x_temportal]
    mov DL,[y_temporal]
    call Renderizar_sprite

    add counter_g,0001h
    jmp Renderizar_caja_tile
    Finalizar_caja:
        mov counter_g,0000h
        ret

Renderizar_objetivo:
    mov counter_g,0000h                                        
    Renderizar_obj_tile:

    RenderizarPos posx_obj,posy_obj,counter_g
    
    xor AX,AX
    xor SI,SI
    lea SI,objetivo
    mov DH,[x_temportal]
    mov DL,[y_temporal]
    call Renderizar_sprite

    add counter_g,0001h
    jmp Renderizar_obj_tile
    Finalizar_objeto:
        mov counter_g,0000h
        ret

Renderizar_jugador:
    lea SI,jugador
    mov DH,[posx_jugador]
    mov DL,[posy_jugador]
    mov x_temportalP,DH
    mov y_temporalP,DL
    call Renderizar_sprite
    ret
 

Verificar_colision: 
    call Buscar_pared
    call Caja_Hitcaja
    call Verificar_estado_ganar
    ret

Buscar_pared:
    mov counter_g,0000h
    lea SI,posx_pared
    BuscarX_pared:
        lodsb
        cmp AL,posx_jugador
        je BuscarY_pared
        cmp AL,0FFh
        je Capaz_moverse_pared
        inc counter_g
        jmp BuscarX_pared
    BuscarY_pared:
        push SI
        xor SI,SI
        lea SI,posy_pared
        add SI,counter_g
        lodsb
        cmp AL,posy_jugador
        je No_moverse_a_pared
        pop SI
        inc counter_g
        jmp BuscarX_pared
    No_moverse_a_pared:
        pop SI
        xor AX,AX
        mov AH,x_temportalP
        mov AL,y_temporalP
        mov posx_jugador,AH
        mov posy_jugador,AL
    Capaz_moverse_pared:
        ret
        
    ret

Caja_Hitcaja: 
    Findcaja:
    mov counter_g,0000h
    lea SI,posx_caja
    BuscarX_caja:
        lodsb
        cmp AL,posx_jugador
        je BuscarY_caja
        cmp AL,0FFh
        je Caja_no_encontrada
        inc counter_g
        jmp BuscarX_caja
    BuscarY_caja:
        push SI
        xor SI,SI
        lea SI,posy_caja
        add SI,counter_g
        lodsb
        cmp AL,posy_jugador
        je Caja_encontrada
        pop SI
        inc counter_g
        jmp BuscarX_caja
    Caja_no_encontrada:
        ret
    Caja_encontrada:
        pop SI
        lea SI,posx_caja
        add SI,counter_g
        lodsb
        mov x_temportalB,AL
        lea SI,posy_caja
        add SI,counter_g
        lodsb

        mov y_temporalB,AL
        cmp V_DESP,DESP_U
        je Verificar_movimiento_arriba
        cmp V_DESP,DESP_D
        je Verificar_movimiento_abajo
        cmp V_DESP,DESP_L
        je Verificar_movimiento_izquierda
        cmp V_DESP,DESP_R
        je Verificar_movimiento_derecha
        ret

    Verificar_movimiento_arriba: 
        dec y_temporalB
        jmp Verificar_movimiento_cajas
    Verificar_movimiento_abajo: 
        inc y_temporalB
        jmp Verificar_movimiento_cajas
    Verificar_movimiento_izquierda:
        dec x_temportalB
        jmp Verificar_movimiento_cajas
    Verificar_movimiento_derecha:
        inc x_temportalB
        jmp Verificar_movimiento_cajas

    Verificar_movimiento_cajas:
        call Buscar_caja_siguiente
        cmp AH,01h
        je No_mover_caja
        call Buscar_pared_siguiente
        cmp AH,01h
        je No_mover_caja

        lea BX,posx_caja
        add BX,counter_g
        mov AH,x_temportalB
        mov [BX],AH

        lea BX,posy_caja
        add BX,counter_g
        mov AH,y_temporalB
        mov [BX],AH
        
        mov DH,x_temportalB
        mov DL,y_temporalB
        lea SI,caja
        call Renderizar_sprite

        ret
    No_mover_caja:
        pop SI
        xor AX,AX
        mov AH,x_temportalP
        mov AL,y_temporalP
        mov posx_jugador,AH
        mov posy_jugador,AL
        ret

Buscar_caja_siguiente:
    mov counter_g2,0000h
    lea SI,posx_caja
    BuscarX_cajaAt:
        lodsb
        cmp AL,x_temportalB
        je BuscarY_cajaAt
        cmp AL,0FFh
        je Caja_no_encontradaAt
        inc counter_g2
        jmp BuscarX_cajaAt
    BuscarY_cajaAt:
        push SI
        xor SI,SI
        lea SI,posy_caja
        add SI,counter_g2
        lodsb
        cmp AL,y_temporalB
        je Caja_encontradaAt
        pop SI
        inc counter_g2
        jmp BuscarX_cajaAt
    Caja_no_encontradaAt:
        mov AH,00h
        ret
    Caja_encontradaAt:
        pop SI
        mov AH,01h
        ret

Buscar_pared_siguiente:
    mov counter_g2,0000h
    lea SI,posx_pared
    BuscarX_paredAt:
        lodsb
        cmp AL,x_temportalB
        je BuscarY_paredAt
        cmp AL,0FFh
        je Capaz_moverse_paredAt
        inc counter_g2
        jmp BuscarX_paredAt
    BuscarY_paredAt:
        push SI
        xor SI,SI
        lea SI,posy_pared
        add SI,counter_g2
        lodsb
        cmp AL,y_temporalB
        je No_moverse_a_paredAt
        pop SI
        inc counter_g2
        jmp BuscarX_paredAt
    No_moverse_a_paredAt:
        pop SI
        mov AH,01h
        ret
    Capaz_moverse_paredAt:
        mov AH,00h
        ret

Verificar_estado_ganar:
    mov counter_g,0000h
    Loop_estado_ganar:
        lea SI,posx_caja
        add SI,counter_g
        lodsb
        mov x_temportalB,AL

        cmp x_temportalB,0FFh
        je Gano

        lea SI,posy_caja
        add SI,counter_g
        lodsb
        mov y_temporalB,AL

        mov counter_g2,0000h
        Buscar_estadoX_ganar:
            lea SI,posx_obj
            add SI,counter_g2
            lodsb
            cmp x_temportalB,AL
            je Buscar_estadoY_ganar
            cmp AL,0FFh
            je No_gano_ahora
            inc counter_g2
            jmp Buscar_estadoX_ganar
        Buscar_estadoY_ganar:
            lea SI,posy_obj
            add SI,counter_g2
            lodsb
            cmp y_temporalB,AL
            je Encontrar_uno
            inc counter_g2
            jmp Buscar_estadoX_ganar
        Encontrar_uno:
            inc counter_g
            jmp Loop_estado_ganar

    No_gano_ahora:
        ret

    Gano:
        jmp Tu_ganaste

Tu_ganaste: 
    cmp curr_nivel,02h
    jb Ir_al_siguiente_nivel
    mov curr_nivel,00h
    call Iniciar_video
    jmp menu_principal
    Ir_al_siguiente_nivel:
        inc curr_nivel
        mov AH,curr_nivel
        call Analizar_nivel
        ret

Actualizar_puntaje:
    mov AH,x_temportalP
    cmp AH,posx_jugador
    je CompareY
    inc curr_scr 
    jmp Renderizar_puntaje
    CompareY:
        mov AL,y_temporalP
        cmp AL,posy_jugador
        je Renderizar_puntaje
        inc curr_scr
    Renderizar_puntaje:
        cmp curr_scr,0064h
        jb TriplePad
        cmp curr_scr,03E8h
        jb DoublePad
        cmp curr_scr,2710h
        jb SinglePad
        ;no pad
        BufferItoa curr_scr,buffer_g2
        ImprimirTextoEspecifico 22h,00h,buffer_g2,COLOR_BLANCO
        ret
        TriplePad:
            ImprimirTextoEspecifico 22h,00h,pad3,COLOR_BLANCO
            BufferItoa curr_scr,buffer_g2
            ImprimirTextoEspecifico 25h,00h,buffer_g2,COLOR_BLANCO
            ret
        DoublePad:
            ImprimirTextoEspecifico 22h,00h,pad2,COLOR_BLANCO
            BufferItoa curr_scr,buffer_g2
            ImprimirTextoEspecifico 24h,00h,buffer_g2,COLOR_BLANCO
            ImprimirTextoEspecifico 27h,00h,vacio,COLOR_BLANCO
            ret
        SinglePad:
            ImprimirTextoEspecifico 22h,00h,padCero,COLOR_BLANCO
            BufferItoa curr_scr,buffer_g2
            ImprimirTextoEspecifico 23h,00h,buffer_g2,COLOR_BLANCO
            ret
    ret

Jugador_parado_en:
    mov counter_g,0000h
    lea SI,posx_obj
    BuscarX_Steppint:
        lodsb
        cmp AL,x_temportalP
        je BuscarY_Stepping
        cmp AL,0FFh
        je Piso_Stepping
        inc counter_g
        jmp BuscarX_Steppint
    BuscarY_Stepping:
        push SI
        xor SI,SI
        lea SI,posy_obj
        add SI,counter_g
        lodsb
        cmp AL,y_temporalP
        je Objetivo_Stepping
        pop SI
        inc counter_g
        jmp BuscarX_Steppint

    Objetivo_Stepping:
        pop SI
        xor AX,AX
        lea SI, objetivo
        mov DH,x_temportalP
        mov DL,y_temporalP
        call Renderizar_sprite
        ret
    Piso_Stepping:
        lea SI, suelo
        mov DH,x_temportalP
        mov DL,y_temporalP
        call Renderizar_sprite
        ret
        
    ret

Menu_pausa:
    call Iniciar_video
    ImprimirTextoEspecifico 0Ch,POS_CONTADOR,msg_continuar,COLOR_BLANCO
    ImprimirTextoEspecifico 0Ch,POS_LEAV,salir,COLOR_BLANCO
    ImprimirTextoEspecifico 0Ah,POS_CONTADOR,arrow,COLOR_ROJO
    jmp Tomar_clave_pausa

Tomar_clave_pausa:
    mov AH,12h
    int 16h
    mov BX,AX 

    mov AH,10h                                                          
    int 16h

Verificar_clave_pausa:
    cmp AH,CLAVE_ARRIBA                                                 
    je Verificar_flecha_pausa
    cmp AH,CLAVE_ABAJO                                                  
    je Verificar_flecha_pausa
    cmp AH,TECLA_F1
    je Seleccion_pausa
    jmp Tomar_clave_pausa

Verificar_flecha_pausa:
    TomarPosicionCursor
    ImprimirTextoEspecifico 0Ah,DH,vacio,COLOR_ROJO
    cmp DH,POS_CARGAR
    je Mudarse_para_irse
    ImprimirTextoEspecifico 0Ah,POS_LEAV,vacio,COLOR_ROJO
    ImprimirTextoEspecifico 0Ah,POS_CONTADOR,arrow,COLOR_ROJO
    jmp FinalVerificar_flecha_pausa
    Mudarse_para_irse:
        ImprimirTextoEspecifico 0Ah,POS_CONTADOR,vacio,COLOR_ROJO
        ImprimirTextoEspecifico 0Ah,POS_LEAV,arrow,COLOR_ROJO
        jmp FinalVerificar_flecha_pausa
    FinalVerificar_flecha_pausa:
        jmp Tomar_clave_pausa
 
Seleccion_pausa:
    TomarPosicionCursor
    cmp DH,POS_CONTADOR
    je RenderAndmsg_continuar
    cmp DH,POS_LEAV
    je Limpiar_e_irse
    jmp Verificar_clave_pausa
    RenderAndmsg_continuar:
        call Renderizar_mapa
        jmp Lopp_juego
    Limpiar_e_irse:
        call Iniciar_video
        jmp menu_principal

Saltar_espacio:
    Comparar_espacio:
        cmp char_temporal, 0a
        je Omitir
        cmp char_temporal,' '
        jne FinishSaltar_espacio
    Omitir:
        mov AH,3Fh
        mov CX,01h
        mov DX,offset char_temporal
        int 21h

        jc Finalizar_lectura                                        
        cmp AX,0000h                                                
        je Finalizar_lectura

        jmp Comparar_espacio
    FinishSaltar_espacio:
        ret

LeerXY:
    LimpiarBuffer char_temporal,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset char_temporal
    int 21h
    
    call Saltar_espacio

    mov AH,3Fh
    mov CX,01h 
    mov DX, offset char_temporal
    inc DX                                                        
    int 21h
    
    BufferAtoi char_temporal,x_temportal


    LimpiarBuffer char_temporal,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset char_temporal
    int 21h
    
    call Saltar_espacio
                                                                 
    mov AH,42h
    mov AL,01h
    mov DX,0001h
    mov CX,0000h 
    int 21h

    LimpiarBuffer char_temporal,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset char_temporal
    int 21h

    call Saltar_espacio

    mov AH,3Fh
    mov CX,01h 
    mov DX, offset char_temporal
inc DX                                                             
    int 21h
    BufferAtoi char_temporal,y_temporal
    inc y_temporal
    LimpiarBuffer char_temporal,0a
    ret

Agregar_al_arreglo:
    push DI 
    push SI

    mov DI,SI                                                     
    mov AH,00h                                                    
    Buscar_cero:                                                  
        lodsb
    cmp AL,0FFh                                                   
        je Encontrar_cero
        inc AH                                                    
        jmp Buscar_cero
    Encontrar_cero:
        pop DI
        pop SI
        mov AL,AH                                                   
        mov AH,00h                                                  

    add DI,AX                                                       
    movsb                                                        
        ret

Imprimir_Str:
    Tomar_char: 
    lodsb                                                         
        cmp AL,0    
        je Terminar_impresion                                     
        
        mov AH,0Eh                                                
        mov BH,00h                                                
        int 10h

        jmp Tomar_char
    Terminar_impresion:
        ret

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
pop AX                                                                   
        mov AH,01h
        ret

itoa: 
    xor CX,CX 
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

Iniciar_video:
    mov AH, 00h
    mov AL, 13h
    int 10h
    ret

Restaurar_video:
    mov AH,00h
    mov AL,03h
    int 10h
    ret

Limpiar_assets_nivel:
    LimpiarBufferJuego posx_caja,1Eh
    LimpiarBufferJuego posy_caja,1Eh
    LimpiarBufferJuego posx_obj,1Eh
    LimpiarBufferJuego posy_obj,1Eh
    LimpiarBufferJuego posx_pared,0FFh
    LimpiarBufferJuego posy_pared,0FFh
    LimpiarBufferJuego posx_suelo,0FFh
    LimpiarBufferJuego posy_suelo,0FFh
    mov posx_jugador,00h
    mov posy_jugador,00h
    mov cont_obj,00h
    mov cont_cajas,00h
    mov cont_pared,00h
    mov cont_suelo,00h
    mov segundos,00h
    mov minutos,00h
    mov horas,00h
    mov timer,00h
    mov curr_scr,0000h
    ret

Tomar_tiempo:
    mov AH,2Ch
    int 21h
    cmp DH,timer
    jne Actualizar_timer
    ret
    Actualizar_timer:
        mov timer,DH
        inc segundos
        cmp segundos,3Ch 
        jge Actualizar_minutos
        jmp Imprimir_nueva_hora
    Actualizar_minutos:
        mov segundos,00h
        inc minutos
        cmp minutos,3Ch
        jge Actualizar_horas
        jmp Imprimir_nueva_hora
    Actualizar_horas:
        mov minutos,00h
        inc horas     
    Imprimir_nueva_hora:
        mov AL,segundos
        cbw
        mov segundos2b,AX
        mov AL,minutos
        cbw
        mov minutos2b,AX
        mov AL,horas
        cbw
        mov horas2b,AX
        ImprimirTextoEspecifico 24h,LINEA_BOTON,puntos,COLOR_BLANCO

        BufferItoa segundos2b,buffer_g2
        ImprimirTextoEspecifico 25h,LINEA_BOTON,buffer_g2,COLOR_BLANCO

        ImprimirTextoEspecifico 21h,LINEA_BOTON,puntos,COLOR_BLANCO

        BufferItoa minutos2b,buffer_g2
        ImprimirTextoEspecifico 22h,LINEA_BOTON,buffer_g2,COLOR_BLANCO
        

        BufferItoa horas2b,buffer_g2
        ImprimirTextoEspecifico 1Fh,LINEA_BOTON,buffer_g2,COLOR_BLANCO
        ret

padCeroding:
    cmp AX,0Ah
    jb addpadCeroding
    LimpiarBuffer buffer_g,20h
    lea DI,buffer_g 
    ret
addpadCeroding: 
    LimpiarBuffer buffer_g,20h
    lea DI,buffer_g 
    AnadirBufferTMP padCero,01h,0 
    ret

TextModeImprimir_Str:
    TMTomar_char:
        lodsb
        cmp AL,0a
        je nline 
        cmp AL,0
        je TMfinished
        mov AH, 0Eh
        int 10h
        jmp TMTomar_char
    
    nline:             
        mov AL, 0d
        mov AH, 0Eh
        int 10h
        mov AL, 0a
        mov AH, 0Eh
        int 10h
        jmp TMTomar_char

    TMfinished:
        ret

Final:
    .EXIT


pared:    
    db 12,12,0f,0f,0f,0f,0f,12
    db 0f,12,12,18,17,17,17,12
    db 0f,0f,12,12,18,17,17,12
    db 0f,17,0f,12,12,18,17,12
    db 0f,17,17,0f,12,12,18,12
    db 12,17,17,17,0f,12,12,12
    db 12,12,17,17,17,0f,12,12
    db 12,12,12,12,12,12,12,12

caja:
    db 18,15,18,18,18,18,15,18
    db 15,18,15,15,15,15,18,15
    db 18,15,18,15,15,18,15,18
    db 18,15,15,18,18,15,15,18
    db 18,15,15,18,18,15,15,18
    db 18,15,18,15,15,18,15,18
    db 15,18,15,15,15,15,18,15
    db 18,15,18,18,18,18,15,18

suelo:
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c
    db 1c,1c,1c,1c,1c,1c,1c,1c

objetivo:
    db 1c,1c,28,28,28,28,1c,1c
    db 1c,28,1c,1c,1c,1c,28,1c
    db 28,1c,28,1c,1c,28,1c,28
    db 28,1c,1c,28,28,1c,1c,28
    db 28,1c,1c,28,28,1c,1c,28
    db 28,1c,28,1c,1c,28,1c,28
    db 1c,28,1c,1c,1c,1c,28,1c
    db 1c,1c,28,28,28,28,1c,1c

jugador:
    db 1c,14,14,14,14,14,14,1c
    db 14,4c,00,4c,4c,00,4c,14
    db 14,4c,4c,00,00,4c,4c,14
    db 1c,14,14,14,14,14,14,1c
    db 1c,1c,14,14,14,14,1c,1c
    db 1c,1c,00,14,14,00,1c,1c
    db 1c,1c,1c,14,14,1c,1c,1c
    db 1c,00,14,14,14,14,00,1c 
    

END
