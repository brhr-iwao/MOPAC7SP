#
#   Makefile for making the executable of program MOPAC
#
#
#    Valid Commands of this makefile
#
#	make		Makes the MOPAC file
#	make clean	Clean up disk to minimum config
#
F77             = ./f77pc
CC		= gcc
FFLAGS	        = -A -b i386-any-go32 -O2 -finline-functions -ffast-math -m486 
LD              = gcc -b i386-any-go32 -Wl,-Map,mopac.map
LIBS            = -lf2c -lm
#
#F77		= f77
#CC		= cc
#FFLAGS		= -non_shared -static -O2 -g3
#LD		= $(F77) $(FFLAGS)
#LIBS		= 
#
RM              = rm
HDRS		= SIZES

FLARGE		= greenf.f esp.f
DUMMIES		= fdummy.f
FEXTRA		= $(DUMMIES)
FSRCS		= \
aababc.f addfck.f addhcr.f addnuc.f analyt.f anavib.f axis.f block.f \
bonds.f brlzon.f btoc.f calpar.f capcor.f cdiag.f chrge.f cnvg.f \
compfg.f consts.f cqden.f datin.f dcart.f delmol.f delri.f denrot.f \
densit.f depvar.f deri0.f deri1.f deri2.f deri21.f deri22.f deri23.f \
deritr.f deriv.f dernvo.f ders.f dfock2.f dfpsav.f dgemm.f dgemv.f \
dger.f dgetf2.f dgetrf.f dgetri.f diag.f diat.f diat2.f diegrd.f \
dielen.f diis.f dijkl1.f dijkl2.f dipind.f dipole.f dlaswp.f dofs.f \
dot.f drc.f drcout.f dtrmm.f dtrmv.f dtrsm.f dtrti2.f dtrtri.f dvfill.f \
ef.f enpart.f exchng.f ffhpol.f flepo.f fmat.f fock1.f fock2.f \
force.f formxy.f forsav.f frame.f freqcy.f geout.f geoutg.f getgeg.f \
getgeo.f getsym.f gettxt.f gmetry.f gover.f grid.f h1elec.f \
haddon.f hcore.f helect.f hqrii.f ijkl.f ilaenv.f initsv.f interp.f \
iter.f jcarin.f linmin.f local.f locmin.f lsame.f makpol.f mamult.f \
matou1.f matout.f matpak.f meci.f mecid.f mecih.f mecip.f moldat.f \
molval.f mopac.f mullik.f mult.f nllsq.f nuchar.f parsav.f partxy.f \
pathk.f paths.f perm.f polar.f powsav.f powsq.f prtdrc.f quadr.f \
react1.f reada.f readmo.f refer.f repp.f rotat.f rotate.f rsp.f \
search.f second.f setupg.f solrot.f swap.f sympro.f symtry.f symtrz.f \
thermo.f timer.f timout.f update.f vecprt.f writmo.f wrtkey.f \
wrttxt.f xerbla.f xyzint.f $(FEXTRA)

CSRCS		= f2c_mopac.c

OBJS		= $(FSRCS:.f=.o) $(CSRCS:.c=.o)
MOPAC		= mopac
MOPACSHELL	= mopac.csh
BINDIR		= /usr/local/bin
OWNER		= root.bin

$(MOPAC):     	f77pc SIZES $(OBJS) 
		@echo -n "Loading $@ ... "
		$(LD) -o $@ $(OBJS) $(LIBS)
		@echo "done"

.SUFFIXES: .c .f

f77pc:		f77pc.c
	$(CC) -o f77pc f77pc.c

$(FSRCS:.f=.o):	$($@:.o=.f)
	$(F77) -c $(FFLAGS) $(@:.o=.f)

$(CSRCS:.c=.o): $($@:.o=.c)
	$(F77) -c $(FFLAGS) $(@:.o=.c)

clean:
	 	$(RM) $(OBJS) $(FSRCS:.f=.c) $(DUMMIES:.f=.c) $(FLARGE:.f=.c) $(DUMMIES:.f=.o) $(FLARGE:.f=.o)

cleandepend:
		$(RM) $(SIZEDEPEND) *.trace core

cleanall:	clean
		$(RM) $(MOPAC)

deinstall:
		$(RM) $(BINDIR)/$(MOPAC) $(BINDIR)/$(MOPACSHELL)

install:	$(MOPAC) $(MOPACSHELL)
		strip $(MOPAC)
		chmod 755 $(MOPAC) $(MOPACSHELL)
		chown $(OWNER) $(MOPAC) $(MOPACSHELL)
		/bin/cp -p $(MOPAC) $(BINDIR)/$(MOPAC)
		/bin/cp -p $(MOPACSHELL) $(BINDIR)/$(MOPACSHELL)

ftnchek:
		ftnchek -array=2 -volatile -wordsize=4 -common=2 -pure=no -truncation=no -verbose=no -pretty=no -calltree $(SRCS)

###
