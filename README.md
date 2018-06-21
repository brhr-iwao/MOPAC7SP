### MOPAC 7 SP

#### What is MOPAC 7 SP ?
[MOPAC](http://openmopac.net) is a well-known semi-empirical molecular orbital calculation package and MOPAC 7 is the latest public domain distribution.  
 MOPAC 7 SP is an improved MOPAC 7 package on which you can do COSMO (Conductor-like solvation model) calculation to some extent.

#### Description
How to build MOPAC 7 SP for Windows with [MinGW](http://www.mingw.org) make and gfortran.
1. Download [the archived MOPAC 7 source ](http://www.ccl.net/cca/software/SOURCES/FORTRAN/mopac7_sources/mopac7.tar.Z) from [CCL](http://www.ccl.net/) and unpack it.
2. Rename esp.rof to esp.f and remove fdummy.f to avoid a multiple definition error (subroutine greenf is defined in both of fdummy.f and greenf.f).
3. Apply [the patch file (named "changes" ) by Serge Pachkovsky](http://www.ccl.net/cca/software/MS-DOS/mopac_for_dos/mopac7/changes) (which is also packed in  [the mop7sp.zip package](https://github.com/brhr-iwao/MOPAC7SP/Releases) ) to the unpacked original MOPAC 7 sources with a patching tool such as [GnuWin32 patch](http://gnuwin32.sourceforge.net/packages/patch.htm).  
 > patch < changes

 Execute this command on the Windows command prompt. Patch.exe must be in the same directory as MOPAC 7 sources, otherwise environmental variable PATH must include the path to the directory which patch.exe is located. Make sure that the text file "changes" uses CR-LF as line endings before execution.    
 [GnuWin32 patch](http://gnuwin32.sourceforge.net/packages/patch.htm) may not work on Windows Vista or later for administration right. The problem is caused of the absence of the manifest in the executable. The manifest embedded GnuWin32 patch.exe is also provided in [the mop7sp.zip package](https://github.com/brhr-iwao/MOPAC7SP/Releases).    
 Press ENTER to skip when you ask the two following questions during patching
>The next patch would delete the file esp.f.orig,   
>which does not exist!  Assume -R? [n]

 and

 >Apply anyway? [n]

 Even if you meet the message "patch unexpectedly ends in middle of line", it can be ignored.    
 In the following description, line numbers are these of after patching. (They are not line numbers of the original MOPAC 7 source codes)

4. Edit the line 1045 in symtrz.f.    
Change
```FORTRAN
 DATA TOLER,IFRA /  0.1, '????'/
```
to
```FORTRAN
C DATA TOLER,IFRA /  0.1, '????'/
 DATA TOLER,IFRA /  0.1, 0.0/
```
 The variable "IFRA" is CHARACTER*4 type in the original MOPAC 7. After patching the type of "IFRA" is changed to double precision floating point type because "IMPLICIT DOUBLE PRECISION (A-H,O-Z)" is declared.

5. Edit the line 48 in SIZES.  
Change
```FORTRAN
 PARAMETER (LENABC=400)
```
to
```FORTRAN
  PARAMETER (LENABC=800)
```
 The size of the array NSETF(LENABC) which declared in const.f may be too small for some calculations (Access violation may occur on NSET(NSETF(IPM)+NARA)=J in the line 303 in consts.f for these cases).

6. The editing described in this section is done to receive a input file name as a command argument and reflect it in the output file names. It really does not have any meanings if you use traditional file names such as "FOR005". In this case you can omit the description of the section (except editing of esp.f. See section 6-6.).    

  6-1. Edit the subroutine getdat in mopac.f.    
  Comment out the line 240 (the original OPEN statement) in mopac.f.
```FORTRAN
   C   OPEN(UNIT=2,FILE=GETNAM('FOR005'),STATUS='UNKNOWN')
```
And insert the following code block after the line 239 (`C#      WRITE(6,*)GETNAM('FOR005')`).   

 ```FORTRAN
 CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
/               GPTF*80,SYBF*80,ERR0*80,ERR1*80
 COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
 integer INLEN
 call GETARG(1,INF)
 INLEN=LEN_TRIM(INF)
 IF(INLEN==0) THEN
     INF='FOR005'
     OUTF='FOR006'
     RESF='FOR009'
     DENF='FOR010'
     LOGF='FOR011'
     ARCF='FOR012'
     GPTF='FOR013'
     SYBF='FOR016'
     ERR0='FOR020'
     ERR1='FOR021'
 else
    IF(index(inf,'.')==(INLEN-3)) THEN
       OUTF(1:(inlen-4))=INF(1:(inlen-4))
       OUTF((inlen-3):inlen)='.out'
       RESF(1:(inlen-4))=INF(1:(inlen-4))
       RESF((inlen-3):inlen)='.res'
       DENF(1:(inlen-4))=INF(1:(inlen-4))
       DENF((inlen-3):inlen)='.den'
       LOGF(1:(inlen-4))=INF(1:(inlen-4))
       LOGF((inlen-3):inlen)='.log'
       ARCF(1:(inlen-4))=INF(1:(inlen-4))
       ARCF((inlen-3):inlen)='.arc'
       GPTF(1:(inlen-4))=INF(1:(inlen-4))
       GPTF((inlen-3):inlen)='.gpt'
       SYBF(1:(inlen-4))=INF(1:(inlen-4))
       SYBF((inlen-3):inlen)='.syb'
       ERR0(1:(inlen-4))=INF(1:(inlen-4))
       ERR0((inlen-3):inlen)='.er0'
       ERR1(1:(inlen-4))=INF(1:(inlen-4))
       ERR1((inlen-3):inlen)='.er1'
       ELSE
         OUTF=trim(INF)//'.out'
         RESF=trim(INF)//'.res'
         DENF=trim(INF)//'.den'
         LOGF=trim(INF)//'.log'
         ARCF=trim(INF)//'.arc'
         GPTF=trim(INF)//'.gpt'
         SYBF=trim(INF)//'.syb'
         ERR0=trim(INF)//'.er0'
         ERR1=trim(INF)//'.er1'
      ENDIF	  
 ENDIF
  OPEN(2,FILE=INF(1:INLEN),STATUS='OLD')
 ```

 In addition, edit the main program in mopac.f. Insert the following variable declaration at the end of the original variable declaration block (after the line 44):

```FORTRAN
 CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
+               GPTF*80,SYBF*80,ERR0*80,ERR1*80
 COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
 INTEGER OUTLEN
```
And then change the line 50:
```FORTRAN
          OPEN(UNIT=6,FILE=GETNAM('FOR006'),STATUS='NEW')
```
to
```FORTRAN
   IF(len_trim(outf)==0) then
      OUTF='FOR006'
   ENDIF
   OUTLEN=len_trim(outf)
   OPEN(UNIT=6,FILE=OUTF(1:outlen),STATUS='NEW')
 C          OPEN(UNIT=6,FILE=GETNAM('FOR006'),STATUS='NEW')
```
  6-2. Edit deriv.f. Insert the following declaration of variables for file names after the original variable declaration block (after the line 46):
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
    +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
     COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
     INTEGER INLEN
```
  Comment out the original content of if-statement in the line 60.
```FORTRAN
   C    OPEN(UNIT=5,FILE=GETNAM('FOR005'),STATUS='OLD',BLANK='ZERO')
```
  And then insert the new code block instead of it.
```FORTRAN
    if(len_trim(inf)==0) then
        inf='FOR005'
    endif
    inlen=len_trim(inf)
    OPEN(UNIT=5,FILE=inf(1:inlen),STATUS='OLD',BLANK='ZERO')
```
  6-3. Edit dfpsav.f. Insert the following variable declaration at the end of the original variable declaration block (after the line 54):

```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
    +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    INTEGER RESLEN,DENLEN
```
  Change the line 56-61 (OPEN and REWIND statements)
```FORTRAN
    OPEN(UNIT=9,FILE=GETNAM('FOR009')
    +                     ,STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE=GETNAM('FOR010')
    +                     ,STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 10
```
  to
```FORTRAN
    IF(len_trim(RESF)==0) THEN
     RESF='FOR009'
    ENDIF
    IF(len_trim(DENF)==0) THEN
     DENF='FOR010'
    ENDIF
    RESLEN=len_trim(RESF)
    DENLEN=len_trim(DENF)
    OPEN(UNIT=9,FILE=RESF(1:RESLEN)
    +                     ,STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE=DENF(1:DENLEN)
    +                     ,STATUS='UNKNOWN',FORM='UNFORMATTED')
 C      OPEN(UNIT=9,FILE=GETNAM('FOR009')
 C     +                     ,STATUS='UNKNOWN',FORM='UNFORMATTED')
 C      REWIND 9
 C      OPEN(UNIT=10,FILE=GETNAM('FOR010')
 C     +                     ,STATUS='UNKNOWN',FORM='UNFORMATTED')
```
  6-4. Edit dfc.f.  Insert the following variable declaration at the end of the original variable declaration block (after the line 38):
```FORTRAN
      CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
     +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
      COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
            INTEGER RESLEN,DENLEN
```
  Change the lines 171-176 (OPEN and REWIND statements):
```FORTRAN
     OPEN(UNIT=9,FILE=GETNAM('FOR009'),STATUS='UNKNOWN',
    +FORM='FORMATTED')
    REWIND 9
     OPEN(UNIT=10,FILE=GETNAM('FOR010'),STATUS='UNKNOWN',
    +FORM='UNFORMATTED')
    REWIND 10
```
  to
```FORTRAN
    IF(len_trim(RESF)==0) THEN
      RESF='FOR009'
     ENDIF
    IF(len_trim(DENF)==0) THEN
      DENF='FOR010'
    ENDIF
    RESLEN=len_trim(RESF)
    DENLEN=len_trim(DENF)
    OPEN(UNIT=9,FILE=RESF(1:RESLEN),STATUS='UNKNOWN',
   +FORM='FORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE=DENF(1:DENLEN),STATUS='UNKNOWN',
   +FORM='UNFORMATTED')
    REWIND 10
 C         OPEN(UNIT=9,FILE=GETNAM('FOR009'),STATUS='UNKNOWN',
 C     +FORM='FORMATTED')
 C         REWIND 9
 C         OPEN(UNIT=10,FILE=GETNAM('FOR010'),STATUS='UNKNOWN',
 C     +FORM='UNFORMATTED')
 C         REWIND 10
```
  And then change the lines 546-557:

```FORTRAN
    IF (ILOOP.EQ.IUPPER.OR.TLEFT.LT.3*TCYCLE) THEN
46        OPEN(UNIT=9,FILE=GETNAM('FOR009'),STATUS='NEW',
  +FORM='FORMATTED',ERR=45)
   GOTO 47
45        OPEN(UNIT=9,FILE=GETNAM('FOR009'),STATUS='OLD')
   CLOSE(9,STATUS='DELETE')
   GOTO 46
47        CONTINUE
   REWIND 9
   OPEN(UNIT=10,FILE=GETNAM('FOR010'),STATUS='UNKNOWN',
  +FORM='UNFORMATTED')
   REWIND 10
```
  to
```FORTRAN
    IF(len_trim(RESF)==0) THEN
        RESF='FOR009'
    ENDIF
    IF(len_trim(DENF)==0) THEN
       DENF='FOR010'
    ENDIF
    RESLEN=len_trim(RESF)
    DENLEN=len_trim(DENF)
   IF (ILOOP.EQ.IUPPER.OR.TLEFT.LT.3*TCYCLE) THEN
46        OPEN(UNIT=9,FILE=RESF(1:RESLEN),STATUS='NEW',
  +FORM='FORMATTED',ERR=45)
   GOTO 47
45        OPEN(UNIT=9,FILE=RESF(1:RESLEN),STATUS='OLD')
   CLOSE(9,STATUS='DELETE')
   GOTO 46
47        CONTINUE
   REWIND 9
   OPEN(UNIT=10,FILE=DENF(1:DENLEN),STATUS='UNKNOWN',
  +FORM='UNFORMATTED')
   REWIND 10
C         IF (ILOOP.EQ.IUPPER.OR.TLEFT.LT.3*TCYCLE) THEN
C  46        OPEN(UNIT=9,FILE=GETNAM('FOR009'),STATUS='NEW',
C     +FORM='FORMATTED',ERR=45)
C            GOTO 47
C  45        OPEN(UNIT=9,FILE=GETNAM('FOR009'),STATUS='OLD')
C            CLOSE(9,STATUS='DELETE')
C            GOTO 46
C  47        CONTINUE
C            REWIND 9
C            OPEN(UNIT=10,FILE=GETNAM('FOR010'),STATUS='UNKNOWN',
C     +FORM='UNFORMATTED')
C            REWIND 10
```

  6-5. Edit the subroutine EFSAV in ef.f. Change the lines 478-481 (OPEN and REWIND statements at the end of variable declaration):
  ```FORTRAN
    OPEN(UNIT=9,FILE='FOR009',STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE='FOR010',STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 10
```
  to
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
  +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer RESLEN,DENLEN
    IF(len_trim(RESF)==0) THEN
        RESF='FOR009'
    ENDIF
    IF(len_trim(DENF)==0) THEN
      DENF='FOR010'
    ENDIF
    RESLEN=len_trim(RESF)
    DENLEN=len_trim(DENF)
    OPEN(UNIT=9,FILE=RESF(1:RESLEN),STATUS='UNKNOWN',
   +        FORM='UNFORMATTED')
   REWIND 9
   OPEN(UNIT=10,FILE=DENF(1:DENLEN),STATUS='UNKNOWN',
  +        FORM='UNFORMATTED')
   REWIND 10
 C      OPEN(UNIT=9,FILE='FOR009',STATUS='UNKNOWN',FORM='UNFORMATTED')
 C      REWIND 9
 C      OPEN(UNIT=10,FILE='FOR010',STATUS='UNKNOWN',FORM='UNFORMATTED')
 C      REWIND 10
```
  6-6. Edit the subroutine ELESP in esp.f. Insert the following code block at the end of the original variable declaration block (after the line 681):
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer ER1LEN
    IF(len_trim(ERR1)==0) THEN
       ERR1='FOR021'
    ENDIF
    ER1LEN=len_trim(ERR1)
```
  And then change the line 948:
```FORTRAN
             OPEN(21,STATUS='NEW')
```
  to
```FORTRAN
    OPEN(21,FILE=ERR1(1:ER1LEN),STATUS='NEW')
C         OPEN(21,STATUS='NEW')
```
  If a file attribute is absent from OPEN statement, gfortran may generate an error. If you use the traditional FORTRAN 77 in/out decks (i.e. FOR005 etc),it is necessary to change the line 948 open statement to such as:
```FORTRAN
             OPEN(21,FILE='FOR021',STATUS='NEW')
```
  6-7. Edit forsav.f. Change the lines 19-25 (array GETNUM declaration, OPEN and REWIND statements at the end of variable declaration):
```FORTRAN
    CHARACTER*80 GETNAM
    OPEN(UNIT=9,FILE=GETNAM('FOR009')
   +              ,STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE=GETNAM('FOR010')
   +              ,STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 10
```
  to
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer RESLEN,DENLEN
    IF(len_trim(RESF)==0) THEN
       RESF='FOR009'
    ENDIF
    IF(len_trim(DENF)==0) THEN
       DENF='FOR010'
    ENDIF
    RESLEN=len_trim(RESF)
    DENLEN=len_trim(DENF)
    OPEN(UNIT=9,FILE=RESF(1:RESLEN)
   +              ,STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE=DENF(1:DENLEN)
   +              ,STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 10
 C      CHARACTER*80 GETNAM
 C      OPEN(UNIT=9,FILE=GETNAM('FOR009')
 C     +              ,STATUS='UNKNOWN',FORM='UNFORMATTED')
 C      REWIND 9
 C      OPEN(UNIT=10,FILE=GETNAM('FOR010')
 C     +              ,STATUS='UNKNOWN',FORM='UNFORMATTED')
 C      REWIND 10
```
  6-8. Edit grid.f. Insert the following code block at the end of the original variable declaration block (after the line 42):
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer ARCLEN,ER0LEN
```
  And then change the lines 162- 165:
```FORTRAN
    OPEN(UNIT=12,FILE=GETNAM('FOR012'),STATUS='UNKNOWN')
    OPEN(UNIT=20,FILE=GETNAM('FOR020'),STATUS='NEW',ERR=31)
    GOTO 32
  31  OPEN(UNIT=20,FILE=GETNAM('FOR020'),STATUS='OLD')
```
  to
```FORTRAN
    IF(len_trim(ARCF)==0) THEN
       ARCF='FOR012'
    ENDIF
    IF(len_trim(ERR0)==0) THEN
       ERR0='FOR020'
    ENDIF
    ARCLEN=len_trim(ARCF)
    ER0LEN=len_trim(ERR0)
    OPEN(UNIT=12,FILE=ARCF(1:ARCLEN),STATUS='UNKNOWN')
    OPEN(UNIT=20,FILE=ERR0(1:ER0LEN),STATUS='NEW',ERR=31)
    GOTO 32
  31  OPEN(UNIT=20,FILE=ERR0(1:ER0LEN),STATUS='OLD')
 C      OPEN(UNIT=12,FILE=GETNAM('FOR012'),STATUS='UNKNOWN')
 C      OPEN(UNIT=20,FILE=GETNAM('FOR020'),STATUS='NEW',ERR=31)
 C      GOTO 32
 C  31  OPEN(UNIT=20,FILE=GETNAM('FOR020'),STATUS='OLD')
```
  6-9. Edit iter.f. Insert the following code block at the end of the original variable declaration block (after the line 105):
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer DENLEN,OUTLEN
```
  And change the lines 187-192:
```FORTRAN
    IF(INDEX(KEYWRD,'RESTART')+INDEX(KEYWRD,'OLDENS')
   1      .NE. 0) THEN
    IF(INDEX(KEYWRD,'OLDENS').NE.0)
   1   OPEN(UNIT=10,FILE=GETNAM('FOR010'),
   +        STATUS='UNKNOWN',FORM='UNFORMATTED')
```
  to
```FORTRAN
    IF(len_trim(DENF)==0) THEN
      DENF='FOR010'
    ENDIF
    DENLEN=len_trim(DENF)
    IF(INDEX(KEYWRD,'RESTART')+INDEX(KEYWRD,'OLDENS')
   1      .NE. 0) THEN
    IF(INDEX(KEYWRD,'OLDENS').NE.0)
   1   OPEN(UNIT=10,FILE=DENF(1:DENLEN),
   +        STATUS='UNKNOWN',FORM='UNFORMATTED')
 C     1   OPEN(UNIT=10,FILE=GETNAM('FOR010'),
 C     +        STATUS='UNKNOWN',FORM='UNFORMATTED')
```
  Furthermore change the line 640:
```FORTRAN
          OPEN(UNIT=6,FILE=GETNAM('FOR006'))
```
  to
```FORTRAN
    IF(len_trim(OUTF)==0) THEN
       OUTF='FOR006'
    ENDIF
    OUTLEN=len_trim(OUTF)
    OPEN(UNIT=6,FILE=OUTF(1:OUTLEN))
 C      OPEN(UNIT=6,FILE=GETNAM('FOR006'))
```

  6-10. Edit mullik.f. Insert the following code block at the end of the original variable declaration block (after the line 24):
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer GPTLEN
```
  And change the lines 86-96:
```FORTRAN
    OPEN(UNIT=13,FILE=GETNAM('FOR013'),FORM='UNFORMATTED',
   +STATUS='NEW',ERR=31)
    GOTO 32
  31  OPEN(UNIT=13,FILE=GETNAM('FOR013'),STATUS='OLD',
   +FORM='UNFORMATTED')
```
  to
```FORTRAN
    IF(len_trim(GPTF)==0) THEN
       GPTF='FOR013'
    ENDIF
    GPTLEN=len_trim(GPTF)
    OPEN(UNIT=13,FILE=GPTF(1:GPTLEN),FORM='UNFORMATTED',
   +STATUS='NEW',ERR=31)
    GOTO 32
  31  OPEN(UNIT=13,FILE=GPTF(1:GPTLEN),STATUS='OLD',
  +FORM='UNFORMATTED')
C      OPEN(UNIT=13,FILE=GETNAM('FOR013'),FORM='UNFORMATTED',
C     +STATUS='NEW',ERR=31)
C      GOTO 32
C  31  OPEN(UNIT=13,FILE=GETNAM('FOR013'),STATUS='OLD',
C     +FORM='UNFORMATTED')
```
  6-11. Edit parsav.f. Change the lines 31-35 (OPEN and REWIND statements at the end of the original variable declaration block):     
```FORTRAN
    OPEN(UNIT=9,FILE=GETNAM('FOR009'),
   +     STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE=GETNAM('FOR010'),
  +     STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 10
```
  to
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer RESLEN,DENLEN
    IF(len_trim(RESF)==0) THEN
       RESF='FOR009'
    ENDIF
    IF(len_trim(DENF)==0) THEN
     DENF='FOR010'
    ENDIF
    RESLEN=len_trim(RESF)
    DENLEN=len_trim(DENF)
    OPEN(UNIT=9,FILE=RESF(1:RESLEN),
   +     STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE=DENF(1:DENLEN),
   +     STATUS='UNKNOWN',FORM='UNFORMATTED')
REWIND 10
C      OPEN(UNIT=9,FILE=GETNAM('FOR009'),
C     +     STATUS='UNKNOWN',FORM='UNFORMATTED')
C      REWIND 9
C      OPEN(UNIT=10,FILE=GETNAM('FOR010'),
C     +     STATUS='UNKNOWN',FORM='UNFORMATTED')
C      REWIND 10
```
  6-12. Edit pathk.f. Insert the following code block at the end of the original variable declaration block (after the line 27):
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer ARCLEN
```
  And change the lines 74:

```FORTRAN
          OPEN(UNIT=12,FILE=GETNAM('FOR012'),STATUS='UNKNOWN')
```
  to
```FORTRAN
    IF(len_trim(ARCF)==0) THEN
      ARCF='FOR012'
    ENDIF
    ARCLEN=len_trim(ARCF)
    OPEN(UNIT=12,FILE=ARCF(1:ARCLEN),STATUS='UNKNOWN')
C      OPEN(UNIT=12,FILE=GETNAM('FOR012'),STATUS='UNKNOWN')
```
  6-13. Edit powsav.f. Change the lines 39-44 (OPEN and REWIND statements at the end of the original variable declaration block):
```FORTRAN
    OPEN(UNIT=9,FILE=GETNAM('FOR009'),
   +     STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE=GETNAM('FOR010'),
   +     STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 10
```
  to
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer RESLEN,DENLEN
    IF(len_trim(RESF)==0) THEN
      RESF='FOR009'
    ENDIF
    IF(len_trim(DENF)==0) THEN
       DENF='FOR010'
    ENDIF
    RESLEN=len_trim(RESF)
    DENLEN=len_trim(DENF)
    OPEN(UNIT=9,FILE=RESF(1:RESLEN),
   +     STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 9
    OPEN(UNIT=10,FILE=DENF(1:DENLEN),
   +     STATUS='UNKNOWN',FORM='UNFORMATTED')
    REWIND 10
C      OPEN(UNIT=9,FILE=GETNAM('FOR009'),
C     +     STATUS='UNKNOWN',FORM='UNFORMATTED')
C      REWIND 9
C      OPEN(UNIT=10,FILE=GETNAM('FOR010'),
C     +     STATUS='UNKNOWN',FORM='UNFORMATTED')
C      REWIND 10
```   

  6-14. Edit readmo.f. Insert the following code block at the end of the original variable declaration block (after the line 79):
```FORTRAN
    CHARACTER BANNERSP*80
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer LOGLEN
```
  And change the lines 393-397:    
```FORTRAN
    IF(INDEX(KEYWRD,'NOLOG').EQ.0)THEN
    OPEN(UNIT=11, FORM='FORMATTED', STATUS='UNKNOWN',
   +FILE=GETNAM('FOR011'))
    CALL WRTTXT(11)
    ENDIF
```
  to
```FORTRAN
    IF(len_trim(LOGF)==0) THEN
      LOGF='FOR11'
    ENDIF
    LOGLEN=len_trim(LOGF)
    IF(INDEX(KEYWRD,'NOLOG').EQ.0)THEN
    OPEN(UNIT=11, FORM='FORMATTED', STATUS='UNKNOWN',
   +FILE=LOGF(1:LOGLEN))
    CALL WRTTXT(11)
    ENDIF
C      IF(INDEX(KEYWRD,'NOLOG').EQ.0)THEN
C         OPEN(UNIT=11, FORM='FORMATTED', STATUS='UNKNOWN',
C     +FILE=GETNAM('FOR011'))
C         CALL WRTTXT(11)
C      ENDIF
```

  6-15. Edit writmo.f. Insert the following code block at the end of the original variable declaration block (after the line 95):  
```FORTRAN
    CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
   +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
    COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
    integer DENLEN,ARCLEN,SYBLEN
    IF(len_trim(DENF)==0) THEN
       DENF='FOR010'
    ENDIF
    IF(len_trim(ARCF)==0) THEN
       ARCF='FOR12'
    ENDIF
    IF(len_trim(SYBF)==0) THEN
      SYBF='FOR016'
    ENDIF
    DENLEN=len_trim(DENF)
    ARCLEN=len_trim(ARCF)
    SYBLEN=len_trim(SYBF)
```
  And then change the lines 307-311:    

```FORTRAN
    OPEN(UNIT=16,FILE=GETNAM('FOR016'),STATUS='NEW',ERR=31)
    GOTO 32
  31  OPEN(UNIT=16,FILE=GETNAM('FOR016'),STATUS='OLD')
    WRITE(6,'(A)') 'Error opening SYBYL MOPAC output'
  32  CONTINUE
```
  to
```FORTRAN
    OPEN(UNIT=16,FILE=SYBF(1:SYBLEN),STATUS='NEW',ERR=31)
    GOTO 32
  31  OPEN(UNIT=16,FILE=SYBF(1:SYBLEN),STATUS='OLD')
    WRITE(6,'(A)') 'Error opening SYBYL MOPAC output'
  32  CONTINUE
C      OPEN(UNIT=16,FILE=GETNAM('FOR016'),STATUS='NEW',ERR=31)
C      GOTO 32
C  31  OPEN(UNIT=16,FILE=GETNAM('FOR016'),STATUS='OLD')
C      WRITE(6,'(A)') 'Error opening SYBYL MOPAC output'
C  32  CONTINUE
```
  Furthermore change the lines 504-505:    

```FORTRAN
    OPEN(UNIT=10,FILE=GETNAM('FOR010'),
   +STATUS='UNKNOWN',FORM='UNFORMATTED')
```
  to
```FORTRAN
    OPEN(UNIT=10,FILE=DENF(1:DENLEN),
   +STATUS='UNKNOWN',FORM='UNFORMATTED')
C         OPEN(UNIT=10,FILE=GETNAM('FOR010'),
C     +STATUS='UNKNOWN',FORM='UNFORMATTED')
```
  Finally change the line 543:

```FORTRAN
             NAMFIL=GETNAM('FOR012')
```

  to

```FORTRAN
    NAMFIL=ARCF(1:ARCLEN)
C         NAMFIL=GETNAM('FOR012')
```

7. Edit the program banner to show "MOPAC 7 SP" instead of "MOPAC 7" in output files.    
  7.1 In readmo.f, declear new variable of character type "BANNERSP" in the end of the original variable declaration block (after the line 79).
```FORTRAN
      CHARACTER BANNERSP*80
```
Insert the following lines which displays patching information between the line 224 (WRITE(6,'(A)')BANNER) VERSON, IDATE) and the line 225 (C).
```FORTRAN
BANNERSP=' *************** PATCHED BY SERGE '//
1 'PACHKOVSKY AND AOYAMA IWAO ********************'
WRITE(6,'(A)')BANNERSP
```
And then edit the lines 235-6. Change the bellow two lines
```FORTRAN
WRITE(6,'('' *'',10X,''MOPAC:  VERSION '',F5.2,
115X,''CALC''''D. '',A)') VERSON, IDATE
```
to the bellow four lines:
```FORTRAN
C      WRITE(6,'('' *'',10X,''MOPAC:  VERSION '',F5.2,
C     115X,''CALC''''D. '',A)') VERSON, IDATE
      WRITE(6,'('' *'',10X,''MOPAC:  VERSION '',F5.0," SP "
     111X,''CALC''''D. '',A)') VERSON, IDATE
```
  7-2. Edit writmo.f. Change the line 135:     
```FORTRAN
        WRITE(6,'(55X,''VERSION '',F5.2)')VERSON
```
  to
```FORTRAN
C      WRITE(6,'(55X,''VERSION '',F5.2)')VERSON
       WRITE(6,'(55X,''VERSION '',F5.0, " SP")')VERSON
```
  In addition, change the line 567:
```FORTRAN
        WRITE(IWRITE,'(60X,''VERSION '',F5.2)')VERSON
```
  to
```FORTRAN
  C      WRITE(IWRITE,'(60X,''VERSION '',F5.2)')VERSON
         WRITE(IWRITE,'(60X,''VERSION '',F5.0," SP")')VERSON
```

8.  Rename "the original" Makefile to Makefile.old or remove it. To make with Mingw make and gfortran, use the following new Makefile:

```Makefile
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
   9. Launch Windows command prompt. Change the current directory to the directry which contains sources and Makefile.　Execute "make" to build an executable.
   >make

 #### How to use MOPAC 7 SP for Windows.
 1. Prepare your input file. A input file is a simple text file. The first line is the list of keyword to specify the calculation type. The second and third lines are the title and other information for notes. The fourth line and below lines are the definition of the internal coordinate (z-matix) or the Cartesian coordinate of the molecule (the last line must be blank to terminate the geometry definition).  For detail, refer to the mopac 7 manual (mopac.pdf) packed in [the mop7sp.zip package](https://github.com/brhr-iwao/MOPAC7SP/Releases) or many descriptive web pages. It is convenient to use a GUI application such as [Avogadro](https://avogadro.cc) or [OpenBabel GUI](https://openbabel.org/wiki/OpenBabelGUI) for building z-matrix or input.    
 Instead of preparing an input for yourself, you can use [MoCalc2012](https://sourceforge.net/projects/mocalc2012/) with mop7sp.exe.
 2. Copy your input file to the directory with mop7sp.exe. Launch Windows command prompt and change the current directory to the directory with mop7sp.exe. Execute the following command on the command prompt:   

  > mop7sp.exe *YourInputFileName*      

  Wait until finishing the calculation (from a second to several minutes dependent on the input). Output files (see the bellow Appendix) are generated in the current directory. Alternatively you can execute it by dragging and dropping an input file on the mop7sp.exe icon.


 #### An example
 1．An example of methanol in water is shown in [COSMO Validation](http://openmopac.net/manual/cosmo_validation.html) web page in [openmopac.net](http://openmopac.net) . Let's execute the calculation example. The input is:
 ```
 debug eps=78.4 precise am1 1scf
 Methanol

  O         0.00000000 +0    0.0000000 +0    0.0000000 +0                     
  C         1.41376397 +1    0.0000000 +0    0.0000000 +0    1    0    0      
  H         1.11883250 +1  105.4100509 +1    0.0000000 +0    2    1    0       
  H         1.11822538 +1  110.6169278 +1  119.0723551 +1    2    1    3       
  H         1.11822266 +1  110.6330403 +1 -119.0633582 +1    2    1    3       
  H         0.96604061 +1  107.1304037 +1  179.7291695 +1    1    2    3       

 ```
 "Debug" keyword is required for COSMO calculation with mop7sp.exe. A part of the calculation result is:
 ```
FINAL HEAT OF FORMATION =        -63.76685 KCAL
TOTAL ENERGY            =       -504.29643 EV
ELECTRONIC ENERGY       =       -374.69780 EV
CORE-CORE REPULSION     =       -129.59863 EV
DIELECTRIC ENERGY       =         -0.34860 EV
 ```
 Compare this with the validated result shown in [COSMO Validation](http://openmopac.net/manual/cosmo_validation.html) web page:
```
FINAL HEAT OF FORMATION = -60.791xx KCAL
TOTAL ENERGY            = -504.1678x EV
ELECTRONIC ENERGY       = -439.6257x EV POINT GROUP: Cs
CORE-CORE REPULSION     = -64.5421x EV
DIELECTRIC ENERGY       = -0.1821x EV
```

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
