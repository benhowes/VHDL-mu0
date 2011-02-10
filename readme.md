Ben Howes

===
Implementation of the mu0 processor and some memory in VHDL for EENG34040
===
This is intended largely for undergrads on eeng34040 at the University of Bristol, but help yourself all the same. More info can be found on the manchester universtity website.

Notes
---
I have decided to make all of the registers in separate files, though they will largly be the same thing. This will make it easy when we want to experiement with speed enhancements and caches. 

currently their is only a simple program which adds the contents of 256 (2) and 257 (4) and puts them in 258 (you'll have to run the program to find out!), then loops and does the same thing.

I am going to attempt to port a program to calculate something soon, so as we can all benchmark the same thing :)

I will give push access to anyone who wishes to share their code with the rest of us :)

Programming the processor
---
In order to program, simply use the command listings handed out in the lecture and start your commands from location 0. I have been a bit eager to get this info up, but I know that ADD, LDA, STO and JMP are fully functional. For faster debugging I limited the memory to 1K (x16).
This is intended for use in model sim!

What you can do with it
---
1. Make or port existing programs to the processor.
2. Time them.
3. Make buffers and caches; new data paths; various other things to speed up the processor and re test!



