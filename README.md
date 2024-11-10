# ZXSpectrumChuckieEgg
Fully documented, reverse engineered source code to AnF's ZX Spectrum classic Chuckie Egg

## Preamble

Chuckie Egg was a classic, and highly addictive Spectrum platform game released in 1984 and written by a 17-year-old Nigel Alderton.  The game was published by the Manchester based A'n'F software. 

The game was one of the first ZX Spectrum titles with pixel based sprite movement (previously graphics moved one character, or 8 pixels, at a time due to the screen layout of the Spectrum).

## Assembling the Game 

The source code has been put together for SJAsmPlus and should assemble and generate a snapshot file right out of the box.  The code has a few added extras in there for disabling things like the speech (for the Fuller Orator) and the music (which drove me nuts!)  There's also a couple of EQUates you can set to disable collisions and make it so you only need to collect one egg to move on a level.  The resultant snapshop file is more or less identical to the game that shipped in 1984 other than I removed any left over, unused data and a few snippets of the original source code that were left behind in the original release.

## A Peek under the hood

### **The Sprites**

### **The Level Layout**

Each level map is made from and array 32 bytes wide by 21 lines high, stored from the bottom of the map to the top.  Each byte of the map represents a 8x8 bitmap graphic (and, separately, its corresponding colour attribute).  This means each level of the game takes 672 bytes to encode. 

### **Quirky Bits**

As mentioned previously the game levels are stored upside down with row 0 of the data representing row 21 of the screen.  On top of this the sprites are plotted with traditional Cartesian coordinates, in that y = 0 is the bottom of the screen, whereas normally y = 0 would be the top of the screen.  Not a big thing, just different.

There are a couple of calls into the Spectrum ROM; for the keyboard entry on the high score table. The games uses the system variables KSTATE and LASTK to determine what the last key that was pressed.  It also uses both the ROM beep routine and the Floating Point stack to work out pitch durations to feed into the ROM beep function for the music.

One other unusual thing to note is how the game gets out of the main loop upon collision.  The main game loop is called from the core game loop and when the main loop returns the game loop will then decide whether the player died or finished the level.  So far, so what?  In order to get out of some of the collision functions it could have been a few calls into the call stack, or have extra data PUSHED on the stack, so rather than flag the collisions all the way back up through the calling functions, the “death” routines will run a sequence of POP instructions to get back to where the main loop was originally called in the stack. When the function RETs it is returned to the point of the game loop call straight away, whereupon the game loop takes over lives lost / level being completed.

