.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGHT, 	480
.equ BITS_PER_PIXEL,  	32

.globl main
main:
	// X0 contiene la direccion base del framebuffer
 	mov x20, x0	// Save framebuffer base address to x20	

	mov x2, 320
	mov x1, 480
	mov x27, 100
	movz x3, 0x11, lsl 16
	movk x3, 0x11CF, lsl 00    
	movz x26, 0x10, lsl 16          // Initialize some registers
	movk x26, 0x1000, lsl 00
	mov x19, 1

rocketLoop:
	bl paint_background
	sub x3, x3, 0x4                 // Darkens the background
	sub x3, x3, x26
	sub x1, x1, 8                  // Set the y coordinate 8+ up
	                               // so the rocket gets painted 8 pixels up
  sub x19, x19, 1
  cbz x19, lopyyfire   // cbz 1 = primer frame, seguir con la animacion pasar el contador al segundo frame
  sub x19, x19 ,1                  
  cbz x19, lopyyfire2  // cbz 2 = segundo frame, seguir con la animacion pasar el contador al tercer frame
  sub x19, x19, 1
  cbz x19, lopyyfire3  // cbz 3 = tercer frame, seguir con la animacion pasar el contador al cuarto frame
  sub x19, x19, 1
  cbz x19, lopyyfire4  // cbz 4 = cuarto frame, volver el contador al  primer fuego seguir con la animacion
lopyyfire:                     // Animates fire, consists of 4 diferent fire variations (4 frames)
	bl paint_fire
	add x19, x19,2 
	b endfiree
lopyyfire2:
	bl paint_fire4
	add x19, x19,3
	b endfiree 
lopyyfire3:
	bl paint_fire3
	add x19, x19,4
	b endfiree
lopyyfire4:	
	bl paint_fire2
	add x19, x19, 1
	b endfiree
endfiree:					

	bl paint_rocket                // paints the rocket
	bl delay

	cmp x27, x1                    // If x1 = 100, the rocket is in the middle, end loop
	b.le rocketLoop


	mov x27, 480                     // Initialize some registers
	mov x2, 0
	mov x1, -480        // Basicamente, para hacer que las estrellas bajen y infinitamente, lo que hacemos
	mov x16, x1         // es pintar lo suficiente para 2 pantallas de estrellas, bajarlas 960 pixeles, osea
	mov x17, x1         // dos pantallas y luego resetearlas 480 pixeles hacia arriba, por lo que el cambio
	mov x18, x1         // no se nota, ya que van a estar en exactamente la misma posicion. Luego, cada vez
	                    // que x1 = 480 significa que llego al final y hay que resetearlas de nuevo
starloop:                          // Infinite loop for the stars and planets
	bl paint_background

	sub SP, SP, 24
	stur x16, [SP, 16]
	stur x17, [SP, 8] 
	stur x18, [SP, 0]        //save x16, x17, x18

	sub x16, x16, 480
	sub x17, x17, 480
	sub x18, x18, 480
	mov x1, x16
	bl bg_pattern
	mov x1, x17
	bl draw_bg_stars1       // draw second background
	bl draw_bg_stars2
	bl draw_bg_stars3
	mov x1, x18
	bl draw_bg_planets
	
	ldur x18, [SP, 0]      // retrieve x16, x17 and x18
	ldur x17, [SP, 8]
	ldur x16, [SP, 16]
	add SP, SP, 24 

	mov x1, x16
	bl bg_pattern
	mov x1, x17
	bl draw_bg_stars1     // draw first background
	bl draw_bg_stars2
	bl draw_bg_stars3
	mov x1, x18
	bl draw_bg_planets

	sub SP, SP, 16 
	stur x1, [SP, 8]  
	stur x2, [SP, 0]    // Save x1 and x2 so the rocket stays in the middle
	mov x2, 320
	mov x1, 100

  sub x19, x19, 1
  cbz x19, lopyfire
  sub x19, x19 ,1
  cbz x19, lopyfire2
  sub x19, x19, 1
  cbz x19, lopyfire3
  sub x19, x19, 1
  cbz x19, lopyfire4
lopyfire:                         // Animated fire
	bl paint_fire
	add x19, x19,2 
	b endfire
lopyfire2:
	bl paint_fire4
	add x19, x19,3
	b endfire 
lopyfire3:
	bl paint_fire3
	add x19, x19,4
	b endfire
lopyfire4:	
	bl paint_fire2
	add x19, x19, 1
	b endfire

endfire:	

	bl paint_rocket         // Paint static rocket

	ldur x2, [SP, 0]  
	ldur x1, [SP, 8]  // retrieve x1 and x2
	add SP, SP, 16 

	add x16, x16, 5   // Background speed (bg_pattern)
	add x17, x17, 3   // Stars speed 
	add x18, x18, 2   // Planets speed

	cmp x16, x27             // if x16 = 480 reset background to the top 
	b.ge reset
	cmp x17, x27             // if x17 = 480 reset the stars to the top 
	b.ge reset2
	cmp x18, x27             // if x18 = 480 reset the planets to the top 
	b.ge reset3

	bl delay
	b starloop            // Repeat
	
reset:
	mov x1, 0
	mov x16, 0 
	bl delay
	b starloop

reset2:
	mov x1, 0
	mov x17, 0   
	bl delay
	b starloop

reset3:
	mov x1, 0
	mov x18, 0   
	bl delay
	b starloop

	b exit             // branch to exit (just in case something goes wrong)

	// -------------------- Functions ---------------------------

bg_pattern:
	// Paints the full pattern for the background stars
	sub SP, SP, 32 
	stur x30, [SP, 24] 
	stur X1, [SP, 16]  
	stur X2, [SP, 8] 
	stur x3, [SP, 0]  

	mov x4, 3
	mov x5, 3
	movz x3, 0x19, lsl 16
	movk x3, 0x1970, lsl 00
	mov x6, 100
	bl background_pattern

	mov x4, 2
	mov x5, 2
	movz x3, 0x87, lsl 16
	movk x3, 0xCEEB, lsl 00
	mov x6, 90
	bl background_pattern

	mov x4, 3
	mov x5, 3
	movz x3, 0x4B, lsl 16
	movk x3, 0x0082, lsl 00
	mov x6, 80
	bl background_pattern

	movz x3, 0xF0, lsl 16
	movk x3, 0xE68C, lsl 00
	mov x6, 140
	bl background_pattern

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP,24] 
	add SP, SP, 32  

	ret x30

delay: 
	// Delay between each frame 
	mov x26, x9
	movz x9, 0xFFF, lsl 16
	movk x9, 0xFFFF, lsl 00
delayLoop:
	sub x9, x9, 1
	cbnz x9, delayLoop

	mov x9, x26
	br lr

paint_background:           
	// paint background given a color (x3)
	mov x21, x1
	mov x22, x2
	
	mov x2, SCREEN_HEIGHT       // Y Size 
loop1:
	mov x1, SCREEN_WIDTH        // X Size
loop0:
	stur w3, [x0]
	add x0, x0, 4	   // Next pixel
	sub x1, x1, 1	   // decrement X counter	
	cbnz x1, loop0	   // If not end row jump
	sub x2, x2, 1	   // Decrement Y counter
	cbnz x2, loop1	   // if not last row, jump

	mov x1, x21
	mov x2, x22
	mov x0, x20
	br lr

paint_pixel:      
	// Paint a pixel given coords (x,y) (x2,x1) and a color (x3)
	mov x11, SCREEN_WIDTH
	mov x12, 4         // Save the width and the number 4 in x11 and x12

	mul x11, x1, x11   // Calculate the pixel position
	add x11, x2, x11
	mul x11, x12, x11

	add x0, x0, x11    // Set x0 to the position
	stur w3, [x0]      // Paint the pixel
	mov x0, x20        // Reset x0

	br lr

paint_rectangle: 
    // Paints a rectangle given a (x,y) coord. (x2,x1), a width and a height (x4,x5), and a color (x3)

	sub SP, SP, 8
	stur x30, [SP, 0] 
    bl paint_pixel
    mov x10, x5 // save height in x10
loopSW:
    mov x9, x4    // Save width in x9
loopW:
    bl paint_pixel
    add x2, x2, 1  // Next pixel
    sub x9, x9, 1  // Decrement width counter
    cmp xzr, x9    // Compare with 0
    b.lt loopW     // If bigger than 0 repeat, else keep going

    sub x2, x2, x4 // Set x2 on the coordinate of the first pixel of the row
    add x1, x1, 1  // Jump to nex row
    sub x10, x10, 1  // Decrement height counter
    cmp xzr, x10   // Compare with 0 
    b.lt loopSW    // If bigger than 0 repeat, else end
    sub x1, x1, x5 // volver Y al mismo lugar del inicio

	ldur x30, [SP, 0]
	add SP, SP, 8


    ret x30

paint_triangle:
	// Paints a triangle given a (x,y) coords (x2, x1) a height (x5) and a color (x3)
	sub SP, SP, 24
	stur x30, [SP, 16]
	stur x4, [SP, 8]
	stur x5, [SP, 0]

	mov x4, 1  //  x4 = x22 x5 = x23
	bl paint_pixel
loopT:
	bl paint_horizontal_row  // Paint row 
	add x1, x1, 1  
	bl paint_horizontal_row

	add x1, x1, 1  
	sub x2, x2, 1  // Next row

	add x4, x4, 2  // Increment row size

	sub x5, x5, 1  // Decrement height counter
	cmp xzr, x5    // Compare with 0
	b.lt loopT     // If bigger than 0 repeat, else continue

	ldur x5, [SP, 0]
	ldur x4, [SP, 8]
	ldur x30, [SP, 16]
	add SP, SP, 24

	ret x30

paint_inverted_triangle:
	// Paints an inverted triangle given a (x,y) coords (x2, x1) a height (x5) and a color (x3)
	sub SP, SP, 24
	stur x30, [SP, 16]
	stur x4, [SP, 8]
	stur x5, [SP, 0]

	mov x4, 1
	bl paint_pixel
loopIT:
	bl paint_horizontal_row  // Paint row 
	sub x1, x1, 1  
	bl paint_horizontal_row

	sub x1, x1, 1  
	sub x2, x2, 1  // Next row

	add x4, x4, 2  // Increment row size

	sub x5, x5, 1  // Decrement height counter
	cmp xzr, x5    // Compare with 0
	b.lt loopIT     // If bigger than 0 repeat, else continue

	ldur x5, [SP, 0]
	ldur x4, [SP, 8]
	ldur x30, [SP, 16] //devolvidos! uwu 
	add SP, SP, 24         // devueltos che bolu

	ret x30      

paint_horizontal_row:
	// Paints an horizontal row given a (x,y) coords (x2,x1) a length (x4) and a color (x3)  
	
	sub SP, SP, 8
	stur x30, [SP, 0]

	mov x10, x4
loopHR:
	bl paint_pixel    // Paint pixel
	add x2, x2, 1     // Next pixel
	sub x10, x10, 1   // Decrement length counter
	cmp xzr, x10      // Compare with 0
	b.lt loopHR       // If bigger than 0 repeat, else continue
	sub x2, x2, x4    // Reset X coord

	ldur x30, [SP, 0]
	add SP, SP, 8

	ret x30

paint_vertical_row:
	// Paints an horizontal row given a (x,y) coords (x2,x1) a height (x5) and a color (x3) 

	sub SP, SP, 8
	stur x30, [SP, 0]

	mov x10, x5
loopVR:
	bl paint_pixel    // Paint pixel
	add x1, x1, 1     // Next pixel
	sub x10, x10, 1   // Decrement length counter
	cmp xzr, x10      // Compare with 0
	b.lt loopVR       // If bigger than 0 repeat, else continue
	sub x1, x1, x5    // Reset Y coord

	ldur x30, [SP, 0]
	add SP, SP, 8

	ret x30

draw_circle:
	// Draws a circle given a (x0, y0) center coords (x2, x1) a radius (x4) and a color (x3)
	
	sub SP, SP, 8
	stur x30, [SP, 0]
	
	mov x6, x2           // Save center coords
	mov x5, x1

	add x7, x1, x4       // Save end of vertical lines
	add x8, x2, x4       // Save end of horizontal line

	sub x2, x2, x4
	sub x1, x1, x4         // set the coords to the leftmost top corner of the square r^2

	smull x15, w4, w4       // save r^2

loopcircle:

	sub x14, x2, x6 
	smull x14, w14, w14       // (X - x0)^2

	sub x13, x1, x5
	smull x13, w13, w13       // (Y - y0)^2

	add x13, x13, x14       // add results

	cmp x15, x13
	b.le skip_paint

	bl paint_pixel

skip_paint:

	add x2, x2, 1
	cmp x8, x2
	b.ne loopcircle

	sub x2, x2, x4
	sub x2, x2, x4          // Reset x coord

	add x1, x1, 1
	cmp x7, x1
	b.ne loopcircle
	
	ldur x30, [SP, 0]
	add SP, SP, 8

	ret x30 

paint_rocket:
	// Paints the rocket given a (x,y) coords of the tip (x2,x1)

	sub SP, SP, 32  // adjust stack to make room for 3 items
	stur x30, [SP, 24]
	stur X1, [SP, 16]  // save register X1 for use afterwards
	stur X2, [SP, 8]  // save register X2 for use afterwards
	stur x3, [SP, 0]  // ``
        
	mov x5, 23   
	movz x3, 0xFF, lsl 16
	movk x3, 0x0F12, lsl 00   
	bl paint_triangle

    sub x2, x2, 1
		// Paint the body of the rocket
	mov x4, 48       
	add x5, x5, 105     
	movz x3, 0x5A, lsl 16      
	movk x3, 0x5454, lsl 00
	bl paint_rectangle

	add x2, x2, 1  
	add x1, x1, 14 
	sub x4, x4, 2  
	bl paint_rectangle

	add x2, x2, 1   
	add x1, x1, 14  
	sub x4, x4, 2   
	bl paint_rectangle

	sub x2, x2, 3 
	sub x1, x1, 25 
    
    mov x26, x5   // save x5

	mov x5, 100   
	mov x9, 40  
LSLoop:
	bl paint_vertical_row           // 2 Loops to give depth to the sides of the rocket
	sub x2, x2, 1                
	add x1, x1, 3                 
	sub x5, x5, 10
	cmp x9, x5
	b.ne LSLoop
    add x2, x2, 6 
    sub x1,x1,18 

	add x2, x2, 49  
	mov x5, 100
RSLoop:
	bl paint_vertical_row
	add x2, x2, 1                
	add x1, x1, 3				 
	sub x5, x5, 10
	cmp x9, x5
	b.ne RSLoop
    sub x2,x2,6 
    sub x1,x1,18 
    mov x5, x26 

	// Paint the base of the rocket (main thruster)
	sub x2, x2, 49  
	add x1, x1, 153
	mov x4, 49                     
	mov x5, 16
	movz x3, 0xC1, lsl 16
	movk x3, 0xBEBF, lsl 00
	bl paint_rectangle

	// Paint right leg 
	add x2, x2, 60 
	sub x1, x1, 40  
	mov x4, 12
	mov x5, 64
	movz x3, 0xFF, lsl 16         
	movk x3, 0x0F12, lsl 00
	bl paint_rectangle

    
	add x2, x2, 5  
	sub x1, x1, 12 
	mov x5, 6
    mov x21, x1
    mov x22, x2
	bl paint_triangle
    mov x1, x21
    mov x2, x22

	// Paint left leg 
	sub x2, x2, 87  
    add x1, x1, 14 
	mov x4, 12            
	mov x5, 64
	bl paint_rectangle

	add x2, x2, 6  
	sub x1, x1, 12  
	mov x5, 6
	mov x21, x1
    mov x22, x2
	bl paint_triangle
    mov x1, x21
    mov x2, x22

	// Paint right leg support
	add x2, x2, 65 
	add x1, x1, 2

	mov x5, 18
	movz x3, 0x20, lsl 16        
	movk x3, 0x363D, lsl 00     
	mov x9, 11
RlegSupport:
	bl paint_vertical_row
	add x1, x1, 2
	add x2, x2, 1
	add x3, x3, 512
	sub x9, x9, 1
	cmp xzr, x9
	b.lt RlegSupport

    sub x1, x1, 22 // x1= 214 retoma los valores del loop
    sub x2, x2, 11 // x2 = 345  retoma los valroes del loop

	// Paint left leg support	
	sub x2, x2, 49
	mov x5, 18 
	movz x3, 0x20, lsl 16        
	movk x3, 0x363D, lsl 00        
	mov x9, 11
LlegSupport:
	bl paint_vertical_row
	add x1, x1, 2
	sub x2, x2, 1
	add x3, x3, 512
	sub x9, x9, 1
	cmp xzr, x9
	b.lt LlegSupport
    add x2, x2, 11 
    sub x1, x1, 22   

		// Paint middle leg 
	add x2, x2, 19  
	add x1, x1, 10  
 	mov x4, 11                        
	mov x5, 70
	movz x3, 0xFF, lsl 16        
	movk x3, 0x0F12, lsl 00
	bl paint_rectangle

	add x2, x2, 5   
	sub x1, x1, 12 
	mov x5, 6
    mov x21, x1
    mov x22, x2
	bl paint_triangle
    mov x1, x21
    mov x2, x22

	   // Paint window 
	add x2, x2, 1
	sub x1, x1, 60  
	mov x4, 22                              
	movz x3, 0x00, lsl 16
	movk x3, 0x0000, lsl 00
	bl draw_circle           // hola profe agus! 

	add x2, x2, 22
	sub x1, x1, 22
	mov x4, 20
	movz x3, 0xC1, lsl 16
	movk x3, 0xBEBF, lsl 00
	bl draw_circle                      
											
	add x2, x2, 20
	sub x1, x1, 20
	mov x4, 18
	movz x3, 0x00, lsl 16
	movk x3, 0x0000, lsl 00
	bl draw_circle

	add x2, x2, 18
	sub x1, x1, 18
	mov x4, 16
	movz x3, 0x4C, lsl 16
	movk x3, 0x9695, lsl 00 
	bl draw_circle

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16] 
	ldur x30, [SP, 24]
	add SP, SP, 32  

	ret x30

draw_star1:
	// Draws a star (type 1) given (x,y) coordinates (x2,x1) (static size and color)

	sub SP, SP, 32 
	stur x30, [SP, 24] 
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0]  

	mov x5, 10
	movz x3, 0xFF, lsl 16
	movk x3, 0xBD00, lsl 00   
	mov x9, x5

	bl paint_triangle
	
	add x2, x2, 10
	add x1, x1, 5

	mov x5, x9
	bl paint_inverted_triangle

	mov x5, 5
	movz x3, 0xFF, lsl 16
	movk x3, 0xFFCB, lsl 00 

	add x2, x2, 10
	add x1, x1, 1

	bl paint_triangle
	
	add x2, x2, 5
	add x1, x1, 3

	mov x5, 5
	bl paint_inverted_triangle

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32  

	ret x30

draw_bg_stars1:
// Paint stars!!!!!!!!!!!!!!!!!
	sub SP, SP, 32 
	stur x30, [SP, 24] 
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0]  

	add x2, x2, 50
	add x1, x1, 100

	bl draw_star1

	add x2, x2, 500
	add x1, x1, 150
	bl draw_star1

	sub x2, x2, 400
	add x1, x1, 100
	bl draw_star1

	add x2, x2, 300
	sub x1, x1, 320
	bl draw_star1

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32  
	
	ret x30

draw_star2:
// Draws a star (type 2)given (x,y) coordinates (x2,x1) (static size and color)

	sub SP, SP, 32 
	stur x30, [SP, 24] 
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0]  

	mov x4, 9
	mov x5, 9
	movz x3, 0xFF, lsl 16
	movk x3, 0xFF5C, lsl 00 
	bl paint_rectangle
    
	add x2, x2, 3
	add x1, x1, 9
	mov x4, 3
	mov x5, 6
	bl paint_rectangle

	sub x1, x1, 15
	bl paint_rectangle

	add x1, x1, 9
	add x2, x2, 6
	mov x4, 6
	mov x5, 3
	bl paint_rectangle

	sub x2, x2, 15
	bl paint_rectangle

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16] 
	ldur x30, [SP, 24]
	add SP, SP, 32  

	ret x30

draw_bg_stars2:
// Paint  MORE stars!!!!!!!!!!!!!!!!!
	sub SP, SP, 32
	stur x30, [SP, 24]  
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0] 

	add x2, x2, 200
	add x1, x1, 40

	bl draw_star2

	sub x2, x2, 100
	add x1, x1, 200
	bl draw_star2
	
	add x2, x2, 380
	add x1, x1, 150
	bl draw_star2

	add x2, x2, 50
	sub x1, x1, 270
	bl draw_star2

	sub x2, x2, 500
	add x1, x1, 220
	bl draw_star2

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32

	ret x30

draw_star3:
// Draws a star (type 3)given (x,y) coordinates (x2,x1) (static size and color)

	sub SP, SP, 32
	stur x30, [SP, 24]  
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0] 

	mov x4, 6
	mov x5, 6
	movk x3, 0x18, lsl 16
	movk x3, 0x89DA, lsl 00 
	bl paint_rectangle

	sub x2, x2, 2
	add x1, x1, 2
	mov x4, 10
	mov x5, 2
	bl paint_rectangle

 	add x2, x2, 4
	sub x1, x1, 4
	mov x4, 2
	mov x5, 10
	bl paint_rectangle

	sub x2,x2, 2
	add x1, x1, 4
	mov x4, 6
	mov x5, 2
	movk x3, 0x92, lsl 16
	movk x3, 0xC9F0, lsl 00 
	bl paint_rectangle

	add x2, x2, 2
	sub x1, x1, 2
	mov x4, 2
	mov x5, 6
	bl paint_rectangle

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16] 
	ldur x30, [SP, 24]
	add SP, SP, 32
	
	ret x30
draw_bg_stars3:
// yes, MORE stars 
	sub SP, SP, 32
	stur x30, [SP, 24]  
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0] 

	add x2, x2, 175
	add x1, x1, 150

	bl draw_star3

	add x2, x2, 250
	add x1, x1, 80
	bl draw_star3

	sub x2, x2, 360
	add x1, x1, 180
	bl draw_star3

	add x2, x2, 490
	sub x1, x1, 60
	bl draw_star3

	add x2, x2, 5
	sub x1, x1, 320
	bl draw_star3

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32

	ret x30

draw_bg_planets:
// Now planets, paint some planets
	sub SP, SP, 32
	stur x30, [SP, 24]  
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0] 

	// Draw medium planet  (Moon-like)
	add x2, x2, 80
	add x1, x1, 60
	mov x4, 40
	movz x3, 0x71, lsl 16
	movk x3, 0x7171, lsl 00
	bl draw_circle

	add x2, x2, 25
	sub x1, x1, 50
	mov x4, 15
	movz x3, 0x61, lsl 16
	movk x3, 0x6161, lsl 00
	bl draw_circle

	add x2, x2, 25
	add x1, x1, 20
	mov x4, 5
	bl draw_circle

	add x2, x2, 30
	sub x1, x1, 25
	mov x4, 10
	bl draw_circle

	// Draw big planet   (Gaseous-like)
	add x2, x2, 250
	add x1, x1, 320  // 370
	mov x4, 55
	movz x3, 0x3B, lsl 16
	movk x3, 0x7151, lsl 00
	bl draw_circle

	add x2, x2, 1
	sub x1, x1, 65
	mov x4, 109
	mov x5, 21
	movz x3, 0x7C, lsl 16
	movk x3, 0xC49A, lsl 00
	bl paint_rectangle

	add x2, x2, 8
	sub x1, x1, 19
	mov x4, 93
	mov x5, 2
	bl paint_rectangle

	sub x2, x2, 6
	add x1, x1, 45
	mov x4, 105
	bl paint_horizontal_row

	add x2, x2, 4
	add x1, x1, 8
	mov x4, 97
	mov x5, 3
	bl paint_rectangle

	add x2, x2, 1
	mov x4, 95
	bl paint_horizontal_row

	// Draw small planet  (Ringed)
	add x2, x2, 250
	sub x1, x1, 253 // 303
	mov x4, 90
	mov x5, 3
	movz x3, 0x90, lsl 16
	movk x3, 0x853B, lsl 00
	bl paint_rectangle

	add x2, x2, 44
	add x1, x1, 3
	mov x4, 30
	movz x3, 0xD9, lsl 16
	movk x3, 0xC753, lsl 00
	bl draw_circle

	sub x2, x2, 14
	sub x1, x1, 27
	mov x4, 90
	mov x5, 3
	movz x3, 0x90, lsl 16
	movk x3, 0x853B, lsl 00
	bl paint_rectangle

	sub x2, x2, 1
	sub x1, x1, 3
	mov x4, 10
	mov x5, 3
	movz x3, 0x90, lsl 16
	movk x3, 0x853B, lsl 00
	bl paint_rectangle

	add x2, x2, 82
	mov x4, 10
	mov x5, 3
	bl paint_rectangle

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32

	ret x30

paint_fire:
// Fire fisrt frame
	sub SP, SP, 32
	stur x30, [SP, 24]  
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0] 

	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00      
	sub x2, x2, 25
	add x1, x1, 230

	mov x4, 4  
	mov x5, 28
	bl paint_rectangle//1

	add x2, x2, 4 
	sub x1, x1, 4 
	bl paint_rectangle //2

	add x2, x2, 4 
	sub x1, x1, 4 
	mov x5, 36
	bl paint_rectangle //3

	add x2, x2, 4 
	sub x1, x1, 4
	mov x5, 48
	bl paint_rectangle //4

	add x2, x2, 4   
	mov x5, 52
	bl paint_rectangle //5

	add x2, x2, 4 
	mov x5, 48
	bl paint_rectangle //6

	add x2, x2, 4 
	mov x5, 64
	bl paint_rectangle //7 

	add x2, x2, 4 
	mov x5, 76
	bl paint_rectangle //8 

	add x2, x2, 4
	mov x5, 60
	bl paint_rectangle //9 

	add x2, x2, 4 
	add x1, x1, 4
	mov x5, 48
	bl paint_rectangle //10

	add x2, x2, 4  
	add x1, x1, 4 
	mov x5, 40
	bl paint_rectangle //11 

	add x2, x2, 4
	add x1, x1, 4   
	mov x5, 32
	bl paint_rectangle //12 

	// parte amarilla del fuego
	movz x3, 0xFB, lsl 16
	movk x3, 0xEC37, lsl 00  
		
	sub x2, x2, 16
	add x1, x1, 20
	mov x5, 12
	bl paint_rectangle //9

	sub x1, x1, 16
	bl paint_rectangle //8 

	sub x2, x2, 4 
	sub x1, x1, 4 
	mov x5, 28
	bl paint_rectangle //7

	sub x2, x2, 4 
	mov x5, 24
	bl paint_rectangle //6

	sub x2, x2, 4 
	mov x5, 16
	bl paint_rectangle //5

	sub x2, x2, 4  
	add x1, x1, 4  
	mov x5, 8
	bl paint_rectangle //4

	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00

	add x1, x1, 16   
	mov x5, 4
	bl paint_rectangle

	sub x2, x2, 8 
	add x1, x1, 12 
	bl paint_rectangle

	add x2, x2, 4 
	add x1, x1, 12
	bl paint_rectangle

	add x2, x2, 8
	add x1, x1, 4
	bl paint_rectangle

	add x2, x2, 4
	add x1, x1, 16
	bl paint_rectangle

	sub x1, x1, 36
	bl paint_rectangle

	add x2, x2, 8 
	add x1, x1, 44 
	bl paint_rectangle

	add x2, x2, 8
	sub x1, x1, 12
	bl paint_rectangle

	add x2, x2, 4
	sub x1, x1, 16
	bl paint_rectangle

	add x1, x1, 32 
	bl paint_rectangle

	sub x2, x2, 12 
	sub x1, x1, 36
	bl paint_rectangle

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32

	ret x30

// --------------------------------------------

paint_fire2:
// Fire second frame
	sub SP, SP, 32
	stur x30, [SP, 24]  
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0] 

	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00      
	add x1, x1, 230
	sub x2, x2, 25
    
	add x2, x2, 44
	mov x4, 4  
	mov x5, 28
	bl paint_rectangle//1

	sub x2, x2, 4 
	sub x1, x1, 4 
	bl paint_rectangle //2

	sub x2, x2, 4 
	sub x1, x1, 4
	mov x5, 36
	bl paint_rectangle //3

	sub x2, x2, 4 
	sub x1, x1, 4 
	mov x5, 48
	bl paint_rectangle //4

	sub x2, x2, 4 
	mov x5, 52
	bl paint_rectangle //5

	sub x2, x2, 4 
	mov x5, 48
	bl paint_rectangle //6

	sub x2, x2, 4
	mov x5, 64
	bl paint_rectangle //7 

	sub x2, x2, 4  
	mov x5, 76
	bl paint_rectangle //8 

	sub x2, x2, 4 
	mov x5, 60
	bl paint_rectangle //9 

	sub x2, x2, 4 
	add x1, x1, 4 
	mov x5, 48
	bl paint_rectangle //10

	sub x2, x2, 4  
	add x1, x1, 4  
	mov x5, 40
	bl paint_rectangle //11 

	sub x2, x2, 4 
	add x1, x1, 4 
	mov x5, 32
	bl paint_rectangle //12 

	// parte amarilla del fuego
	movz x3, 0xFB, lsl 16
	movk x3, 0xEC37, lsl 00  
		
	add x2, x2, 16  
	add x1, x1, 20  
	mov x5, 12
	bl paint_rectangle //9

	sub x1, x1, 16
	bl paint_rectangle //8

	add x2, x2, 4 
	sub x1, x1, 4
	mov x5, 28
	bl paint_rectangle //7

	add x2, x2, 4
	mov x5, 24
	bl paint_rectangle //6

	add x2, x2, 4
	mov x5, 16
	bl paint_rectangle //5

	add x2, x2, 4
	add x1, x1, 4
	mov x5, 8
	bl paint_rectangle //4

	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00

	add x1, x1, 16
	mov x5, 4
	bl paint_rectangle

	add x2, x2, 8
	add x1, x1, 12
	bl paint_rectangle

	sub x2, x2, 4
	add x1, x1, 12
	bl paint_rectangle

	sub x2, x2, 8
	add x1, x1, 4
	bl paint_rectangle

	sub x2, x2, 4
	add x1, x1, 16
	bl paint_rectangle

	sub x1, x1, 36
	bl paint_rectangle

	sub x2, x2, 8
	add x1, x1, 44
	bl paint_rectangle

	sub x2, x2, 8 
	sub x1, x1, 12 
	bl paint_rectangle

	sub x2, x2, 4 
	sub x1, x1, 16 
	bl paint_rectangle

	add x1, x1, 32
	bl paint_rectangle

	add x2, x2, 12
	sub x1, x1, 36
	bl paint_rectangle

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32

	ret x30

paint_fire3:
// Fire third frame
	sub SP, SP, 32
	stur x30, [SP, 24]  
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0] 

	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00      

	add x1, x1, 230
	sub x2, x2, 25

	mov x4, 4
	mov x5, 34
	bl paint_rectangle //1 

	add x2, x2, 4
	sub x1, x1, 4
	mov x5, 42
	bl paint_rectangle //2 

	add x2, x2, 4
	sub x1, x1, 4
	bl paint_rectangle //3

	add x2, x2, 4
	sub x1, x1, 4 
	mov x5, 58
	bl paint_rectangle //4

	add x2, x2, 4
	mov x5, 76
	bl paint_rectangle //5

	add x2, x2, 4
	mov x5, 62
	bl paint_rectangle //6

 	add x2, x2, 4 
	mov x5, 64
	bl paint_rectangle //7 

	add x2, x2, 4
	mov x5, 70
	bl paint_rectangle //8 

	add x2, x2, 4 
	mov x5, 60
	bl paint_rectangle //9 

	add x2, x2, 4 
	add x1, x1, 4
	mov x5, 40
	bl paint_rectangle //10

	add x2, x2, 4
	add x1, x1, 4
	bl paint_rectangle //11 

	add x2, x2, 4
	add x1, x1, 4  
	mov x5, 32
	bl paint_rectangle //12 
	// parte amarilla del fuego

    movz x3, 0xFB, lsl 16
	movk x3, 0xEC37, lsl 00  

	sub x2, x2, 12 
	add x1, x1, 4  
	mov x5, 16
	bl paint_rectangle //0 amarila
		
	sub x2, x2, 4  // x = 324 y = 310
	sub x1, x1, 6
	mov x5, 38
	bl paint_rectangle //1 amarila

	sub x2, x2, 4
	mov x5, 34
	bl paint_rectangle //2 amarila

	sub x2, x2, 4
	mov x5, 42
	bl paint_rectangle //3 amarila

	sub x2, x2, 4
	mov x5, 36
	bl paint_rectangle //4 amarila

	sub x2, x2, 4
	add x1, x1, 8 
	mov x5, 16
	bl paint_rectangle //5 amarila

 	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00       // chispitaaas!  

	sub x2, x2, 12  // x = 300
	add x1, x1, 44 // y = 324
	mov x5, 4
	bl paint_rectangle

	add x2, x2, 4
	add x1, x1, 12
	bl paint_rectangle

	add x2, x2, 8 
	add x1, x1, 4 
	bl paint_rectangle

	add x2, x2, 4 
	add x1, x1, 16 
	bl paint_rectangle

	sub x1, x1, 36 
	bl paint_rectangle

	add x2, x2, 16 
	add x1, x1, 32 
	bl paint_rectangle

	add x2, x2, 4
	sub x1, x1, 16 
	bl paint_rectangle
 
	sub x2, x2, 12 
	sub x1, x1, 4 
	bl paint_rectangle

	add x2, x2, 16
	sub x1, x1, 12
	bl paint_rectangle

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32

	ret x30

paint_fire4:
// Fire fourth frame
	sub SP, SP, 32
	stur x30, [SP, 24]  
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0] 

	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00      

	add x1, x1, 230
	sub x2, x2, 25

	mov x4,4
	mov x5,44
	bl paint_rectangle //1 

	add x2, x2, 4 
	sub x1, x1, 4
	mov x5, 42
	bl paint_rectangle //2 

	add x2, x2, 4
	sub x1, x1, 4
	mov x5, 38
	bl paint_rectangle //3

	add x2, x2, 4
	sub x1, x1, 4 
	mov x5, 43
	bl paint_rectangle //4

	add x2, x2, 4
	mov x5, 50
	bl paint_rectangle //5

	add x2, x2, 4
	mov x5, 48
	bl paint_rectangle //6

 	add x2, x2, 4 
	mov x5, 47
	bl paint_rectangle //7 

	add x2, x2, 4 
	mov x5, 50

	bl paint_rectangle //8 

	add x2, x2, 4 
	mov x5, 54
	bl paint_rectangle //9 

	add x2, x2, 4  
	add x1, x1, 4
	mov x5, 40
	bl paint_rectangle //10

	add x2, x2, 4  
	add x1, x1, 4  
	mov x5, 44
	bl paint_rectangle //11 

	add x2, x2, 4 
	add x1, x1, 4 
	mov x5, 46
	bl paint_rectangle //12 
	// parte amarilla del fuego

    movz x3, 0xFB, lsl 16
	movk x3, 0xEC37, lsl 00  

	sub x2, x2, 12 
	add x1, x1, 4
	mov x5, 16
	bl paint_rectangle //0 amarila
		
	sub x2, x2, 4  // x = 324 y = 310
	sub x1, x1, 6
	mov x5, 32
	bl paint_rectangle //1 amarila

	sub x2, x2, 4
	mov x5, 20
	bl paint_rectangle //2 amarila

	sub x2, x2, 4 
	mov x5, 22
	bl paint_rectangle //3 amarila

	sub x2, x2, 4
	mov x5, 28
	bl paint_rectangle //4 amarila

	sub x2, x2, 4
	add x1, x1, 8  
	mov x5, 16
	bl paint_rectangle //5 amarila

 // chispitaaas!  

 	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00      

	sub x2, x2, 8 
	add x1, x1, 44 
	mov x5, 4
	bl paint_rectangle

	add x2, x2, 4
	add x1, x1, 12
	bl paint_rectangle

	add x2, x2, 8
	add x1, x1, 4
	bl paint_rectangle

	add x2, x2, 4
	sub x1, x1, 20
	bl paint_rectangle

	add x2, x2, 20 
	add x1, x1, 16
	bl paint_rectangle
 
	sub x2, x2, 12 
	sub x1, x1, 8
	bl paint_rectangle

	add x2, x2, 16
	sub x1, x1, 4
	bl paint_rectangle 

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32

	ret x30

	// --------------------------------------------------------------------

background_pattern:
    // Paints stars given a width and a height (x7=x4,x8=x5), a color (x3) and a distance between them (x6)
  
	sub SP, SP, 32
	stur x30, [SP,24]  
	stur X1, [SP, 16]  
	stur X2, [SP, 8]  
	stur x3, [SP, 0] 

    mov x21, x1
    mov x22, x2

    mov x23, x5 // x23 = x1 
    mov x24, x4 // x24 = x2

loop2:
    mov x7, x4
    mov x8, x5
    bl paint_rectangle
    add x24, x24, x6
    add x2, x2, x6
    cmp x24, 640

    b.gt endrow

    b loop2

endrow:
    sub x24, x24, 640
    add x23, x23, x6
    add x1, x1, x6
    cmp x23, 480
    b.gt endcolumn

    b loop2

endcolumn:
    mov x1, x21
    mov x2, x22
    mov x4, x7
    mov x5, x8

	ldur X3, [SP, 0]  
	ldur X2, [SP, 8]  
	ldur X1, [SP, 16]
	ldur x30, [SP, 24] 
	add SP, SP, 32

    ret x30

	// -------------------- END ---------------------------

exit:
InfLoop: 
	b InfLoop


