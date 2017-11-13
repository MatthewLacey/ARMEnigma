# ARMEnigma
## Enigma Machine Simulator in ARM Assembly

This is a simulated Enigma Machine as used in WWII. There are three predefined cogs and a reflector. There is no switch board. To learn how the original Enigma Machine worked visit [here](http://enigma.louisedade.co.uk/howitworks.html).

To run, load file *final* onto ARM compatable machine (I used a raspberry pi)

`./final`

### Formatting Help:

#### Spacer Character:
To add a stop between words or sentences you can use an "X" character.
This is not required but it helps.

#### Encoding Numbers:
The Enigma Machine can only output letters. One way to send numbers is to
spell them out, but this is tedious and longer messages are easier to break.
The short hand for numbers on enigma is:
Q:1 W:2 E:3 R:4 T:5 Z:6 U:7 I:8 O:9 P:0
To include numbers in your message, you first need to indicate that you
are about to use a number by entering the letter "Y" before each number.
The number 8 would be YI and the number 57 would be YTU

#### Letter Blocks:
Your output should be put into letter blocks of four to six letters.

#### Emulator Commands:
**-h: display help menu
-t: switch between character and sentence input
-r: reinitialize cogs
-w: wipe screen
-q: quit Enigma**
