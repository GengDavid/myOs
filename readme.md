# myos
This is my os. 
But there are many bugs.
# How to use
## Just run
You can load test.img as floppy disk to run this os via Vmware
## Compile
using DOSBox to compile and link ```c.c``` and ```os.asm``` using code as follows:
```
delete os.obj
tcc -mt -c c.obj c.c
tasm os.asm os.obj
tlink /3 /t os.obj c.obj , os.com,,
```
TCC and TASM are in directory ```TCC_TASM```
Then using nasm to compile other ```.asm``` files 
(You can also compile automatically using ```compile.bat``` in the root directory ^_^).