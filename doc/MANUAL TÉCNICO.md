### Kevin Ernesto García Hernández | 202113553

# Manual Técnico

Un manual técnico es un documento que va dirigido a un público con conocimientos
técnicos sobre el área en la que estamos trabajando, en este caso, hablando de un
proyecto de programación, va dirigido a una persona que tenga conocimientos en
programación.

## Herramientas

Para el desarrollo de este proyecto se utilizaron las siguientes herramientas y tecnologías:

- DOSBox: DOSBox es un emulador de DOS que permite ejecutar programas y juegos diseñados para el sistema operativo MS-DOS en sistemas modernos. Es una herramienta esencial para programar en ensamblador (MASM) ya que proporciona un entorno compatible con DOS donde se pueden ejecutar y depurar programas.

- MASM (Microsoft Macro Assembler): MASM es un ensamblador desarrollado por Microsoft que se utiliza para escribir programas en lenguaje ensamblador para plataformas x86. Es compatible con DOS y Windows, y ofrece un conjunto de macros y directivas que facilitan la escritura de código en ensamblador.

- emu8086: emu8086 es un emulador de microprocesador Intel 8086 que permite ejecutar y depurar programas escritos en lenguaje ensamblador. Es una herramienta útil para el desarrollo y la depuración de programas ensambladores, ya que proporciona una simulación del funcionamiento del procesador 8086 y permite observar el estado de los registros y la memoria durante la ejecución del programa.

- Editor de texto: Para escribir y editar el código fuente en ensamblador (MASM), se requiere un editor de texto. Puedes utilizar cualquier editor de texto de tu elección, como Notepad++, Sublime Text, Visual Studio Code, entre otros. Estos editores de texto suelen ofrecer características útiles como resaltado de sintaxis y autocompletado, lo que facilita la escritura y el mantenimiento del código.

- Documentación y recursos: Para programar en ensamblador (MASM), es importante contar con documentación y recursos de referencia. Puedes consultar el manual de MASM y los manuales de referencia del conjunto de instrucciones x86 para obtener información detallada sobre las instrucciones y las directivas de ensamblador. Además, hay una amplia variedad de tutoriales, libros y recursos en línea que pueden servir como guías de aprendizaje y referencia.

Estas herramientas, como DOSBox, MASM y emu8086, junto con un editor de texto y recursos de documentación, brindan un entorno completo y funcional para programar en ensamblador (MASM). Con estas herramientas, puedes escribir, depurar y ejecutar programas en ensamblador, aprovechando las características y funcionalidades de la arquitectura x86 y del conjunto de instrucciones del procesador Intel 8086.

## Programa

El programa únicamente se basa en un archivo **main.asm** el cual contiene todo el código del programa.

### Funciones Importantes

El programa cuenta con demasiadas funciones, pero las más importantes son las siguientes:

### Renderizar

```asm
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
```

### Convertir a String

```asm
cadenaAnum:
    mov AX, 0000    
    mov CX, 0005    		
    seguir_convirtiendo:
        mov BL, [DI]
        cmp BL, 00
        je retorno_cadenaAnum
        sub BL, 30      
        mov DX, 000a
        mul DX         
        mov BH, 00
        add AX, BX 
        inc DI         
        loop seguir_convirtiendo
        retorno_cadenaAnum:
            ret
```

### Convertir a Número

```asm
numAcadena:
    
    mov CX, 0005
    mov DI, offset numero

    ciclo_poner30s:
        mov BL, 30
        mov [DI], BL
        inc DI
        loop ciclo_poner30s

        mov CX, AX                     
        mov DI, offset numero
        add DI, 0004
		
        ciclo_convertirAcadena:
            mov BL, [DI]
            inc BL
            mov [DI], BL
            cmp BL, 3a
            je aumentar_siguiente_digito_primera_vez
            loop ciclo_convertirAcadena
            jmp retorno_convertirAcadena

            aumentar_siguiente_digito_primera_vez:
                push DI

                aumentar_siguiente_digito:
                    mov BL, 30  
                    mov [DI], BL
                    dec DI         
                    mov BL, [DI]
                    inc BL
                    mov [DI], BL
                    cmp BL, 3a
                    je aumentar_siguiente_digito
                    pop DI      
                    loop ciclo_convertirAcadena

    retorno_convertirAcadena:
    ret
```

### Obtener Nivel

```asm
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
```

### Redenrizar Nivel

```asm
Renderizar_mapa:
    call Iniciar_video                                       
    call Renderizar_pared
    call Renderizar_suelo
    call Renderizar_objetivo
    call Renderizar_caja
    call Renderizar_jugador
    ImprimirTextoEspecifico 00h,LINEA_BOTON,datos_pantalla,COLOR_GRIS 
    ret
```

```asm
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
```

```asm
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
```

```asm
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
```

```asm
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
```

```asm
Renderizar_jugador:
    lea SI,jugador
    mov DH,[posx_jugador]
    mov DL,[posy_jugador]
    mov x_temportalP,DH
    mov y_temporalP,DL
    call Renderizar_sprite
    ret
```

### Macros

Las macros son una herramienta muy útil para el desarrollo de programas en ensamblador (MASM), ya que permiten definir bloques de código que se pueden reutilizar en diferentes partes del programa. Las macros se definen con la directiva MACRO y se finalizan con la directiva ENDM. Las macros pueden recibir parámetros y pueden contener cualquier instrucción o directiva de ensamblador.

Las que se utilizaron en este proyecto son las siguientes:

### Mover el puntero
    
```asm
    MoverPuntero MACRO xpos,ypos
    mov AH,02h  
    mov BH,00h  
    mov DH,ypos
    mov DL,xpos
    int 10h
ENDM
```

### Obtener la posicion del puntero

```asm
TomarPosicionCursor MACRO
    mov AH,03h
    mov BH,0h   
    int 10h
ENDM
```

### Imprimir texto

```asm
ImprimirTextoEspecifico MACRO xpos, ypos, stringbuffer, color
    push SI
    MoverPuntero xpos,ypos
    lea SI,stringbuffer 
    mov BL,color
    call Imprimir_Str 
    pop SI
ENDM
```

### Sprite

```asm
PonerSprite MACRO sprite,col,row
    lea SI, sprite
    mov DH,col
    mov DL,row
    call Renderizar_sprite
ENDM
```

### Limpiar Buffer

```asm
LimpiarBuffer MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    mov AL,0
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM
```

### Redenrizado

```asm
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
```