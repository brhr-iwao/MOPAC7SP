### MOPAC 7 SP

#### What is MOPAC 7 SP ?
[MOPAC](http://openmopac.net) is a well-known semi-empirical molecular orbital calculation package and MOPAC 7 is the latest public domain distribution of it.  
 MOPAC 7 SP is a improved MOPAC 7 package which can be performed COSMO (Conductor-like solvation model) calculation in some extent. PM6 is not available.

#### Description
How to build MOPAC 7 SP for Windows with [MinGW](http://www.mingw.org) make and gfortran.
1. Download [the archived MOPAC 7 source ](http://www.ccl.net/cca/software/SOURCES/FORTRAN/mopac7_sources/mopac7.tar.Z) from [CCL](http://www.ccl.net/) and unpack it.
2. Rename esp.rof to esp.f and remove fdummy.f to avoid a multiple definition error (subroutine greenf is defined in both of fdummy.f and greenf.f).
3. Apply [the patch file (named "changes" ) by Serge Pachkovsky](http://www.ccl.net/cca/software/MS-DOS/mopac_for_dos/mopac7/changes) (which is also packed in  [the mop7sp.zip package](https://github.com/brhr-iwao/MOPAC7SP/releases) ) to the unpacked original MOPAC 7 sources with a patching tool such as [GnuWin32 patch](http://gnuwin32.sourceforge.net/packages/patch.htm).  
 > patch < changes

 Execute this command on the Windows command prompt. Patch.exe must be in the same directory as MOPAC 7 sources, otherwise environmental variable PATH must include the path to the directory which patch.exe is located. Make sure that the text file "changes" uses CR-LF as line endings before execution.    
 [GnuWin32 patch](http://gnuwin32.sourceforge.net/packages/patch.htm) may not work on Windows Vista or later for administration right. The problem is caused of the absence of the manifest in the executable. The manifest embedded GnuWin32 patch.exe is also provided in [the mop7sp.zip package](https://github.com/brhr-iwao/MOPAC7SP/releases).    
 Press ENTER to skip when you ask the two following questions during patching
>The next patch would delete the file esp.f.orig,   
>which does not exist!  Assume -R? [n]

 and

 >Apply anyway? [n]

 Even if you meet the message "patch unexpectedly ends in middle of line", it can be ignored.  

4. Edit the line 1045 in symtrz.f.    
Edit
```
 DATA TOLER,IFRA /  0.1, '????'/
```
to
```
C DATA TOLER,IFRA /  0.1, '????'/
 DATA TOLER,IFRA /  0.1, 0.0/
```
 The variable "IFRA" is CHARACTER*4 type in the original MOPAC 7. After patching the type of "IFRA" is changed to double precision floating point type because "IMPLICIT DOUBLE PRECISION (A-H,O-Z)" is declared.

5. Edit the line 948 in esp.f (originally esp.rof)    
Edit
```
         OPEN(21,STATUS='NEW')
```
to
```
C         OPEN(21,STATUS='NEW')
          OPEN(21,FILE='FOR021',STATUS='NEW')
```    

6. Edit the line 48 in SIZES.  
Edit
```
 PARAMETER (LENABC=400)
```
to
```
  PARAMETER (LENABC=800)
```
 The size of the array NSETF(LENABC) which declared in const.f may be too small for some calculations (Access violation may occur on NSET(NSETF(IPM)+NARA)=J in the line 303 in consts.f for these cases).     
7. Edit the subroutine getdat which defined in mopac.f. After this the executable get its input as program argument. It really does not have any meanings if you use the traditional input file "FOR005", you can omit it.   
Insert the following five lines between the line 238 (DATA I/0/) and 239 (`C#      WRITE(6,*)GETNAM('FOR005')`).   

 ```
      character*128 ARG    
      integer ARGLEN
      call GETARG(1,ARG)
      ARGLEN=LEN(ARG)
      OPEN(2,FILE=ARG(1:ARGLEN),STATUS='OLD')
 ```

 And comment out the line 240 (the original OPEN statement) in mopac.f.
 ```
C OPEN(UNIT=2,FILE=GETNAM('FOR005'),STATUS='UNKNOWN')
 ```

8.  It is described here the way to make with [Mingw](http://www.mingw.org) make and gfortran. Rename "the original" Makefile to Makefile.old or remove it. To make with Mingw make and g95, use the following new Makefile:

```
TARGET = mop7sp.exe

FC = gfortran

RM = rm

FFLAGS = -g -O2 -std=legacy -fno-automatic

SRC = $(wildcard *.f)
OBJ = $(SRC:.f=.o)

.SUFFIXES: f. .o
.f.o:
	$(FC) -c $(FFLAGS) $<


.PHONY: all
all: $(TARGET)

$(TARGET): $(OBJ)
	$(FC) -o $(TARGET) $^


.PHONY: clean
clean:
		-$(RM) $(TARGET)
		-$(RM) $(OBJ)
   ```

 #### How to use MOPAC 7 SP for Windows.
 1. Prepare your input file. A input file is a simple text file. The first line is the list of keyword to specify the calculation type. The second and third lines are the title and other information for notes. The fourth line and below lines are the definition of the internal coordinate (z-matix) or the Cartesian coordinate of the molecule (the last line must be blank to terminate the geometry definition).  For detail, refer to the mopac 7 manual (mopac.pdf) packed in [the mop7sp.zip package](https://github.com/brhr-iwao/MOPAC7SP/releases) or many descriptive web pages. It is convenient to use a GUI application such as [Avogadro](https://avogadro.cc) or [OpenBabel GUI](https://openbabel.org/wiki/OpenBabelGUI) for building z-matrix or input.
 2. Copy your input file to the directory with mop7sp.exe. Open the Windows command prompt and change the current directory to the directory with mop7sp.exe. Execute the following command on the command prompt:   
 
  > mop7sp.exe *YourInputFileName*      

  Wait until finishing the calculation (from a second to several minutes dependent on the input). Output files (see the bellow Appendix) are generated in the current directory.    
 3. If you drag and drop your input file on the mop7sp.exe icon, output files are generated in C:\Documents and Settings\ *UserName* for Windows XP/2000 (C:\Users\ *UserName* for Windows Vista or later) defined as the USERPROFILE environmental variable. Take care that output files are NOT generated the current directory (i.e. the directory with either mop7sp.exe or your input file) in this case.

#### Appendix
|file name | description  | extension  |
|----------|--------------|------------|
|FOR005    |input file    |  .dat      |
|FOR006    |output file   |  .out      |
|FOR009    |restart file  |  .res      |
|FOR010    |density matrix file  |  .den      |
|FOR011    |log file      |  .log      |
|FOR012    |archive or summary file  |  .arc      |
|FOR013    |graphic file  |  .gpt    |
|FOR016    |SYBYL file    |  .syb    |

#### Contact
[Aoyama Iwao](https://github.com/brhr-iwao)
