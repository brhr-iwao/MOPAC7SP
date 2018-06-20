      PROGRAM MOPAC
C
C         Notice of Public Domain nature of MOPAC
C
C      'This computer program is a work of the United States
C       Government and as such is not subject to protection by
C       copyright (17 U.S.C. # 105.)  Any person who fraudulently
C       places a copyright notice or does any other act contrary
C       to the provisions of 17 U.S. Code 506(c) shall be subject
C       to the penalties provided therein.  This notice shall not
C       be altered or removed from this software and is to be on
C       all reproductions.'
C
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      COMMON /SCFTYP/ EMIN, LIMSCF
      COMMON /KEYWRD/ KEYWRD
      COMMON /OKMANY/ ISOK
      COMMON /GEOVAR/ NVAR,LOC(2,MAXPAR), IDUMY, XPARAM(MAXPAR)
      COMMON /MESAGE/ IFLEPO,ISCF
      COMMON /GEOSYM/ NDEP,LOCPAR(MAXPAR),IDEPFN(MAXPAR),LOCDEP(MAXPAR)
      COMMON /GEOKST/ NATOMS,LABELS(NUMATM),
     1NA(NUMATM),NB(NUMATM),NC(NUMATM)
      COMMON /GEOM  / GEO(3,NUMATM), XCOORD(3,NUMATM)
      COMMON /GRADNT/ GRAD(MAXPAR),GNORM
      COMMON /MOLKST/ NUMAT,NAT(NUMATM),NFIRST(NUMATM),NMIDLE(NUMATM),
     1                NLAST(NUMATM), NORBS, NELECS,NALPHA,NBETA,
     2                NCLOSE,NOPEN,NDUMY,FRACT
      COMMON /ATHEAT/ ATHEAT
      COMMON /LAST  / LAST
      COMMON /ATOMIC/ EISOL(107),EHEAT(107)
      COMMON /NUMCAL/ NUMCAL
C ***** Modified by Jiro Toyoda at 1994-05-25 *****
C     COMMON /TIME  / TIME0
      COMMON /TIMEC / TIME0
C ***************************** at 1994-05-25 *****
      COMMON /PATH  / LATOM,LPARAM,REACT(200)
C COSMO change
      LOGICAL ISEPS, USEPS , UPDA
      COMMON /ISEPS/  ISEPS, USEPS, UPDA
C end of COSMO change
      CHARACTER*241 KEYWRD, GETNAM*80
      LOGICAL ISOK, LIMSCF
C  aoyama added 1/3
      CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
     +               GPTF*80,SYBF*80,ERR0*80,ERR1*80
      COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
      INTEGER OUTLEN
C  end aoyama added 1/3

      CALL GETDAT
C
C   CLOSE UNIT 6 IN CASE IT WAS ALREADY PRE-ASSIGNED
C
          CLOSE (6)
C   aoyama added 2/3
      IF(len_trim(outf)==0) then
         OUTF='FOR006'
      ENDIF
      OUTLEN=len_trim(outf)
      OPEN(UNIT=6,FILE=OUTF(1:outlen),STATUS='NEW')
C          OPEN(UNIT=6,FILE=GETNAM('FOR006'),STATUS='NEW')
C  end aoyama added 2/3
          REWIND 6
C#      CALL TIMER('FIRST LINE')
      NUMCAL=0
      ISOK=.TRUE.
   10 NUMCAL=NUMCAL+1
C
      TIME0=SECOND()
C
C READ AND CHECK INPUT FILE, EXIT IF NECESSARY.
C     WRITE INPUT FILE TO UNIT 6 AS FEEDBACK TO USER
C
   20 CALL READMO
      EMIN=0.D0
C#      CALL TIMER('AFTER READ')
      IF(NATOMS.EQ.0) GOTO 50
      IF(INDEX(KEYWRD,'AUTHOR') .NE. 0) THEN
         WRITE(6,'(10X,'' MOPAC - A GENERAL MOLECULAR ORBITAL PACKAGE'',
     1/         ,10X,''   ORIGINAL VERSION WRITTEN IN 1983'')')
         WRITE(6,'(10X,''     BY JAMES J. P. STEWART AT THE'',/
     1         ,10X,''     UNIVERSITY OF TEXAS AT AUSTIN'',/
     2         ,10X,''          AUSTIN, TEXAS, 78712'')')
         WRITE(6,'(10X,''  MODIFIED TO DO ESP CALCULATIONS BY''
     1          ,10X,''    BRENT H. BESLER AND K. M. MERZ JR. 1989'')')
      ENDIF
C
C INITIALIZE CALCULATION AND WRITE CALCULATION INDEPENDENT INFO
C
      IF(INDEX(KEYWRD,'0SCF') .NE. 0) THEN
         WRITE(6,'(A)')' GEOMETRY IN MOPAC Z-MATRIX FORMAT'
         CALL GEOUT(6)
         IF(INDEX(KEYWRD,' AIGOUT').NE.0)THEN
            WRITE(6,'(//,A)')'  GEOMETRY IN GAUSSIAN Z-MATRIX FORMAT'
            CALL WRTTXT(6)
            CALL GEOUTG(6)
         ENDIF
         GOTO 50
      ENDIF
      CALL MOLDAT(0)
C COSMO change
C  INITIALIZE SOLVATION
      ISEPS = .FALSE.
      USEPS = .FALSE.
      UPDA = .FALSE.
      INDEPS=INDEX(KEYWRD,'EPS=')
      IF (INDEPS .NE. 0) THEN
        ISEPS = .TRUE.
        USEPS = .TRUE.
        UPDA =.TRUE.
*       CALL INITSV (INDEPS)
      END IF
C A.KLAMT 18.7.91
C end of COSMO change
      IF(INDEX(KEYWRD,'EXTERNAL') .NE. 0) THEN
         CALL DATIN
C
C  RECALCULATE THE ATOMIC ENERGY
C
         ATHEAT=0.D0
         EAT=0.D0
         DO 30 II=1,NUMAT
            NI=NAT(II)
            ATHEAT=ATHEAT+EHEAT(NI)
   30    EAT   =EAT   +EISOL(NI)
         ATHEAT=ATHEAT-EAT*23.061D0
      ENDIF
      IF (INDEX(KEYWRD,'RESTART').EQ.0)THEN
         IF (INDEX(KEYWRD,'1SCF').NE.0) THEN
            IF(LATOM.NE.0)THEN
               WRITE(6,'(//,10X,A)')'1SCF SPECIFIED WITH PATH.  THIS PAI
     1R OF'
               WRITE(6,'(   10X,A)')'OPTIONS IS NOT ALLOWED'
               GOTO 50
            ENDIF
            IFLEPO=1
            ISCF=1
            LAST=1
            I=INDEX(KEYWRD,'GRAD')
            DO 39 J=1,NVAR
  39        GRAD(J)=0.D0
            CALL COMPFG(XPARAM,.TRUE.,ESCF,.TRUE.,GRAD,I.NE.0)
            GOTO 40
         ENDIF
      ENDIF
C
C CALCULATE DYNAMIC REACTION COORDINATE.
C
C
      IF(INDEX(KEYWRD,'SADDLE') .NE. 0) THEN
         CALL REACT1(ESCF)
         GOTO 50
      ENDIF
      IF(INDEX(KEYWRD,'STEP1') .NE. 0) THEN
         CALL GRID
         GOTO 50
      ENDIF
      IF (LATOM .NE. 0) THEN
C
C       DO PATH
C
         IF (INDEX(KEYWRD,'STEP').EQ.0.OR.
     1INDEX(KEYWRD,'POINT').EQ.0) THEN
            CALL PATHS
            GOTO 50
         ENDIF
         CALL PATHK
         GOTO 50
      ENDIF
      IF (   INDEX(KEYWRD,'FORCE') .NE. 0
     1  .OR. INDEX(KEYWRD,'IRC=' ) .NE. 0
     2  .OR. INDEX(KEYWRD,'THERM') .NE. 0 ) THEN
C
C FORCE CALCULATION IF DESIRED
C
         CALL FORCE
         GOTO 50
      ENDIF
      IF(INDEX(KEYWRD,' DRC') + INDEX(KEYWRD,' IRC') .NE. 0) THEN
C
C   IN THIS CONTEXT, "REACT" HOLDS INITIAL VELOCITY VECTOR COMPONENTS.
C
         CALL DRC(REACT,REACT)
         GOTO 50
      ENDIF
C
      IF(INDEX(KEYWRD,'NLLSQ') .NE. 0) THEN
         CALL NLLSQ(XPARAM, NVAR )
         CALL COMPFG(XPARAM,.TRUE.,ESCF,.TRUE.,GRAD,.TRUE.)
         GOTO 40
      ENDIF
C
      IF(INDEX(KEYWRD,'SIGMA') .NE. 0) THEN
         CALL POWSQ(XPARAM, NVAR, ESCF)
         GOTO 40
      ENDIF
C
C  EF OPTIMISATION
C
      IF(INDEX(KEYWRD,' EF').NE.0 .OR. INDEX(KEYWRD,' TS').NE.0) THEN
         IF(INDEX(KEYWRD,'GEO-OK').EQ.0.AND.NVAR.GT.3*NATOMS-6)THEN
            WRITE(6,'(A)')' EIGENVECTOR FOLLOWING IS NOT RECOMMENDED WHE
     1N'
            WRITE(6,'(A)')' MORE THAN 3N-6 COORDINATES ARE TO BE OPTIMIZ
     1ED'
            WRITE(6,'(A)')' TO CONTINUE, SPECIFY ''GEO-OK'''
            STOP
         ENDIF
         CALL EF (XPARAM,NVAR,ESCF)
         GOTO 40
      ENDIF
C
C ORDINARY GEOMETRY OPTIMISATION
C
C
C ORDINARY GEOMETRY OPTIMISATION
C
C#      CALL TIMER('BEFORE FLEPO')
C COSMO change 1/9/92 SJC
      UPDA = .FALSE.
C end of COSMO change
      CALL FLEPO(XPARAM, NVAR, ESCF)
   40 LAST=1
      IF(IFLEPO.GE.0)CALL WRITMO(TIME0, ESCF)
      IF(INDEX(KEYWRD,'POLAR') .NE. 0) THEN
         CALL POLAR
      ENDIF
      IF(INDEX(KEYWRD,' ESP') .NE. 0)THEN
C  IF YOU WANT TO USE THE ESP PROGRAM, UNCOMMENT THE LINE
C  "C#      CALL ESP", ADD "ESP, " TO MOPAC.OPT, THEN COMPILE ESP AND
C  MNDO, AND RELINK.
          CALL ESP
      ENDIF
   50 TIM=SECOND()-TIME0
      LIMSCF=.FALSE.
      WRITE(6,'(///,'' TOTAL CPU TIME: '',F16.2,'' SECONDS'')') TIM
      WRITE(6,'(/,'' == MOPAC DONE =='')')
      IF(ISOK) GOTO 10
      END
      SUBROUTINE GETDAT
      CHARACTER*80 LINE, GETNAM
************************************************************************
*
*   GETDAT READS ALL THE DATA IN ON CHANNEL 2, AND WRITES IT TO SCRATCH
*   CHANNEL 5.  THIS WAY THE ORIGINAL DATA-SET IS FREED UP AS SOON AS
*   THE JOB STARTS.
*
************************************************************************
      SAVE I
      DATA I/0/
C  aoyama added 3/3
      CHARACTER INF*80 ,OUTF*80,RESF*80,DENF*80,LOGF*80,ARCF*80,
     /               GPTF*80,SYBF*80,ERR0*80,ERR1*80
      COMMON /DECKS/ INF,OUTF,RESF,DENF,LOGF,ARCF,GPTF,SYBF,ERR0,ERR1
      integer INLEN
      call GETARG(1,INF)
      INLEN=LEN_TRIM(INF)
      IF(INLEN==0) then
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
      endif
      OPEN(2,FILE=INF(1:INLEN),STATUS='OLD')
C#      WRITE(6,*)GETNAM('FOR005')
C      OPEN(UNIT=2,FILE=GETNAM('FOR005'),STATUS='UNKNOWN')
C  end aoyama added 3/3
C
C  CLOSE UNIT 5 IN CASE IT WAS ALREADY PRE-ASSIGNED.
C
      CLOSE (5)
      OPEN(UNIT=5,STATUS='SCRATCH')
      REWIND 5
      REWIND 2
   10 READ(2,'(A80)',END=20,ERR=20)LINE
      I=I+1
      WRITE(5,'(A80)')LINE
      GOTO 10
   20 REWIND 5
      IF(I.LT.3)THEN
         WRITE(6,'(A)')' INPUT FILE MISSING OR EMPTY'
         STOP
      ENDIF
      CLOSE (2)
      END
