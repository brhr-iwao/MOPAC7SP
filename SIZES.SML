*COMDECK SIZES                                                          
************************************************************************
*   THIS FILE CONTAINS ALL THE ARRAY SIZES FOR USE IN MOPAC.            
*                                                                       
*     THERE ARE ONLY 5 PARAMETERS THAT THE PROGRAMMER NEED SET:          
*     MAXHEV = MAXIMUM NUMBER OF HEAVY ATOMS (HEAVY: NON-HYDROGEN ATOMS)
*     MAXLIT = MAXIMUM NUMBER OF HYDROGEN ATOMS.                        
*     MAXTIM = DEFAULT TIME FOR A JOB. (SECONDS)                        
*     MAXDMP = DEFAULT TIME FOR AUTOMATIC RESTART FILE GENERATION (SECS)
*     ISYBYL = 1 IF MOPAC IS TO BE USED IN THE SYBYL PACKAGE, =0 OTHERWISE
*     SEE ALSO NMECI, NPULAY AND MESP AT THE END OF THIS FILE
*                                                                       
*     For a small version, do not forget to use FDUMMY sources instead
*     of FLARGE ones in Makefile!
*
      PARAMETER (MAXHEV=15, MAXLIT=24)
      PARAMETER (MAXTIM=3600, MAXDMP=3600)
      PARAMETER (ISYBYL=0)
*                                                                       
************************************************************************
*                                                                       
*   THE FOLLOWING CODE DOES NOT NEED TO BE ALTERED BY THE PROGRAMMER    
*                                                                       
************************************************************************
*                                                                       
*    ALL OTHER PARAMETERS ARE DERIVED FUNCTIONS OF THESE TWO PARAMETERS 
*                                                                       
*      NAME                   DEFINITION                                
*     NUMATM         MAXIMUM NUMBER OF ATOMS ALLOWED.                   
*     MAXORB         MAXIMUM NUMBER OF ORBITALS ALLOWED.                
*     MAXPAR         MAXIMUM NUMBER OF PARAMETERS FOR OPTIMISATION.     
*     N2ELEC         MAXIMUM NUMBER OF TWO ELECTRON INTEGRALS ALLOWED.  
*     MPACK          AREA OF LOWER HALF TRIANGLE OF DENSITY MATRIX.     
*     MORB2          SQUARE OF THE MAXIMUM NUMBER OF ORBITALS ALLOWED.  
*     MAXHES         AREA OF HESSIAN MATRIX                             
*     MAXALL         LARGER THAN MAXORB OR MAXPAR.
************************************************************************
      PARAMETER (VERSON=7.00D0)
      PARAMETER (NUMATM=MAXHEV+MAXLIT)
      PARAMETER (MAXORB=4*MAXHEV+MAXLIT)
      PARAMETER (MAXPAR=3*NUMATM)
      PARAMETER (MAXBIG=MAXORB*MAXORB*2)
      PARAMETER (N2ELEC=(50*MAXHEV*(MAXHEV-1)+10*MAXHEV*MAXLIT
     +                     +(MAXLIT*(MAXLIT-1))/2))
      PARAMETER (MAXHES=(MAXPAR*(MAXPAR+1))/2,MORB2=MAXORB**2)
      PARAMETER (MPACK=(MAXORB*(MAXORB+1))/2)
      PARAMETER (MAXPR=6*MAXORB)
      PARAMETER (MAXALL=4*MAXHEV+3*MAXLIT)
      PARAMETER (NMECI=8, NPULAY=MPACK, MMCI=60)
      PARAMETER (MESP=50000)
      PARAMETER (LENABC=400)
      PARAMETER (LENAB2=LENABC*(LENABC+5))
      PARAMETER (NPPA = 1082, MAXNSS = 500)
      PARAMETER (MAXDEN=10*MAXHEV+MAXLIT)
*    For a small version, disable green functions support, since they need
*    a horrible amount of memory
      PARAMETER (IGREEN=0)
************************************************************************
*DECK MOPAC 
