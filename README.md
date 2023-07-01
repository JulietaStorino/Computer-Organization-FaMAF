#Computer Organization Project 2022

## Points to meet

* Display configuration: `640x480` pixels, `ARGB` format 32 bits.
* The `X0` register contains the base address of the FrameBuffer (Pixel 1)
* The code of each password must be written in the file _app.s_
* The _start.s_ file contains the initialization of the FrameBuffer, at the end it calls _app.s_ **(DO NOT EDIT)**
* The sample code paints the entire screen a single color

##Structure

* **[app.s](app.s)** This file contains an application. All hardware is already pre-initialized.
* **[start.s](start.s)** This file performs hardware initialization
* **[Makefile](Makefile)** File that describes how to build the software _(what assemble to use, what output to generate, etc)_
* **[memmap](memmap)** This file contains the description of the program's memory layout and where to place each section.
* **README.md** this file

## Use

The _Makefile_ file contains what is needed to build the project. Others can be used
**.s** files if it's convenient for you to clean up your code and the Makefile will assemble them

**To run the project run**

```bash
$ run
```
This will build the code and run qemu for emulation
