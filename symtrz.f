C
C
C
      SUBROUTINE SYMTRZ (COORD,C,NORB,NMOS,FLAG,FLAG2)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C**************************************************************
C                                                             *
C     DETERMINE POINT GROUP & SYMMETRIZE ORBITALS             *
C                                                             *
C**************************************************************
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
C     ---------------------------------------------------------------
      COMMON/MOLKST/NUMAT,NAT(NUMATM),NFIRST(NUMATM),NMIDLE(NUMATM),
     1   NLAST(NUMATM),NORBS,NELECS,NALPHA,NBETA,NCLOSE,NOPEN,NDUMY,
     2 FRACT
      COMMON/SYMRES/ TRANS,RTR,SIG,NAME,NAMO(MXDIM),INDEX(MXDIM),ISTA(2)
      COMMON /SYMINF/ IBASE(2,12),NBASE,IVIBRO(2,12),IVIB
      COMMON/VECTOR/CDUM(MORB2),EIGS(MAXORB),CBDUM(MORB2),EIGB(MAXORB)
      COMMON /S00002/ NUNUM,NONORB,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON/S00004/SHIFT(3),R(3,3),VECT(2,MXDIM)
      CHARACTER*4  NAME, NAMO, NAM, ISTA
      LOGICAL FLAG,FLAG2
      DIMENSION RSAV(3,3),COTIM(3,NUMATM)
      DIMENSION V1(MAXORB),V2(MAXORB),V3(MAXORB),V4(MAXORB)
      DIMENSION COORD(3,NUMATM),C(MAXORB,MAXORB)
      DIMENSION IOPSYM(7),IMAGE(NUMATM,7)
      DATA IOPSYM /1,1,1,1,1,1,1/
      NUNUM = NUMAT
      NONORB = NORBS
      DO K=1,3
      DO L=1,NUMAT
      COTIM(K,L)=COORD(K,L)
      ENDDO
      ENDDO
      DO I=1,3
      DO J=1,3
      RSAV(I,J)=R(I,J)
      ENDDO
      ENDDO
      NAM=NAME
      CALL SYMAN1(NUMAT,2,COORD,NAT,1,MAXORB)
      IF(FLAG2) CALL SYMAN2(NORBS,NORBS,C,0,1,MAXORB)
      DO I=1,3
      DO J=1,3
      R(I,J)=RSAV(I,J)
      ENDDO
      ENDDO
      DO K=1,3
      DO L=1,numat
      COORD(K,L)=COTIM(K,L)
      ENDDO
      ENDDO
      RETURN
      END
C
C================================================================
C
      SUBROUTINE SYMAN1(NUM1,NUM2,ARRAY,LINEAR,JUMP,idim)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C***************************************************************
C                                                              *
C     SYMMETRY PACKAGE FROM UMNDO PROGRAM OF PETER BISCHOF     *
C     WAS REWRITTEN BY DAVID DANOVICH FOR MOPAC SYSTEM         *
C                                                              *
C***************************************************************
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      DIMENSION LINEAR(NUMATM),NUSS(MXDIM),ICOUNT(12),ARRAY(3,NUMATM)
      COMMON /S00001/T(12,12),JX(7,12),LINA,I1,J1,J2
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00020/ NIMM(2,MXDIM),NOCC(2)
      COMMON/SYMRES/ TRANS,RTR,SIG,NAME,NAMO(MXDIM),INDEX(MXDIM),ISTA(2)
      CHARACTER*4  IFRA, NAME, ISTA, NAMO, NIMM
      COMMON /SYMINF/ IBASE(2,12),NBASE,IVIBRO(2,12),IVIB
      DATA IFRA / '????'  /
      IF(NUM1.LT.2) GOTO 12
      IF(NUM2.LT.2) GOTO 12
      IF(NUM1.GT.MXDIM) GOTO 12
C **  MOLECULAR SYMMETRY
 1    IERROR=0
      LCALL=0
      IVIB=0
      NBASE=0
      NUMAT=NUM1
      NAME=IFRA
      ISTA(1)=' '
      ISTA(2)=IFRA
      DO 2 I=1,MXDIM
 2    NAMO(I)=IFRA
      CALL R00001(LINEAR,ARRAY)
      IF(IERROR.LT.1) CALL R00009(LINEAR,ARRAY)
      IF(IERROR.LT.1) CALL R00016
      DO 3 I=1,NUMAT
 3    INDEX(I)=LINEAR(I)
      RETURN
 12   IERROR=1
      WRITE(6,600)NUM1,NUM2
      RETURN
 600  FORMAT(' ILLEGAL SYMA - ARGUMENTS: NUM1 = ',I10,' NUM2 = ',I10)
      END
C
C======================================================================
C
      SUBROUTINE SYMAN2(NUM1,NUM2,ARRAY,LINEAR,JUMP,idim)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      DIMENSION NUSS(MXDIM),ICOUNT(12),array(num1,num1)
      COMMON /S00001/ T(12,12),JX(7,12),LINA,I1,J1,J2
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00020/ NIMM(2,MXDIM),NOCC(2)
      COMMON/SYMRES/ TRANS,RTR,SIG,NAME,NAMO(MXDIM),INDEX(MXDIM),ISTA(2)
      CHARACTER*4  IFRA, NAME, ISTA, NAMO, NIMM
      COMMON /SYMINF/ IBASE(2,12),NBASE,IVIBRO(2,12),IVIB
      DATA IFRA / '????'  /
      IF(NUM1.LT.2) GOTO 12
      IF(NUM2.LT.2) GOTO 12
      IF(NUM1.GT.MXDIM) GOTO 12
C **  ORBITAL SYMMETRY
      IF(IERROR.GT.0) THEN
        RETURN
      ENDIF
      LCALL=0
      IF(LINEAR.GT.0) GOTO 6
      IF(LCALL.GT.0) GOTO 8
      KORB=0
      NQZ=1
      DO 5 I=1,NUMAT
      JJ=1
      IF(INDEX(I).GT.1) JJ=4
      DO 5 J=1,JJ
      KORB=KORB+1
      NUSS(KORB)=100*I+10*NQZ+J-1
 5    CONTINUE
      GOTO 8
 6    DO 7 I=1,NUM1
 7    NUSS(I)=LINEAR
 8    NORBS=NUM1
      NCDIM=NUM2
      NCDUM=NUM2
      CALL R00010(ARRAY,NUSS,ICOUNT,num1)
      IF(IERROR.GT.0) RETURN
      NBASE=0
      DO 9 I=1,I1
      IF(ICOUNT(I).LT.1) GOTO 9
      NBASE=NBASE+1
      IBASE(1,NBASE)=ICOUNT(I)
      IBASE(2,NBASE)=JX(1,I)
 9    CONTINUE
      LCALL=LCALL+1
      IF(LCALL.GT.2) LCALL=1
      DO 10 I=1,NORBS
      NIMM(LCALL,I)=NAMO(I)
 10   NIMM(2,I)=NAMO(I)
      RETURN
 12   IERROR=1
      WRITE(6,600)NUM1,NUM2
      RETURN
 600  FORMAT(' ILLEGAL SYMA - ARGUMENTS: NUM1 = ',I10,' NUM2 = ',I10)
      END
C
C==========================================================================
C
      SUBROUTINE R00001(NAT,COORD)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      CHARACTER*4 NAME,NAMO,ISTA
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      COMMON /S00004/ SHIFT(3),R(3,3),VECT(2,MXDIM)
      COMMON/SYMRES/ TRANS,RTR,SIG,NAME,NAMO(MXDIM),INDEX(MXDIM),ISTA(2)
      COMMON  /ATMASS/  ATMASS(NUMATM)
      LOGICAL PLANAR,LINEAR,CUBIC,AXIS
      DIMENSION NAT(NUMATM),COORD(3,NUMATM),F(6),EW(3),HELP(3)
      DIMENSION RHELP(3,3)
      DIMENSION ICYC(6)
      DATA TOLER,BIG/ 0.1D0,1.D35 /
      DO 2 I=1,3
      DO 1 J=1,3
 1    CUB(I,J)=0.D0
 2    CUB(I,I)=1.D0
      DO 3 I=1,20
      CALL R00006(I,I)
 3    IELEM(I)=0
      DO 4 I=1,3
 4    SHIFT(I)=0.D0
      WMOL=0.D0
      DO 5 I=1,NUMAT
      WMOL=WMOL+ATMASS(I)
      DO 5 K=1,3
 5    SHIFT(K)=SHIFT(K)+ATMASS(I)*COORD(K,I)
      IJ=0
      DO 7 I=1,3
      SHIFT(I)=SHIFT(I)/WMOL
      DO 6 K=1,NUMAT
 6    COORD(I,K)=COORD(I,K)-SHIFT(I)
      DO 7 J=1,I
      IJ=IJ+1
      F(IJ)=0.D0
      DO 7 K=1,NUMAT
      TERM=ATMASS(K)*COORD(I,K)*COORD(J,K)
 7    F(IJ)=F(IJ)+TERM
      TRANS=25.98160821D0 + 2.97975D0*DLOG(WMOL)
      CALL R00015(F,R,EW)
      R(1,3)=R(2,1)*R(3,2)-R(3,1)*R(2,2)
      R(2,3)=R(3,1)*R(1,2)-R(1,1)*R(3,2)
      R(3,3)=R(1,1)*R(2,2)-R(2,1)*R(1,2)
      PLANAR=(EW(1).LT.TOLER)
      LINEAR=(EW(2).LT.TOLER)
      CUBIC=((EW(3)-EW(1)).LT.TOLER)
      IF(.NOT.LINEAR) GOTO 8
      CALL R00005(COORD,1)
      IELEM(20)=1
      GOTO 22
 8    IF(CUBIC.OR.((EW(3)-EW(2)).GT.TOLER)) GOTO 10
      DO 9 I=1,3
      BUFF=-R(I,1)
      R(I,1)=R(I,3)
 9    R(I,3)=BUFF
      BUFF=EW(1)
      EW(1)=EW(3)
      EW(3)=BUFF
 10   AXIS=(ABS(EW(1)-EW(2)).LT.TOLER)
      CALL R00005(COORD,1)
      IF(CUBIC) CALL R00003(NAT,COORD,1)
      IF(.NOT.AXIS) GOTO 16
      ITURN=7
      DO 11 I=8,18
      CALL R00007(NAT,COORD,I)
      IF((IELEM(I).EQ.1).AND.(I.LT.14)) ITURN=I
 11   CONTINUE
      ITURN=ITURN-5
      DO 13 I=1,NUMAT
      DIST=COORD(1,I)**2+COORD(2,I)**2
      IF(DIST.LT.TOLER) GOTO 13
      BUFF1=BIG
      JNDEX=0
      IPLUS=I+1
      DO 12 J=IPLUS,NUMAT
      BUFF=COORD(1,J)**2+COORD(2,J)**2
      IF(ABS(BUFF-DIST).GT.TOLER) GOTO 12
      BUFF=(COORD(1,I)-COORD(1,J))**2+(COORD(2,I)-COORD(2,J))**2
      IF(BUFF.GT.BUFF1) GOTO 12
      JNDEX=J
      BUFF1=BUFF
 12   CONTINUE
      GOTO 14
 13   CONTINUE
 14   IF(JNDEX.LT.1) IERROR=1
      IF(IERROR.GT.0) GOTO 25
      HELP(1)=COORD(1,I)+COORD(1,JNDEX)
      HELP(2)=COORD(2,I)+COORD(2,JNDEX)
      DIST=SQRT(HELP(1)**2+HELP(2)**2)
      SINA=HELP(2)/DIST
      COSA=HELP(1)/DIST
      CALL R00002(COORD,SINA,COSA,1,2)
      CALL R00007(NAT,COORD,5)
      IF(IELEM(5).EQ.1) GOTO 16
      CALL R00007(NAT,COORD,1)
      IF(IELEM(1).EQ.0) GOTO 16
      DIST=1.5707963268D0/FLOAT(ITURN)
      SINA=SIN(DIST)
      COSA=COS(DIST)
      ICHECK=0
 15   CALL R00002(COORD,SINA,COSA,1,2)
      IF(ICHECK.GT.0) GOTO 16
      CALL R00007(NAT,COORD,5)
      IF(IELEM(5).GT.0) GOTO 16
      ICHECK=1
      SINA=-SINA
      GOTO 15
 16   IF(CUBIC) CALL R00003(NAT,COORD,2)
      IF(AXIS) GOTO 22
      DO 17 I=1,6
      CALL R00007(NAT,COORD,I)
 17   ICYC(I)=(1+IQUAL)*IELEM(I)
      NAXES=IELEM(1)+IELEM(2)+IELEM(3)
      IF(NAXES.GT.1) GOTO 18
      IZ=1
      IF(IELEM(1).EQ.1) GOTO 19
      IZ=2
      IF(IELEM(2).EQ.1) GOTO 19
      IZ=3
      IF(IELEM(3).EQ.1) GOTO 19
      IF(ICYC(5).GT.ICYC(4)) IZ=2
      IF(ICYC(6).GT.ICYC(7-IZ)) IZ=1
      GOTO 19
 18   IZ=1
      IF(ICYC(2).GT.ICYC(1)) IZ=2
      IF(ICYC(3).GT.ICYC(IZ)) IZ=3
 19   ICYC(7-IZ)=-1
      IX=1
      IF(ICYC(5).GT.ICYC(6)) IX=2
      IF(ICYC(4).GT.ICYC(7-IX)) IX=3
      IY=6-IX-IZ
      DO 20 I=1,3
      RHELP(I,1)=R(I,IX)
 20   RHELP(I,2)=R(I,IY)
      RHELP(1,3)=R(2,IX)*R(3,IY)-R(3,IX)*R(2,IY)
      RHELP(2,3)=R(3,IX)*R(1,IY)-R(1,IX)*R(3,IY)
      RHELP(3,3)=R(1,IX)*R(2,IY)-R(2,IX)*R(1,IY)
      CALL R00005(COORD,-1)
      DO 21 I=1,3
      DO 21 J=1,3
 21   R(I,J)=RHELP(I,J)
      CALL R00005(COORD,1)
 22   DO 23 I=1,7
      CALL R00007(NAT,COORD,I)
 23   CONTINUE
      NCODE=0
      J=1
      DO 24 I=1,20
      NCODE=NCODE+IELEM(I)*J
 24   J=2*J
 25   CALL R00005(COORD,-1)
      TOTAL=EW(1)+EW(2)+EW(3)
      DO 26 I=1,3
      EW(I)=TOTAL-EW(I)
      DO 26 J=1,NUMAT
 26   COORD(I,J)=COORD(I,J)+SHIFT(I)
      JGROUP = 0
      CALL R00008(JGROUP,NCODE)
      IF(JGROUP.LT.1) IERROR=2
      TOTAL=EW(1)*EW(2)*EW(3)/(SIG*SIG)
      IF(LINEAR) RTR= 6.970686D0 + 1.9865D0*DLOG(EW(1)/SIG)
      IF(.NOT.LINEAR) RTR=11.592852D0 + 0.98325D0*DLOG(TOTAL)
      RETURN
      END
C
C==================================================================
C
      SUBROUTINE R00002(COORD,SINA,COSA,I,J)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00004/ SHIFT(3),R(3,3),VECT(2,MXDIM)
      DIMENSION COORD(3,NUMATM)
      CALL R00005(COORD,-1)
      DO 1 K=1,3
      BUFF=-SINA*R(K,I)+COSA*R(K,J)
      R(K,I)=COSA*R(K,I)+SINA*R(K,J)
 1    R(K,J)=BUFF
      CALL R00005(COORD,1)
      RETURN
      END
C
C====================================================================
C
      SUBROUTINE R00003(NAT,COORD,JUMP)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      COMMON /S00004/ SHIFT(3),R(3,3),VECT(2,MXDIM)
      DIMENSION COORD(3,NUMATM),NAT(NUMATM),WINK(2)
      DATA BIG,TOLER / 1.D35,0.1/
      DATA WINK(1),WINK(2)/ 0.955316618125D0, 0.6523581398D0        /
      GOTO (1,5),JUMP
 1    IELEM(19)=1
      INDEX=0
      XMIN=BIG
      DO 2 I=1,NUMAT
      DIST=COORD(1,I)**2+COORD(2,I)**2+COORD(3,I)**2
      IF(DIST.LT.TOLER) GOTO 2
      IF(DIST.GT.XMIN) GOTO 2
      INDEX=I
      XMIN=DIST
 2    CONTINUE
      DIST=SQRT(XMIN)
      CALL R00005(COORD,-1)
      R(1,3)=COORD(1,INDEX)/DIST
      R(2,3)=COORD(2,INDEX)/DIST
      R(3,3)=COORD(3,INDEX)/DIST
      BUFF=SQRT(R(1,3)**2+R(2,3)**2)
      BUFF1=SQRT(R(1,3)**2+R(3,3)**2)
      IF(BUFF.GT.BUFF1) GOTO 3
      R(1,1)= R(3,3)/BUFF1
      R(2,1)=0.D0
      R(3,1)=-R(1,3)/BUFF1
      GOTO 4
 3    R(1,1)= R(2,3)/BUFF
      R(2,1)=-R(1,3)/BUFF
      R(3,1)=0.D0
 4    R(1,2)= R(2,3)*R(3,1)-R(2,1)*R(3,3)
      R(2,2)= R(3,3)*R(1,1)-R(3,1)*R(1,3)
      R(3,2)= R(1,3)*R(2,1)-R(1,1)*R(2,3)
      CALL R00005(COORD,1)
      RETURN
 5    WINK2=0.D0
      IF(IELEM(8).LT.1) GOTO 8
      DO 6 I=1,2
      JOTA=18-4*I
      WINK2=WINK(I)
      SINA=SIN(WINK2)
      COSA=COS(WINK2)
      CALL R00002(COORD,SINA,COSA,1,3)
      CALL R00007(NAT,COORD,JOTA)
      IF(IELEM(JOTA).GT.0) GOTO 7
      WINK2=-WINK2
      SINB=SIN(2.D0*WINK2)
      COSB=COS(2.D0*WINK2)
      CALL R00002(COORD,SINB,COSB,1,3)
      CALL R00007(NAT,COORD,JOTA)
      IF(IELEM(JOTA).GT.0) GOTO 7
      CALL R00002(COORD,SINA,COSA,1,3)
 6    CONTINUE
 7    CALL R00007(NAT,COORD,9)
      IF(IELEM(10).GT.0) CALL R00007(NAT,COORD,17)
      GOTO 10
 8    WINK2=-WINK(1)
      IF(IELEM(10).GT.0) WINK2=-WINK(2)
      SINA=-SIN(WINK2)
      COSA=COS(WINK2)
      CALL R00002(COORD,SINA,COSA,1,3)
      CALL R00007(NAT,COORD,8)
      CALL R00002(COORD,-SINA,COSA,1,3)
      IF(IELEM(8).GT.0) GOTO 10
      IF(IELEM(9).GT.0) GOTO 9
      WINK2=-WINK2
      GOTO 10
 9    CALL R00002(COORD,0.707106781186D0,0.707106781186D0,1,2)
 10   CUB(1,1)=COS(WINK2)
      CUB(3,3)=CUB(1,1)
      CUB(1,3)=SIN(WINK2)
      CUB(3,1)=-CUB(1,3)
      CALL R00004(CUB,8)
      CALL R00004(CUB,15)
      CALL R00007(NAT,COORD,8)
      CALL R00007(NAT,COORD,15)
      RETURN
      END
C
C=====================================================================
C
      SUBROUTINE R00004(FMAT,IPLACE)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      DIMENSION HELP(3,3),FMAT(3,3)
      DO 1 I=1,3
      DO 1 J=1,3
      HELP(I,J)=0.D0
      DO 1 K=1,3
      DO 1 L=1,3
 1    HELP(I,J)=HELP(I,J)+FMAT(I,L)*FMAT(J,K)*ELEM(L,K,IPLACE)
      DO 2 I=1,3
      DO 2 J=1,3
 2    ELEM(I,J,IPLACE)=HELP(I,J)
      RETURN
      END
C
C==========================================================================
C
      SUBROUTINE R00005(COORD,JUMP)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00004/ SHIFT(3),R(3,3),VECT(2,MXDIM)
      DIMENSION COORD(3,NUMATM),HELP(3)
      IF(JUMP.LT.0) GOTO 3
      DO 2 I=1,NUMAT
      DO 1 J=1,3
 1    HELP(J)=COORD(J,I)
      DO 2 J=1,3
      COORD(J,I)=0.D0
      DO 2 K=1,3
 2    COORD(J,I)=COORD(J,I)+R(K,J)*HELP(K)
      RETURN
 3    DO 5 I=1,NUMAT
      DO 4 J=1,3
 4    HELP(J)=COORD(J,I)
      DO 5 J=1,3
      COORD(J,I)=0.D0
      DO 5 K=1,3
 5    COORD(J,I)=COORD(J,I)+R(J,K)*HELP(K)
      RETURN
      END
C
C========================================================================
C
      SUBROUTINE R00006(IOPER,IPLACE)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      DIMENSION J(3,20)
      DATA J(1, 1),J(2, 1),J(3, 1) /       1   ,   -1   ,   -1     /
      DATA J(1, 2),J(2, 2),J(3, 2) /      -1   ,    1   ,   -1     /
      DATA J(1, 3),J(2, 3),J(3, 3) /      -1   ,   -1   ,    1     /
      DATA J(1, 4),J(2, 4),J(3, 4) /       1   ,    1   ,   -1     /
      DATA J(1, 5),J(2, 5),J(3, 5) /       1   ,   -1   ,    1     /
      DATA J(1, 6),J(2, 6),J(3, 6) /      -1   ,    1   ,    1     /
      DATA J(1, 7),J(2, 7),J(3, 7) /      -1   ,   -1   ,   -1     /
      DATA J(1, 8),J(2, 8),J(3, 8) /       3   ,    0   ,    1     /
      DATA J(1, 9),J(2, 9),J(3, 9) /       4   ,    0   ,    1     /
      DATA J(1,10),J(2,10),J(3,10) /       5   ,    0   ,    1     /
      DATA J(1,11),J(2,11),J(3,11) /       6   ,    0   ,    1     /
      DATA J(1,12),J(2,12),J(3,12) /       7   ,    0   ,    1     /
      DATA J(1,13),J(2,13),J(3,13) /       8   ,    0   ,    1     /
      DATA J(1,14),J(2,14),J(3,14) /       4   ,    0   ,   -1     /
      DATA J(1,15),J(2,15),J(3,15) /       6   ,    0   ,   -1     /
      DATA J(1,16),J(2,16),J(3,16) /       8   ,    0   ,   -1     /
      DATA J(1,17),J(2,17),J(3,17) /      10   ,    0   ,   -1     /
      DATA J(1,18),J(2,18),J(3,18) /      12   ,    0   ,   -1     /
      DATA J(1,19),J(2,19),J(3,19) /       5   ,    0   ,   -1     /
      DATA J(1,20),J(2,20),J(3,20) /       0   ,    0   ,   -1     /
      DATA TWOPI / 6.283185308D0 /
      DO 2 I=1,3
      DO 1 K=1,3
 1    ELEM(I,K,IPLACE)=0.
 2    ELEM(I,I,IPLACE)=J(I,IOPER)
      IF(IOPER.EQ.20) GOTO 4
      IF(J(1,IOPER).LT.2) GOTO 3
      ANGLE=TWOPI/FLOAT(J(1,IOPER))
      ELEM(1,1,IPLACE)=COS(ANGLE)
      ELEM(2,2,IPLACE)=ELEM(1,1,IPLACE)
      ELEM(2,1,IPLACE)=SIN(ANGLE)
      ELEM(1,2,IPLACE)=-ELEM(2,1,IPLACE)
 3    IF((IOPER.EQ.8).OR.(IOPER.EQ.15)) CALL R00004(CUB,IPLACE)
      RETURN
 4    ELEM(1,2,IPLACE)=1.D0
      ELEM(2,1,IPLACE)=1.D0
      RETURN
      END
C
C======================================================================
C
      SUBROUTINE R00007(NAT,COORD,IOPER)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      DIMENSION NAT(NUMATM),COORD(3,NUMATM),HELP(3),E(3,3)
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      DATA TOLER / 0.01 D0/
      IRESUL=1
      IQUAL=0
      DO 2 I=1,NUMAT
      HELP(1)=COORD(1,I)*ELEM(1,1,IOPER)+COORD(2,I)*ELEM(1,2,IOPER)
     .                                  +COORD(3,I)*ELEM(1,3,IOPER)
      HELP(2)=COORD(1,I)*ELEM(2,1,IOPER)+COORD(2,I)*ELEM(2,2,IOPER)
     .                                  +COORD(3,I)*ELEM(2,3,IOPER)
      HELP(3)=COORD(1,I)*ELEM(3,1,IOPER)+COORD(2,I)*ELEM(3,2,IOPER)
     .                                  +COORD(3,I)*ELEM(3,3,IOPER)
      DO 1 J=1,NUMAT
      IF(NAT(I).NE.NAT(J)) GOTO 1
      IF(ABS(COORD(1,J)-HELP(1)).GT.TOLER) GOTO 1
      IF(ABS(COORD(2,J)-HELP(2)).GT.TOLER) GOTO 1
      IF(ABS(COORD(3,J)-HELP(3)).GT.TOLER) GOTO 1
      JELEM(IOPER,I)=J
      IF(I.EQ.J) IQUAL=IQUAL+1
      GOTO 2
 1    CONTINUE
      IRESUL=0
 2    CONTINUE
      IELEM(IOPER)=IRESUL
      RETURN
      END
C
C=====================================================================
C
      SUBROUTINE R00008(IGROUP,NCODE)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      COMMON /S00001/         T(12,12),JX(7,12),LINA,I1,J1,J2
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      COMMON/SYMRES/TRANS,RTR,SIG,NAME,NAMO(MXDIM),INDEX(MXDIM),ISTA(2)
      INTEGER C1(3),CS(7),CI(7),C2(7),C3(9),C4(16),C5(19),C6(29),
     .       C7(33),C8(46),D2(21),D3(13),D4(31),D5(21),D6(43),
     .       C2V(21),C3V(13),C4V(31),C5V(21),C6V(43),
     .       C2H(21),C3H(29),C4H(55),C5H(67),C6H(105),
     .       D2H(73),D3H(43),D4H(111),D5H(73),D6H(157),
     .       D2D(31),D3D(43),D4D(57),D5D(73),D6D(91),
     .       S4(16),S6(29),S8(46),
     .       TD(31),OH(111),IH(111),CV(10),DH(25)
      DIMENSION J(43),JTAB(1844),ISIGMA(43)
      EQUIVALENCE (JTAB(   1),C1(1)),(JTAB(   4),CS(1))
      EQUIVALENCE (JTAB(  11),CI(1)),(JTAB(  18),C2(1))
      EQUIVALENCE (JTAB(  25),C3(1)),(JTAB(  34),C4(1))
      EQUIVALENCE (JTAB(  50),C5(1)),(JTAB(  69),C6(1))
      EQUIVALENCE (JTAB(  98),C7(1)),(JTAB( 131),C8(1))
      EQUIVALENCE (JTAB( 177),D2(1)),(JTAB( 198),D3(1))
      EQUIVALENCE (JTAB( 211),D4(1)),(JTAB( 242),D5(1))
      EQUIVALENCE (JTAB( 263),D6(1)),(JTAB( 306),C2V(1))
      EQUIVALENCE (JTAB( 327),C3V(1)),(JTAB( 340),C4V(1))
      EQUIVALENCE (JTAB( 371),C5V(1)),(JTAB( 392),C6V(1))
      EQUIVALENCE (JTAB( 435),C2H(1)),(JTAB( 456),C3H(1))
      EQUIVALENCE (JTAB( 485),C4H(1)),(JTAB( 540),C5H(1))
      EQUIVALENCE (JTAB( 607),C6H(1)),(JTAB( 712),D2H(1))
      EQUIVALENCE (JTAB( 785),D3H(1)),(JTAB( 828),D4H(1))
      EQUIVALENCE (JTAB( 939),D5H(1)),(JTAB(1012),D6H(1))
      EQUIVALENCE (JTAB(1169),D2D(1)),(JTAB(1200),D3D(1))
      EQUIVALENCE (JTAB(1243),D4D(1)),(JTAB(1300),D5D(1))
      EQUIVALENCE (JTAB(1373),D6D(1)),(JTAB(1464),S4(1))
      EQUIVALENCE (JTAB(1480),S6(1)),(JTAB(1509),S8(1))
      EQUIVALENCE (JTAB(1555),TD(1)),(JTAB(1586),OH(1))
      EQUIVALENCE (JTAB(1697),IH(1))
      EQUIVALENCE (JTAB(1808),CV(1)),(JTAB(1818),DH(1))
      DATA J( 1),J( 2),J( 3),J( 4)/ 1010001, 2020004, 2020011, 2020018 /
      DATA J( 5),J( 6),J( 7),J( 8)/ 3020025, 4030034, 5030050, 6040069 /
      DATA J( 9),J(10),J(11),J(12)/ 7040098, 8050131, 4040177, 3030198 /
      DATA J(13),J(14),J(15),J(16)/ 5050211, 4040242, 6060263, 4040306 /
      DATA J(17),J(18),J(19),J(20)/ 3030327, 5050340, 4040371, 6060392 /
      DATA J(21),J(22),J(23),J(24)/ 4040435, 6040456, 8060485,10060540 /
      DATA J(25),J(26),J(27),J(28)/12080607, 8080712, 6060785,10100828 /
      DATA J(29),J(30),J(31),J(32)/ 8080939,12121012, 5051169, 6061200 /
      DATA J(33),J(34),J(35),J(36)/ 7071243, 8081300, 9091373, 4031464 /
      DATA J(37),J(38),J(39),J(40)/ 6041480, 8051509, 5051555,10101586 /
      DATA J(41),J(42),J(43)      /10101697, 2031808, 3061818          /
      DATA ISIGMA / 1,1,1,2,3,4,5,6,7,8,4,6,8,10,12,2,3,4,5,6,2,3,4,5,6,
     .              4,6,8,10,12,4,6,8,10,12,2,3,4,12,24,60,1,2         /
      DATA C1
     ./                         2HC1,
     .4HA     ,                  0                                     /
      DATA CS
     ./                         2HCS,
     .4HA'    ,          8      ,      20104                           ,
     .4HA"    ,          1      ,       -1                             /
      DATA CI
     ./                         2HCI,
     .4HAG    ,         64      ,      10107                           ,
     .4HAU    ,          1      ,       -1                             /
      DATA C2
     ./                         2HC2,
     .4HA     ,          4      ,    2140103                           ,
     .4HB     ,          1      ,       -1                             /
      DATA C3
     ./                         2HC3,
     .4HA     ,     128      , 3140108  , 3240122                      ,
     .4HE     ,       2      ,   -1     ,    -1                        /
      DATA C4
     ./                         2HC4,
     .4HA     ,      260  ,4140109  ,2140103  ,4340123                 ,
     .4HB     ,      1    ,   -1    ,    1    ,   -1                   ,
     .4HE     ,      2    ,    0    ,   -2    ,    0                   /
      DATA C5
     ./                         2HC5,
     .2HA  ,     512  , 5140110  ,      5240122   , 5340123    ,5440124,
     .2HE1 ,     2    ,    51    ,    52     ,   52      ,  51         ,
     .2HE2 ,     2    ,    52     ,   51     ,   51      ,  52         /
      DATA C6
     ./                         2HC6,
     .2HA  ,  1156  ,6140111  ,3140108  ,2140103  ,3240133  ,6540125   ,
     .2HB  ,   1    ,   -1    ,    1    ,   -1    ,    1    ,   -1     ,
     .2HE1 ,   2    ,    1    ,   -1    ,   -2    ,   -1    ,    1     ,
     .2HE2 ,   2    ,   -1    ,   -1    ,    2    ,   -1    ,   -1     /
      DATA C7
     ./                         2HC7,
     .2HA ,2048,7140112,7240122,7340123,7440124,7540125,7640126,
     .2HE1 ,   2   ,  71   ,  72   ,  73    ,  73   ,  72   ,  71    ,
     .2HE2 ,   2   ,  72   ,  73   ,  71    ,  71   ,  73   ,  72    ,
     .2HE3 ,   2   ,  73   ,  71   ,  72    ,  72   ,  71   ,  73    /
      DATA C8
     ./                         2HC8,
     .2HA ,4356,8140113,4140109,2140103,4340134,8340123,8540124,8740125,
     .2HB  , 1  ,  -1  ,   1  ,   1  ,   1  ,  -1   ,  -1   ,  -1    ,
     .2HE1 , 2  ,  81  ,   0  ,  -2  ,   0  ,  83   ,  83   ,  81    ,
     .2HE2 , 2  ,   0  ,  -2  ,   2  ,  -2  ,   0   ,   0   ,   0    ,
     .2HE3 , 2  ,  83  ,   0  ,  -2  ,   0  ,  81   ,  81   ,  83    /
      DATA D2
     ./                         2HD2,
     .4HA     ,      7    ,2140103  ,2140102  ,2140101                 ,
     .4HB1    ,      1    ,    1    ,   -1    ,   -1                   ,
     .4HB2    ,      1    ,   -1    ,    1    ,   -1                   ,
     .4HB3    ,      1    ,   -1    ,   -1    ,    1                   /
      DATA D3
     ./                         2HD3,
     .4HA1    ,      129    ,   3140208      , 2140301                 ,
     .4HA2    ,      1      ,       1        ,    -1                   ,
     .4HE     ,      2      ,      -1        ,     0                   /
      DATA D4
     ./                         2HD4,
     .2HA1 ,     263  , 4140209  , 2140103   ,2140201    ,2140220      ,
     .2HA2 ,     1    ,     1    ,     1     ,   -1      ,  -1         ,
     .2HB1 ,     1    ,    -1    ,     1     ,    1      ,  -1         ,
     .2HB2 ,     1    ,    -1    ,     1     ,   -1      ,   1         ,
     .2HE  ,     2    ,     0    ,    -2     ,    0      ,   0         /
      DATA D5
     ./                         2HD5,
     .4HA1    ,      513  ,5140210    ,5240222    ,  2140501           ,
     .4HA2    ,      1    ,    1      ,    1      ,     -1             ,
     .4HE1    ,      2    ,   51      ,   52      ,      0             ,
     .4HE2    ,      2    ,   52      ,   51      ,      0             /
      DATA D6
     ./                         2HD6,
     .2HA1 ,  1159  ,6140211  ,3140208  ,2140103  ,2140301  ,2140302   ,
     .2HA2 ,   1    ,    1    ,    1    ,    1    ,   -1    ,   -1     ,
     .2HB1 ,   1    ,   -1    ,    1    ,   -1    ,    1    ,   -1     ,
     .2HB2 ,   1    ,   -1    ,    1    ,   -1    ,   -1    ,    1     ,
     .2HE1 ,   2    ,    1    ,   -1    ,   -2    ,    0    ,    0     ,
     .2HE2 ,   2    ,   -1    ,   -1    ,    2    ,    0    ,    0     /
      DATA C2V
     ./                         3HC2V,
     .4HA1    ,     52    ,2140103  ,  20105  ,  20106                 ,
     .4HA2    ,      1    ,    1    ,   -1    ,   -1                   ,
     .4HB1    ,      1    ,   -1    ,    1    ,   -1                   ,
     .4HB2    ,      1    ,   -1    ,   -1    ,    1                   /
      DATA C3V
     ./                         3HC3V,
     .4HA1    ,      144     ,3140208   ,   20305                      ,
     .4HA2    ,       1      ,    1     ,    -1                        ,
     .4HE     ,       2      ,   -1     ,     0                        /
      DATA C4V
     ./                         3HC4V,
     .2HA1 ,    308   ,4140209   ,2140103    , 20205     ,20224        ,
     .2HA2 ,     1    ,     1    ,     1     ,   -1      ,  -1         ,
     .2HB1 ,     1    ,    -1    ,     1     ,    1      ,  -1         ,
     .2HB2 ,     1    ,    -1    ,     1     ,   -1      ,   1         ,
     .2HE  ,     2    ,     0    ,    -2     ,    0      ,   0         /
      DATA C5V
     ./                         3HC5V,
     .4HA1    ,     528     , 5140210     , 5240222     , 20505        ,
     .4HA2    ,      1      ,      1      ,      1      ,   -1         ,
     .4HE1    ,      2      ,     51      ,     52      ,    0         ,
     .4HE2    ,      2      ,     52      ,     51      ,    0         /
      DATA C6V
     ./                         3HC6V,
     .2HA1 , 1204   ,  6140211,  3140208,2140103  , 20305   ,  20306   ,
     .2HA2 ,   1    ,    1    ,    1    ,    1    ,   -1    ,   -1     ,
     .2HB1 ,   1    ,   -1    ,    1    ,   -1    ,    1    ,   -1     ,
     .2HB2 ,   1    ,   -1    ,    1    ,   -1    ,   -1    ,    1     ,
     .2HE1 ,   2    ,    1    ,   -1    ,   -2    ,    0    ,    0     ,
     .2HE2 ,   2    ,   -1    ,   -1    ,    2    ,    0    ,    0     /
      DATA C2H
     ./                         3HC2H,
     .4HAG    ,     76    ,2140103  , 10107   , 20104                  ,
     .4HBG    ,      1    ,   -1    ,    1    ,   -1                   ,
     .4HAU    ,      1    ,    1    ,   -1    ,   -1                   ,
     .4HBU    ,      1    ,   -1    ,   -1    ,    1                   /
      DATA C3H
     ./                         3HC3H,
     .2HA' ,  136   ,  3140108,  3240122,    20104,  3130124,3530143   ,
     .2HE' ,   2    ,   -1    ,   -1    ,    2    ,   -1    ,   -1     ,
     .2HA" ,   1    ,    1    ,    1    ,   -1    ,   -1    ,   -1     ,
     .2HE" ,   2    ,   -1    ,   -1    ,   -2    ,    1    ,    1     /
      DATA C4H
     ./                         3HC4H,
     .2HAG,8524,4140109,2140103,4340123,10107,4330152,20104,4130114,
     .2HBG ,   1  ,  -1  ,   1  ,  -1  ,   1  ,  -1  ,   1  ,  -1      ,
     .2HEG ,   2  ,   0  ,  -2  ,   0  ,   2  ,   0  ,  -2  ,   0      ,
     .2HAU ,   1  ,   1  ,   1  ,   1  ,  -1  ,  -1  ,  -1  ,  -1      ,
     .2HBU ,   1  ,  -1  ,   1  ,  -1  ,  -1  ,   1  ,  -1  ,   1      ,
     .2HEU ,   2  ,   0  ,  -2  ,   0  ,  -2  ,   0  ,   2  ,   0      /
      DATA C5H
     ./                         3HC5H,
     .2HA',520,5140110,5240122,5340123,5440124,20104,5130119,5730163,
     .                                               5330164,5930165,
     .3HE1' ,  2  , 51  , 52  ,52  , 51  ,  2  , 51  , 52  , 52  , 51  ,
     .3HE2' ,  2  , 52  , 51  ,51  , 52  ,  2  , 52  , 51  , 51  , 52  ,
     .2HA"  ,  1  ,  1  ,  1  , 1  ,  1  , -1  , -1  , -1  , -1  , -1  ,
     .3HE1" ,  2  , 51  , 52  ,52  , 51  , -2  ,103  ,101  ,101  ,103  ,
     .3HE2" ,  2  , 52  , 51  ,51  , 52  , -2  ,101  ,103  ,103  ,101  /
      DATA C6H
     ./                         3HC6H,
     .2HAG,17612,6140111,3140108,2140103,3240133,6540125,10107,20104,
     .                                  3530127,6530137,6130115,3130183,
     .3HBG ,  1 , -1 ,  1 , -1 ,  1 , -1 ,  1 , -1 , -1 ,  1 ,  1 , -1 ,
     .3HE1G,  2 ,  1 , -1 , -2 , -1 ,  1 ,  2 , -2 ,  1 , -1 , -1 ,  1 ,
     .3HE2G,  2 , -1 , -1 ,  2 , -1 , -1 ,  2 ,  2 , -1 , -1 , -1 , -1 ,
     .3HAU ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 , -1 , -1 , -1 , -1 , -1 , -1 ,
     .3HBU ,  1 , -1 ,  1 , -1 ,  1 , -1 , -1 ,  1 ,  1 , -1 , -1 ,  1 ,
     .3HE1U,  2 ,  1 , -1 , -2 , -1 ,  1 , -2 ,  2 , -1 ,  1 ,  1 , -1 ,
     .3HE2U,  2 , -1 , -1 ,  2 , -1 , -1 , -2 , -2 ,  1 ,  1 ,  1 ,  1 /
      DATA D2H
     ./                         3HD2H,
     .2HAG,     127,2140103,2140102,2140101,  10107,  20104,20105,20106,
     .3HB1G,   1   ,   1   ,  -1   ,  -1   ,   1   ,   1   ,  -1   , -1,
     .3HB2G,   1   ,  -1   ,   1   ,  -1   ,   1   ,  -1   ,   1   , -1,
     .3HB3G,   1   ,  -1   ,  -1   ,   1   ,   1   ,  -1   ,  -1   ,  1,
     .3HAU ,   1   ,   1   ,   1   ,   1   ,  -1   ,  -1   ,  -1   , -1,
     .3HB1U,   1   ,   1   ,  -1   ,  -1   ,  -1   ,  -1   ,   1   ,  1,
     .3HB2U,   1   ,  -1   ,   1   ,  -1   ,  -1   ,   1   ,  -1   ,  1,
     .3HB3U,   1   ,  -1   ,  -1   ,   1   ,  -1   ,   1   ,   1   , -1/
      DATA D3H
     ./                         3HD3H,
     .3HA1',  153  ,3140208   ,2140301  , 20104  ,3130224   , 20305    ,
     .3HA2',   1    ,    1    ,   -1    ,    1    ,    1    ,   -1     ,
     .3HE' ,   2    ,   -1    ,    0    ,    2    ,   -1    ,    0     ,
     .3HA1",   1    ,    1    ,    1    ,   -1    ,   -1    ,   -1     ,
     .3HA2",   1    ,    1    ,   -1    ,   -1    ,   -1    ,    1     ,
     .3HE" ,   2    ,   -1    ,    0    ,   -2    ,    1    ,    0     /
      DATA D4H
     ./                         3HD4H,
     .3HA1G,8575,4140209,2140103,2140201,2140220,10107,4130214,20104,
     .                                                      20205,20229,
     .3HA2G ,  1 ,  1 ,  1 , -1 , -1 ,  1 ,  1 ,  1 , -1 , -1 ,
     .3HB1G ,  1 , -1 ,  1 ,  1 , -1 ,  1 , -1 ,  1 ,  1 , -1 ,
     .3HB2G ,  1 , -1 ,  1 , -1 ,  1 ,  1 , -1 ,  1 , -1 ,  1 ,
     .3HEG  ,  2 ,  0 , -2 ,  0 ,  0 ,  2 ,  0 , -2 ,  0 ,  0 ,
     .3HA1U ,  1 ,  1 ,  1 ,  1 ,  1 , -1 , -1 , -1 , -1 , -1 ,
     .3HA2U ,  1 ,  1 ,  1 , -1 , -1 , -1 , -1 , -1 ,  1 ,  1 ,
     .3HB1U ,  1 , -1 ,  1 ,  1 , -1 , -1 ,  1 , -1 , -1 ,  1 ,
     .3HB2U ,  1 , -1 ,  1 , -1 ,  1 , -1 ,  1 , -1 ,  1 , -1 ,
     .3HEU  ,  2 ,  0 , -2 ,  0 ,  0 , -2 ,  0 ,  2 ,  0 ,  0 /
      DATA D5H
     ./                         3HD5H,
     .3HA1',537, 5140210, 5240222,2140501,20104,5130219,  5330263,20505,
     .3HA2',  1  ,  1   ,    1   , -1  ,   1  ,   1    ,    1    , -1  ,
     .3HE1',  2  , 51   ,   52   ,  0  ,   2  ,  51    ,   52    ,  0  ,
     .3HE2',  2  , 52   ,   51   ,  0  ,   2  ,  52    ,   51    ,  0  ,
     .3HA1",  1  ,  1   ,    1   ,  1  ,  -1  ,  -1    ,   -1    , -1  ,
     .3HA2",  1  ,  1   ,    1   , -1  ,  -1  ,  -1    ,   -1    ,  1  ,
     .3HE1",  2  , 51   ,   52   ,  0  ,  -2  , 103    ,  101    ,  0  ,
     .3HE2",  2  , 52   ,   51   ,  0  ,  -2  , 101    ,  103    ,  0  /
      DATA D6H
     ./                         3HD6H,
     .3HA1G,17663,6140211,3140208,2140103,2140301,2140302,10107,20104,
     .                                      6130215,3130238,20306,20305,
     .3HA2G ,   1,  1,  1,  1, -1, -1,  1,  1,  1,  1, -1, -1,
     .3HB1G ,   1, -1,  1, -1,  1, -1,  1, -1,  1, -1,  1, -1,
     .3HB2G ,   1, -1,  1, -1, -1,  1,  1, -1,  1, -1, -1,  1,
     .3HE1G ,   2,  1, -1, -2,  0,  0,  2, -2, -1,  1,  0,  0,
     .3HE2G ,   2, -1, -1,  2,  0,  0,  2,  2, -1, -1,  0,  0,
     .3HA1U ,   1,  1,  1,  1,  1,  1, -1, -1, -1, -1, -1, -1,
     .3HA2U ,   1,  1,  1,  1, -1, -1, -1, -1, -1, -1,  1,  1,
     .3HB1U ,   1, -1,  1, -1,  1, -1, -1,  1, -1,  1, -1,  1,
     .3HB2U ,   1, -1,  1, -1, -1,  1, -1,  1, -1,  1,  1, -1,
     .3HE1U ,   2,  1, -1, -2,  0,  0, -2,  2,  1, -1,  0,  0,
     .3HE2U ,   2, -1, -1,  2,  0,  0, -2, -2,  1,  1,  0,  0/
      DATA D2D
     ./                         3HD2D,
     .2HA1 ,   8244   ,4130214   , 2140103   ,2140220    ,20205        ,
     .2HA2 ,     1    ,     1    ,     1     ,   -1      ,  -1         ,
     .2HB1 ,     1    ,    -1    ,     1     ,    1      ,  -1         ,
     .2HB2 ,     1    ,    -1    ,     1     ,   -1      ,   1         ,
     .2HE  ,     2    ,     0    ,    -2     ,    0      ,   0         /
      DATA D3D
     ./                         3HD3D,
     .3HA1G,16594   ,3140208  ,2140302  , 10107   ,6130215  , 20305    ,
     .3HA2G,   1    ,    1    ,   -1    ,    1    ,    1    ,   -1     ,
     .3HEG ,   2    ,   -1    ,    0    ,    2    ,   -1    ,    0     ,
     .3HA1U,   1    ,    1    ,    1    ,   -1    ,   -1    ,   -1     ,
     .3HA2U,   1    ,    1    ,   -1    ,   -1    ,   -1    ,    1     ,
     .3HEU ,   2    ,   -1    ,    0    ,   -2    ,    1    ,    0     /
      DATA D4D
     ./                         3HD4D,
     .3HA1  ,33076,8130216    ,4140209, 8330223,2140103,20405,2140426,
     .3HA2  , 1 ,     1     ,  1 ,     1     ,  1 , -1 , -1 ,
     .3HB1  , 1 ,    -1     ,  1 ,    -1     ,  1 , -1 ,  1 ,
     .3HB2  , 1 ,    -1     ,  1 ,    -1     ,  1 ,  1 , -1 ,
     .3HE1  , 2 ,    81     ,  0 ,    83     , -2 ,  0 ,  0 ,
     .3HE2  , 2 ,     0     , -2 ,     0     ,  2 ,  0 ,  0 ,
     .3HE3  , 2 ,    83     ,  0 ,    81     , -2 ,  0 ,  0 /
      DATA D5D
     ./                         3HD5D,
     .3HA1G,66130,5140210,5240222,2140502,10107,10130217,
     .                                                  10330226,20505,
     .3HA2G ,   1  ,   1  ,   1  ,  -1  ,   1  ,   1  ,   1  ,  -1  ,
     .3HE1G ,   2  ,  51  ,  52  ,   0  ,   2  ,  52  ,  51  ,   0  ,
     .3HE2G ,   2  ,  52  ,  51  ,   0  ,   2  ,  51  ,  52  ,   0  ,
     .3HA1U ,   1  ,   1  ,   1  ,   1  ,  -1  ,  -1  ,  -1  ,  -1  ,
     .3HA2U ,   1  ,   1  ,   1  ,  -1  ,  -1  ,  -1  ,  -1  ,   1  ,
     .3HE1U ,   2  ,  51  ,  52  ,   0  ,  -2  , 101  , 103  ,   0  ,
     .3HE2U ,   2  ,  52  ,  51  ,   0  ,  -2  , 103  , 101  ,   0  /
      DATA D6D
     ./                         3HD6D,
     .2HA1,140468,12130218,6140211,4130214,3140208,12530225,2140103,
     .                                                    20605,2140620,
     .3HA2  , 1 ,    1  , 1 , 1 , 1 ,   1  , 1 ,-1 ,-1 ,
     .3HB1  , 1 ,   -1  , 1 ,-1 , 1 ,  -1  , 1 ,-1 , 1 ,
     .3HB2  , 1 ,   -1  , 1 ,-1 , 1 ,  -1  , 1 , 1 ,-1 ,
     .3HE1  , 2 ,  121  , 1 , 0 ,-1 , 125  ,-2 , 0 , 0 ,
     .3HE2  , 2 ,    1  ,-1 ,-2 ,-1 ,   1  , 2 , 0 , 0 ,
     .3HE3  , 2 ,    0  ,-2 , 0 , 2 ,   0  ,-2 , 0 , 0 ,
     .3HE4  , 2 ,   -1  ,-1 , 2 ,-1 ,  -1  , 2 , 0 , 0 ,
     .3HE5  , 2 ,  125  , 1 , 0 ,-1 , 121  ,-2 , 0 , 0 /
      DATA S4
     ./                         3HS4 ,
     .4HA     ,   8196    ,  4130114,   2140103,  4330123              ,
     .4HB     ,      1    ,   -1    ,    1    ,   -1                   ,
     .4HE     ,      2    ,    0    ,   -2    ,    0                   /
      DATA S6
     ./                         3HS6 ,
     .3HAG ,16576   ,3140108  ,3240122  , 10107 , 6530124 , 6130115    ,
     .3HEG ,   2    ,   -1    ,   -1    ,    2    ,   -1    ,   -1     ,
     .3HAU ,   1    ,    1    ,    1    ,   -1    ,   -1    ,   -1     ,
     .3HEU ,   2    ,   -1    ,   -1    ,   -2    ,    1    ,    1     /
      DATA S8
     ./                         3HS8 ,
     .3HA  ,33028,8130116,4140109,8330123,2140103,8530125,4340135,
     .                                                          8730127,
     .3HB  , 1,    -1     , 1,    -1     , 1,    -1     , 1,    -1     ,
     .3HE1 , 2,    81     , 0,    83     ,-2,    83     , 0,    81     ,
     .3HE2 , 2,     0     ,-2,     0     , 2,     0     ,-2,     0     ,
     .3HE3 , 2,    83     , 0,    81     ,-2,    81     , 0,    83     /
      DATA TD
     ./                         3HTD ,
     .2HA1 ,270516    ,   3140808,    2140303,    4130614, 20605       ,
     .2HA2 ,     1    ,     1    ,     1     ,   -1      ,  -1         ,
     .2HE  ,     2    ,    -1    ,     2     ,    0      ,   0         ,
     .2HT1 ,     3    ,     0    ,    -1     ,    1      ,  -1         ,
     .2HT2 ,     3    ,     0    ,    -1     ,   -1      ,   1         /
      DATA OH
     ./                         3HOH ,
     .3HA1G,287231,3140808,2140601,4140609,2140303,10107,4130614,
     .                                              6130815,20304,20605,
     .3HA2G ,  1 ,  1 , -1 , -1 ,  1 ,  1 , -1 ,  1 ,  1 , -1 ,
     .3HEG  ,  2 , -1 ,  0 ,  0 ,  2 ,  2 ,  0 , -1 ,  2 ,  0 ,
     .3HT1G ,  3 ,  0 , -1 ,  1 , -1 ,  3 ,  1 ,  0 , -1 , -1 ,
     .3HT2G ,  3 ,  0 ,  1 , -1 , -1 ,  3 , -1 ,  0 , -1 ,  1 ,
     .3HA1U ,  1 ,  1 ,  1 ,  1 ,  1 , -1 , -1 , -1 , -1 , -1 ,
     .3HA2U ,  1 ,  1 , -1 , -1 ,  1 , -1 ,  1 , -1 , -1 ,  1 ,
     .3HEU  ,  2 , -1 ,  0 ,  0 ,  2 , -2 ,  0 ,  1 , -2 ,  0 ,
     .3HT1U ,  3 ,  0 , -1 ,  1 , -1 , -3 , -1 ,  0 ,  1 ,  1 ,
     .3HT2U ,  3 ,  0 ,  1 , -1 , -1 , -3 ,  1 ,  0 ,  1 , -1 /
      DATA IH
     ./                         3HIH ,
     .3HAG ,344786,5141210,5241222,3142008,2141502,10107,10131217,
     .                                       10331227,6132015,21505,
     .3HT1G,3,  101    ,  103    , 0,-1, 3,  103    ,  101    , 0 ,-1 ,
     .3HT2G,3,  103    ,  101    , 0,-1, 3,  101    ,  103    , 0 ,-1 ,
     .3HGG ,4,   -1    ,   -1    , 1, 0, 4,   -1    ,   -1    , 1 , 0 ,
     .3HHG ,5,    0    ,    0    ,-1, 1, 5,    0    ,    0    ,-1 , 1 ,
     .3HAU ,1,    1    ,    1    , 1, 1,-1,   -1    ,   -1    ,-1 ,-1 ,
     .3HT1U,3,  101    ,  103    , 0,-1,-3,   51    ,   52    , 0 , 1 ,
     .3HT2U,3,  103    ,  101    , 0,-1,-3,   52    ,   51    , 0 , 1 ,
     .3HGU ,4,   -1    ,   -1    , 1, 0,-4,    1    ,    1    ,-1 , 0 ,
     .3HHU ,5,    0    ,    0    ,-1, 1,-5,    0    ,    0    , 1 ,-1 /
      DATA CV
     ./                         3HC*V,
     .3HSI  ,     524340           ,     4140109          ,
     .3HPI  ,         2            ,           0          ,
     .3HDE  ,         2            ,          -2          /
      DATA DH
     ./                         3HD*H,
     .3HSIG ,     524415       ,    4140109       ,      10107         ,
     .3HPIG ,         2        ,         0        ,         2          ,
     .3HDEG ,         2        ,        -2        ,         2          ,
     .3HSIU ,         1        ,         1        ,        -1          ,
     .3HPIU ,         2        ,         0        ,        -2          ,
     .3HDEU ,         2        ,        -2        ,        -2          /
      SIG=1.D0
      I=IGROUP
      IF(NCODE.LT.0) GOTO 2
      IGROUP=0
      DO 1 I=1,43
      ICHECK=J(I)/10000
      ICHECK=J(I)-10000*ICHECK+2
      ICHECK=JTAB(ICHECK)
      IF(ICHECK.EQ.NCODE) GOTO 2
 1    CONTINUE
      RETURN
 2    IGROUP=I
      JGROUP=J(IGROUP)
      J1=JGROUP/1000000
      KDIM=JGROUP-1000000*J1
      I1=KDIM/10000
      JGROUP=KDIM-10000*I1
      NAME=JTAB(JGROUP)
      SIG=ISIGMA(IGROUP)
      J2=0
      DO 4 I=1,I1
      JGROUP=JGROUP+1
      JX(1,I)=JTAB(JGROUP)
      DO 4 K=1,J1
      JGROUP=JGROUP+1
      BUFF=JTAB(JGROUP)
      IF(I.GT.1) GOTO 3
      JX(2,K)=JTAB(JGROUP)/100
      JX(3,K)=JTAB(JGROUP)-100*JX(2,K)
      JX(4,K)=JX(2,K)/100
      JX(5,K)=JX(2,K)-100*JX(4,K)
      JX(2,K)=JX(5,K)
      JX(5,K)=JX(4,K)/10
      JX(4,K)=JX(4,K)-10*JX(5,K)
      JX(2,1)=1
      JX(3,1)=0
      J2=J2+JX(2,K)
      BUFF=1.D0
 3    IF(BUFF.LT.10.) GOTO 4
      NZZ=JTAB(JGROUP)
      NZ=NZZ/10
      FZ=NZ
      FN=NZZ-10*NZ
      BUFF=2.D0*COS(6.283185307179D0*FN/FZ)
 4    T(I,K)=BUFF
      LINA=IGROUP-41
      RETURN
      END
C
C================================================================
C
      SUBROUTINE R00009(NAT,COORD)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      COMMON /S00001/         T(12,12),JX(7,12),LINA,I1,J1,J2
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      COMMON /S00004/ SHIFT(3),R(3,3),VECT(2,MXDIM)
      DIMENSION HELP(3,3),NAT(NUMATM),COORD(3,NUMATM)
      DO 1 I=1,3
      DO 1 J=1,NUMAT
 1    COORD(I,J)=COORD(I,J)-SHIFT(I)
      CALL R00005(COORD,1)
      IF(J1.LT.2) RETURN
      DO 5 I=2,J1
      JOTA=JX(3,I)
      JOT=1
      IF(JOTA.LE.20) GOTO 2
      JOTB=JOTA/10
      JOT=JOTA-10*JOTB
      JOTA=JX(3,JOTB)
 2    CALL R00006(JOTA,I)
      IF(JOT.EQ.1) GOTO 5
      DO 3 J=1,3
      DO 3 K=1,3
      HELP(J,K)=0.D0
      DO 3 L=1,3
 3    HELP(J,K)=HELP(J,K)+ELEM(J,L,JOT)*ELEM(L,K,I)
      DO 4 J=1,3
      DO 4 K=1,3
 4    ELEM(J,K,I)=HELP(J,K)
 5    CONTINUE
      DO 6 I=2,J1
      CALL R00007(NAT,COORD,I)
      JX(6,I)=IQUAL
      IF(IELEM(I).LT.1) IERROR=5
 6    CONTINUE
      CALL R00005(COORD,-1)
      DO 7 I=1,3
      DO 7 J=1,NUMAT
 7    COORD(I,J)=COORD(I,J)+SHIFT(I)
      RETURN
      END
C
C===================================================================
C
      SUBROUTINE R00010(COEFF,NTYPE,ICOUNT,NCDUM)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      CHARACTER*4  NAME,ISTA
      COMMON /S00001/         T(12,12),JX(7,12),LINA,I1,J1,J2
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      COMMON /S00004/ SHIFT(3),R(3,3),VECT(2,MXDIM)
      COMMON/SYMRES/TRANS,RTR,SIG,NAME,NAMO(MXDIM),INDEX(MXDIM),ISTA(2)
      DIMENSION NTYPE(MXDIM),COEFF(NCDUM,NCDUM)
      DIMENSION CHAR(12),ICOUNT(12)
C      DATA TOLER,IFRA /  0.1, '????'/
      DATA TOLER,IFRA /  0.1, 0.0/
C
      NDORBS=0
      DO 1 I=1,I1
 1    ICOUNT(I)=0
      NAMES=IFRA
      IF(J1.EQ.1) NAMES=JX(1,1)
      DO 2 I=1,NORBS
      INDEX(I)=I
 2    NAMO(I)=NAMES
      IF(J1.EQ.1) RETURN
      IF(IERROR.GT.0) RETURN
      IFOUND=0
      I=0
 3    IK=I+1
      DO 4 J=1,J1
 4    CHAR(J)=0.D0
 5    I=I+1
      IF(I.GT.NORBS) GOTO 10
      DO 6 J=1,J1
      CHAR(J)=CHAR(J)+R00011(COEFF,NTYPE,I,J,NCDUM)
      IF(CHAR(J).GT.10.) GOTO 3
 6    CONTINUE
      DO 9 K=1,I1
      DO 7 J=1,J1
      CHECK=ABS(CHAR(J)-T(K,J))
      IF(CHECK.GT.TOLER) GOTO 9
 7    CONTINUE
      ICOUNT(K)=ICOUNT(K)+1
      DO 8 J=IK,I
      IFOUND=IFOUND+1
      INDEX(J)=ICOUNT(K)
 8    NAMO(J)=JX(1,K)
      GOTO 3
 9    CONTINUE
      GOTO 5
 10   IF(IFOUND.NE.NORBS) IERROR=99
      RETURN
      END
C
C======================================================================
C
      FUNCTION R00011(COEFF,NTYPE,JORB,IOPER,NCDUM)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      COMMON /S00004/ SHIFT(3),R(3,3),VECT(2,MXDIM)
      DIMENSION NTYPE(MXDIM),COEFF(NCDUM,NCDUM),E(3,3,20)
      DIMENSION H(5),P(3),D(5),IP(2,3),ID(2,5),LOC(2,50)
      EQUIVALENCE (ELEM(1,1,1),E(1,1,1))
      R00011=1.D0
      IF(IOPER.EQ.1) RETURN
      DO 1 I=1,NORBS
      VECT(1,I)=0.D0
 1    VECT(2,I)=0.D0
      DO 13 IATOM=1,NUMAT
      JATOM=JELEM(IOPER,IATOM)
      KI=0
      KJ=0
      DO 3 I=1,NORBS
      ICHECK=NTYPE(I)/100
      IF(ICHECK.NE.IATOM) GOTO 2
      KI=KI+1
      LOC(1,KI)=I
 2    IF(ICHECK.NE.JATOM) GOTO 3
      KJ=KJ+1
      LOC(2,KJ)=I
 3    CONTINUE
      IBASE=KI
      DO 4 I=1,IBASE
      ICHECK=LOC(1,I)
      ITEST=NTYPE(ICHECK)-10*(NTYPE(ICHECK)/10)
      IF(ITEST.GT.0) GOTO 4
      JCHECK=LOC(2,I)
      LOC(1,I)=0
      KI=KI-1
      VECT(1,ICHECK)=COEFF(ICHECK,JORB)
      VECT(2,JCHECK)=COEFF(ICHECK,JORB)
 4    CONTINUE
      MINUS=100*IATOM
 5    IF(KI.LT.3) GOTO 13
      DO 6 I=1,3
      IP(1,I)=0
 6    ID(1,I)=0
      ID(1,4)=0
      ID(1,5)=0
      NQZP=-1
      NQZD=-1
      DO 9 I=1,IBASE
      IF(LOC(1,I).LT.1) GOTO 9
      ICHECK=LOC(1,I)
      ITEST=NTYPE(ICHECK)
      INQZ=(ITEST-MINUS)/10
      ILQZ=ITEST-10*(ITEST/10)
      IF(ILQZ.GT.8) GOTO 8
      IF(ILQZ.GT.3) GOTO 7
      IF(NQZP.LT.0) NQZP=INQZ
      IF(INQZ.NE.NQZP) GOTO 9
      P(ILQZ)=COEFF(ICHECK,JORB)
      IP(1,ILQZ)=LOC(1,I)
      IP(2,ILQZ)=LOC(2,I)
      GOTO 8
 7    IF(NQZD.LT.0) NQZD=INQZ
      IF(INQZ.NE.NQZD) GOTO 9
      ILQZ=ILQZ-3
      D(ILQZ)=COEFF(ICHECK,JORB)
      ID(1,ILQZ)=LOC(1,I)
      ID(2,ILQZ)=LOC(2,I)
 8    LOC(1,I)=0
      KI=KI-1
 9    CONTINUE
      IF(NQZP.LT.0) GOTO 11
      H(1)=R(1,1)*P(1)+R(2,1)*P(2)+R(3,1)*P(3)
      H(2)=R(1,2)*P(1)+R(2,2)*P(2)+R(3,2)*P(3)
      H(3)=R(1,3)*P(1)+R(2,3)*P(2)+R(3,3)*P(3)
      P(1)=E(1,1,IOPER)*H(1)+E(1,2,IOPER)*H(2)+E(1,3,IOPER)*H(3)
      P(2)=E(2,1,IOPER)*H(1)+E(2,2,IOPER)*H(2)+E(2,3,IOPER)*H(3)
      P(3)=E(3,1,IOPER)*H(1)+E(3,2,IOPER)*H(2)+E(3,3,IOPER)*H(3)
      DO 10 I=1,3
      IF(IP(1,I).LT.1) GOTO 16
      II=IP(1,I)
      JJ=IP(2,I)
      VECT(1,II)=H(I)
 10   VECT(2,JJ)=P(I)
 11   IF(NQZD.LT.0) GOTO 5
      CALL R00012(D,H,IOPER)
      DO 12 I=1,5
      IF(ID(1,I).LT.1) GOTO 16
      II=ID(1,I)
      JJ=ID(2,I)
      VECT(1,II)=H(I)
 12   VECT(2,JJ)=D(I)
      KI=KI-5
      GOTO 5
 13   CONTINUE
      C1=0.D0
      C2=0.D0
      DO 14 I=1,NORBS
      C1=C1+VECT(1,I)*VECT(1,I)
 14   C2=C2+VECT(1,I)*VECT(2,I)
      IF(ABS(C1).LT.1.E-5) GOTO 15
      R00011=C2/C1
      RETURN
 15   R00011=100.D0
      RETURN
 16   IERROR=98
      RETURN
      END
C
C=======================================================================
C
      SUBROUTINE R00012(D,H,IOPER)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      COMMON /S00001/         T(12,12),JX(7,12),LINA,I1,J1,J2
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /S00003/ IELEM(20),ELEM(3,3,20),CUB(3,3),JELEM(20,NUMATM)
      COMMON /S00004/ SHIFT(3),R(3,3),VECT(2,MXDIM)
      DIMENSION D(5),H(5),T1(5,5,12),S(3,3)
      CHARACTER JX*4
      IF(NDORBS.GT.0) GOTO 4
      NDORBS=1
      DO 1 I=1,3
      DO 1 J=1,3
 1    S(I,J)=R(I,J)
      CALL R00013(S,T1,1)
      DO 3 K=2,J1
      DO 2 I=1,3
      DO 2 J=1,3
 2    S(I,J)=ELEM(I,J,K)
      CALL R00013(S,T1,K)
 3    CONTINUE
 4    DO 5 I=1,5
      H(I)=0.D0
      DO 5 J=1,5
 5    H(I)=H(I)+T1(I,J,1)*D(J)
      DO 6 I=1,5
      D(I)=0.D0
      DO 6 J=1,5
 6    D(I)=D(I)+T1(I,J,IOPER)*H(J)
      RETURN
      END
C
C=================================================================
C
      SUBROUTINE R00013(R,T,IOPER)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION R(3,3),T(5,5,12),F(2,4)
      LOGICAL RIGHT
      DATA PI,TOL,S12 / 3.1415926536D0 ,0.001D0,3.46410161513D0 /
      DATA S3,ONE     / 1.73205080756D0 , 1.D0 /
      R1=R(2,1)*R(3,2)-R(3,1)*R(2,2)
      R2=R(3,1)*R(1,2)-R(1,1)*R(3,2)
      R3=R(1,1)*R(2,2)-R(2,1)*R(1,2)
      CHECK=R1*R(1,3)+R2*R(2,3)+R3*R(3,3)
      RIGHT=CHECK.GT.0.
      R(1,3)=R1
      R(2,3)=R2
      R(3,3)=R3
      ARG=R3
      IF(ABS(ARG).GT.ONE) ARG=SIGN(ONE,ARG)
      B= ACOS(ARG)
      SINA=SQRT(1.D0-ARG*ARG)
      IF(SINA.LT.TOL) GOTO 1
      ARG=R(3,2)/SINA
      IF(ABS(ARG).GT.ONE) ARG=SIGN(ONE,ARG)
      G= ASIN(ARG)
      ARG=R(2,3)/SINA
      IF(ABS(ARG).GT.ONE) ARG=SIGN(ONE,ARG)
      A= ASIN(ARG)
      GOTO 2
 1    ARG=R(1,2)
      IF(ABS(ARG).GT.ONE) ARG=SIGN(ONE,ARG)
      G= ASIN(ARG)
      A=0.D0
 2    F(1,1)=A
      F(1,2)=A
      F(1,3)=PI-A
      F(1,4)=PI-A
      F(2,1)=G
      F(2,3)=G
      F(2,2)=PI-G
      F(2,4)=PI-G
      DO 3 I=1,4
      A=F(1,I)
      G=F(2,I)
      CHECK=ABS(SIN(B)*COS(A)+R(1,3))
      IF(CHECK.GT.TOL) GOTO 3
      CHECK=-SIN(G)*COS(B)*SIN(A)+COS(G)*COS(A)
      IF(ABS(CHECK-R(2,2)).GT.TOL) GOTO 3
      CHECK=SIN(A)*COS(G)+COS(A)*COS(B)*SIN(G)
      IF(ABS(CHECK-R(1,2)).LE.TOL) GOTO 4
 3    CONTINUE
 4    G=-G
      A=-A
      B=-B
      E1=COS(B*0.5D0)
      X1=-SIN(B*0.5D0)
      E2=E1*E1
      E3=E1*E2
      E4=E2*E2
      X2=X1*X1
      X3=X1*X2
      X4=X2*X2
      TA=2.D0*A
      TG=2.D0*G
      T(1,1,IOPER)=E4*COS(TA+TG)+X4*COS(TA-TG)
      T(1,2,IOPER)=2.D0*E3*X1*COS(A+TG)-2.D0*E1*X3*COS(A-TG)
      T(1,3,IOPER)=2.D0*S3*E2*X2*COS(TG)
      T(1,4,IOPER)=2.D0*E3*X1*SIN(A+TG)-2.D0*E1*X3*SIN(A-TG)
      T(1,5,IOPER)=E4*SIN(TA+TG)+X4*SIN(TA-TG)
      T(2,1,IOPER)=2.D0*E1*X3*COS(TA-G)-2.D0*E3*X1*COS(TA+G)
      T(2,2,IOPER)=(E4-3.D0*E2*X2)*COS(A+G)-(3.D0*E2*X2-X4)*COS(A-G)
      T(2,3,IOPER)=2.D0*S3*(E3*X1-E1*X3)*COS(G)
      T(2,4,IOPER)=(E4-3.D0*E2*X2)*SIN(A+G)-(3.D0*E2*X2-X4)*SIN(A-G)
      T(2,5,IOPER)=-2.D0*E3*X1*SIN(TA+G)+2.D0*E1*X3*SIN(TA-G)
      T(3,1,IOPER)=S12*E2*X2*COS(TA)
      T(3,2,IOPER)=-S12*(E3*X1-E1*X3)*COS(A)
      T(3,3,IOPER)=E4-4.D0*E2*X2+X4
      T(3,4,IOPER)=-S12*(E3*X1-E1*X3)*SIN(A)
      T(3,5,IOPER)=S12*E2*X2*SIN(TA)
      T(4,1,IOPER)=2.D0*E1*X3*SIN(TA-G)+2.D0*E3*X1*SIN(TA+G)
      T(4,2,IOPER)=-(E4-3.D0*E2*X2)*SIN(A+G)-(3.D0*E2*X2-X4)*SIN(A-G)
      T(4,3,IOPER)=-2.D0*S3*(E3*X1-E1*X3)*SIN(G)
      T(4,4,IOPER)=(E4-3.D0*E2*X2)*COS(A+G)+(3.D0*E2*X2-X4)*COS(A-G)
      T(4,5,IOPER)=-2.D0*E3*X1*COS(TA+G)-2.D0*E1*X3*COS(TA-G)
      T(5,1,IOPER)=-E4*SIN(TA+TG)+X4*SIN(TA-TG)
      T(5,2,IOPER)=-2.D0*E3*X1*SIN(A+TG)-2.D0*E1*X3*SIN(A-TG)
      T(5,3,IOPER)=-2.D0*S3*E2*X2*SIN(TG)
      T(5,4,IOPER)=2.D0*E3*X1*COS(A+TG)+2.D0*E1*X3*COS(A-TG)
      T(5,5,IOPER)=E4*COS(TA+TG)-X4*COS(TA-TG)
      IF(RIGHT) RETURN
      DO 5 I=1,5
      T(2,I,IOPER)=-T(2,I,IOPER)
 5    T(4,I,IOPER)=-T(4,I,IOPER)
      RETURN
      END
C
C======================================================================
C
      SUBROUTINE R00015(F,V,EW)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION F(6),A(3,3),V(3,3),EW(3)
      DATA TOLER /1.E-6 /
      N=3
      IJ=0
      DO 2 J=1,N
      DO 1 I=1,J
      IJ=IJ+1
      A(I,J)=F(IJ)
      A(J,I)=F(IJ)
      V(I,J)=0.D0
 1    V(J,I)=0.D0
 2    V(J,J)=1.D0
      N1=N-1
      ZETA=10.D0
 3    SS=0.D0
      DO 4 J=1,N1
      DO 4 I=J,N1
      IRG=I+1
 4    SS=SS+ABS(A(IRG,J))
      IF(SS-TOLER) 21,21,5
 5    TAU=0.D0
      DO 20 I=1,N
      I1=I+1
      IF(N-I1) 20,6,6
 6    DO 19 J=I1,N
      IF(ABS(A(J,I)).LT.1.E-30) GOTO 19
      THETA=0.5D0*(A(J,J)-A(I,I))/A(J,I)
      IF(ABS(THETA)-ZETA) 7,7,19
 7    T=1.D0
      IF(THETA) 8,9,9
 8    T=-1.D0
 9    T=1.D0/(THETA+T*SQRT(1.D0+THETA*THETA))
      C=1.D0/SQRT(1.D0+T*T)
      S=C*T
      H=2.D0*A(J,I)
      HC=S*H*(S*THETA-C)
      A(I,I)=A(I,I)+HC
      A(J,J)=A(J,J)-HC
      A(J,I)=-H*C*(S*THETA-0.5D0*(C-S*S/C))
      TAU=TAU+1.D0
      IF(I.LT.2) GOTO 11
      DO 10 IG=2,I
      IRS=IG-1
      H=C*A(I,IRS)-S*A(J,IRS)
      A(J,IRS)=S*A(I,IRS)+C*A(J,IRS)
 10   A(I,IRS)=H
 11   L=J-1
      IF(L-I1) 14,12,12
 12   DO 13 IG=I1,L
      H=C*A(IG,I)-S*A(J,IG)
      A(J,IG)=S*A(IG,I)+C*A(J,IG)
 13   A(IG,I)=H
 14   IF(N1-J) 17,15,15
 15   DO 16 IG=J,N1
      ILG=IG+1
      H=C*A(ILG,I)-S*A(ILG,J)
      A(ILG,J)=S*A(ILG,I)+C*A(ILG,J)
 16   A(ILG,I)=H
 17   DO 18 IG=1,N
      H=C*V(IG,I)-S*V(IG,J)
      V(IG,J)=S*V(IG,I)+C*V(IG,J)
 18   V(IG,I)=H
 19   CONTINUE
 20   CONTINUE
      H=0.5D0*FLOAT(N*(N-1))
      ZETA=ZETA**(2.5D0-TAU/H)
      GOTO 3
 21   DO 22 J=1,N
 22   EW(J)=A(J,J)
      N1=N-1
 23   NT=0
      DO 26 J=1,N1
      JRG=J+1
      IF(EW(J)-EW(JRG)) 26,26,24
 24   BUFFER=EW(J)
      EW(J)=EW(JRG)
      EW(JRG)=BUFFER
      DO 25 I=1,N
      BUFFER=V(I,JRG)
      V(I,JRG)=V(I,J)
 25   V(I,J)=BUFFER
      NT=1
 26   CONTINUE
      N1=N1-1
      IF(NT) 23,27,23
 27   RETURN
      END
C
C===================================================================
C
      SUBROUTINE R00016
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
      CHARACTER*4 NAME,NAMO,ISTA
      COMMON /S00001/         T(12,12),JX(7,12),LINA,I1,J1,J2
      COMMON /S00002/ NUMAT,NORBS,NADIM,NCDIM,IQUAL,NDORBS,IERROR
      COMMON /SYMINF/ IBASE(2,12),NBASE,IVIBRO(2,12),IVIB
      COMMON/SYMRES/TRANS,RTR,SIG,NAME,NAMO(MXDIM),INDEX(MXDIM),ISTA(2)
      DIMENSION CHAR(12),COEFF(12)
      IVIBRA=3*NUMAT-6
      IF(LINA.GT.0) GOTO 8
      CHAR(1)=IVIBRA
      IVIB=0
      IF(J1.LT.2) RETURN
      DO 5 I=2,J1
      JUMP=JX(4,I)
      GOTO (1,2,3,4),JUMP
 1    CHAR(I)=-3*JX(6,I)
      GOTO 5
 2    CHAR(I)=JX(6,I)
      GOTO 5
 3    JP=JX(5,I)/10
      JK=JX(5,I)-10*JP
      ANGLE=2.D0*COS(6.283185308D0*DBLE(JK)/DBLE(JP))
      CHAR(I)=DBLE(JX(6,I))*(ANGLE-1.D0)
      GOTO 5
 4    JP=JX(5,I)/10
      JK=JX(5,I)-10*JP
      ANGLE=2.D0*COS(6.283185308D0*DBLE(JK)/DBLE(JP))
      CHAR(I)=DBLE(JX(6,I)-2)*(ANGLE+1.D0)
 5    CHAR(I)=CHAR(I)*DBLE(JX(2,I))
      ORDER=DBLE(J2)
      DO 7 I=1,I1
      COEFF(I)=0.1D0
      DO 6 J=1,J1
 6    COEFF(I)=COEFF(I)+CHAR(J)*T(I,J)/ORDER
      IF(COEFF(I).LT.1.) GOTO 7
      IDEGEN=     T(I,1)+0.1D0
      IVIB=IVIB+1
      IVIBRO(1,IVIB)=     COEFF(I)
      IF(I1.NE.J1) IVIBRO(1,IVIB)=     COEFF(I) /IDEGEN
      IVIBRO(2,IVIB)=JX(1,I)
 7    CONTINUE
      RETURN
 8    IVIBRA=IVIBRA+1
      GOTO(9,10),LINA
 9    IVIBRO(1,1)=NUMAT-1
      IVIBRO(2,1)=JX(1,1)
      IVIBRO(1,2)=NUMAT-2
      IVIBRO(2,2)=JX(1,2)
      IVIB=2
      IF(NUMAT.LT.3) IVIB=1
      RETURN
 10   ICENT=JX(6,3)
      IVIBRO(1,1)=(NUMAT-ICENT)/2
      IVIBRO(2,1)=JX(1,1)
      IVIB=2
      IVIBRO(1,2)=(NUMAT-2-ICENT)/2
      IVIBRO(2,2)=JX(1,2)
      IF(IVIBRO(1,2).GT.0) IVIB=3
      IVIBRO(1,IVIB)=(NUMAT-2+ICENT)/2
      IVIBRO(2,IVIB)=JX(1,4)
      IF(IVIBRO(1,IVIB).GT.0) IVIB=IVIB+1
      IVIBRO(1,IVIB)=(NUMAT-2+ICENT)/2
      IVIBRO(2,IVIB)=JX(1,5)
      IF(IVIBRO(1,IVIB).LT.1) IVIB=IVIB-1
      RETURN
      END
