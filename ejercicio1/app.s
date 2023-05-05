.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGHT, 	480
.equ BITS_PER_PIXEL,  	32

.globl main
main:
	// X0 contiene la direccion base del framebuffer
 	mov x20, x0	// Save framebuffer base address to x20	

	movz x3, 0x00, lsl 16
	movk x3, 0x000E, lsl 00      // La animacion esta un cacho mejor documentada, explicada, y con un uso mas
	bl paint_background          // limpio de los registros gracias a que aprendimos un poco tarde a usar
                                 // el SP
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
	
	mov x2, 50
	mov x1, 100
	bl draw_bg_stars1

	mov x2, 200
	mov x1, 40
	bl draw_bg_stars2

	mov x2, 175
	mov x1, 150
	bl draw_bg_stars3

	bl draw_bg_planets

	mov x2, 296
	mov x1, 290
	bl paint_fire

	mov x2, 320
	mov x1, 100
	bl paint_rocket

	b exit
	
	// Functions : 

paint_background:           
	// paint background given a color (x3)
	
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
    mov x17, x30 
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

    ret x17

paint_triangle:
	// Paints a triangle given a (x,y) coords (x2, x1) a height (x5) and a color (x3)
	mov x17, x30
    mov x24, x4
    mov x25, x5
    mov x22, x2
    mov x21, x1
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
    mov x4, x24
    mov x5, x25
	ret x17

paint_inverted_triangle:
	// Paints an inverted triangle given a (x,y) coords (x2, x1) a height (x5) and a color (x3)
	mov x17, x30

    mov x24, x4 //guardar x4 y x5 para devolverselo al final
    mov x25, x5
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
    mov x4, x24
    mov x5, x25 //devolvidos! uwu
	ret x17

paint_horizontal_row:
	// Paints an horizontal row given a (x,y) coords (x2,x1) a length (x4) and a color (x3)  
	mov x16, x30
	mov x10, x4
loopHR:
	bl paint_pixel    // Paint pixel
	add x2, x2, 1     // Next pixel
	sub x10, x10, 1   // Decrement length counter
	cmp xzr, x10      // Compare with 0
	b.lt loopHR       // If bigger than 0 repeat, else continue
	sub x2, x2, x4    // Reset X coord

	ret x16

paint_vertical_row:
	// Paints an horizontal row given a (x,y) coords (x2,x1) a height (x5) and a color (x3) 
	mov x16, x30
	mov x10, x5
loopVR:
	bl paint_pixel    // Paint pixel
	add x1, x1, 1     // Next pixel
	sub x10, x10, 1   // Decrement length counter
	cmp xzr, x10      // Compare with 0
	b.lt loopVR       // If bigger than 0 repeat, else continue
	sub x1, x1, x5    // Reset Y coord

	ret x16

draw_circle:
	// Draws a circle given a (x0, y0) center coords (x2, x1) a radius (x4) and a color (x3)
	mov x16, x30 

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
	
	ret x16 

paint_rocket:
	// Paints the rocket given a (x,y) coords of the tip (x2,x1)
	mov x18, x30
    mov x2, 320
    mov x1, 100
        // Starting point x= 320 y = 100
		// Paint the tip of the rocket
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
    
    mov x26, x5 

	mov x5, 100    
	mov x9, 40  

LSLoop:
	bl paint_vertical_row
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
	sub x1, x1, 10 
	mov x5, 6
    mov x21, x1
    mov x22, x2
	bl paint_triangle
    mov x1, x21
    mov x2, x22

	// Paint left leg 
	sub x2, x2, 87  
    add x1, x1, 12 
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

	add x2, x2, 6   
	sub x1, x1, 12 
	mov x5, 6
    mov x21, x1
    mov x22, x2
	bl paint_triangle
    mov x1, x21
    mov x2, x22

	   // Paint window 
	sub x1, x1, 60 
	mov x4, 22                              
	movz x3, 0x00, lsl 16
	movk x3, 0x0000, lsl 00
	bl draw_circle

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
	
	ret x18

draw_star1:
	// Draws a star (type 1) given (x,y) coordinates (x2,x1) (static size and color)
	mov x18, x30
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

	ret x18

draw_bg_stars1:
	mov x19, x30

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
	
	ret x19 

draw_star2:
// Draws a star (type 2)given (x,y) coordinates (x2,x1) (static size and color)

	mov x18, x30
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

	ret x18

draw_bg_stars2:
	mov x19, x30

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

	ret x19

draw_star3:
// Draws a star (type 3)given (x,y) coordinates (x2,x1) (static size and color)
	mov x18, x30

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
	
	ret x18
draw_bg_stars3:
	mov x19, x30

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

	ret x19

draw_bg_planets:
	mov x18, x30
	mov x2, 0 
	mov x1, 0

	// Draw medium planet
	add x2, x2, 80
	add x1, x1, 10
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

	// Draw big planet
	add x2, x2, 250
	add x1, x1, 420
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

	// Draw small planet
	add x2, x2, 250
	sub x1, x1, 303 
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

	ret x18

paint_fire:
	// Paints the fire coming out of the rocket 
	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00      

	mov x18, x30

    mov x2,296
    mov x1,329
	mov x4, 4  
	mov x5, 28
	bl paint_rectangle//1

	add x2, x2, 4 
	sub x1, x1, 4 
	mov x4, 4  
	mov x5, 28
	bl paint_rectangle //2

	add x2, x2, 4 
	sub x1, x1, 4
	mov x4, 4  
	mov x5, 36
	bl paint_rectangle //3

	add x2, x2, 4 
	sub x1, x1, 4
	mov x4, 4  
	mov x5, 48
	bl paint_rectangle //4

	add x2, x2, 4 
	mov x4, 4  
	mov x5, 52
	bl paint_rectangle //5

	add x2, x2, 4 
	mov x4, 4  
	mov x5, 48
	bl paint_rectangle //6

	add x2, x2, 4 
	mov x4, 4  
	mov x5, 64
	bl paint_rectangle //7 

	add x2, x2, 4  
	mov x4, 4  
	mov x5, 76
	bl paint_rectangle //8 

	add x2, x2, 4
	mov x4, 4  
	mov x5, 60
	bl paint_rectangle //9 

	add x2, x2, 4 
	add x1, x1, 4
	mov x4, 4  
	mov x5, 48
	bl paint_rectangle //10

	add x2, x2, 4  
	add x1, x1, 4 
	mov x4, 4  
	mov x5, 40
	bl paint_rectangle //11 

	add x2, x2, 4 
	add x1, x1, 4 
	mov x4, 4  
	mov x5, 32
	bl paint_rectangle //12 

	// parte amarilla del fuego
	movz x3, 0xFB, lsl 16
	movk x3, 0xEC37, lsl 00  
		
	sub x2, x2, 16  
	add x1, x1, 20  
	mov x4, 4  
	mov x5, 12
	bl paint_rectangle //9

	sub x1, x1, 16
	mov x4, 4  
	mov x5, 12
	bl paint_rectangle //8

	sub x2, x2, 4 
	sub x1, x1, 4  
	mov x4, 4  
	mov x5, 28
	bl paint_rectangle //7

	sub x2, x2, 4  
	mov x4, 4  
	mov x5, 24
	bl paint_rectangle //6

	sub x2, x2, 4  
	mov x4, 4  
	mov x5, 16
	bl paint_rectangle //5

	sub x2, x2, 4  
	add x1, x1, 4  //
	mov x4, 4  
	mov x5, 8
	bl paint_rectangle //4

	movz x3, 0xEF, lsl 16        
	movk x3, 0x563C, lsl 00

	add x1, x1, 16    
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	sub x2, x2, 8  
	add x1, x1, 12 
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	add x2, x2, 4 
	add x1, x1, 12
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	add x2, x2, 8 
	add x1, x1, 4 
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	add x2, x2, 4
	add x1, x1, 16 
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	sub x1, x1, 36 
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	add x2, x2, 8 
	add x1, x1, 44 
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	add x2, x2, 8 
	sub x1, x1, 12 
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	add x2, x2, 4 
	sub x1, x1, 16 
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	add x1, x1, 32 
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	sub x2, x2, 12 
	sub x1, x1, 36 
	mov x4, 4
	mov x5, 4
	bl paint_rectangle

	ret x18

background_pattern:
    // Paints stars given a width and a height (x4,x5), a color (x3) and a distance between them (x6)
    mov x18, x30

    mov x21, x1
    mov x22, x2

    mov x23, x5 
    mov x24, x4 

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
    ret x18

exit:
InfLoop: 
	b InfLoop


