#include <pc.h>
#include <dos.h>
#include <std.h>
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <f2c.h>

real etime_(real tim_buf[2])
{
static  char		first_call = 1 ;
static	double		start ;
        struct time     tim ;
        struct date     dat ;
        double		hrs, mins, secs, time ;

gettime( &tim ) ;
getdate( &dat ) ;
hrs  = (double)dat.da_day * 24.0 + (double)tim.ti_hour ;
mins = hrs  * 60.0 + (double) tim.ti_min ;
secs = mins * 60.0 + (double) tim.ti_sec ;
time = secs        + (double) tim.ti_hund / 100.0 ;
if( first_call ){
    first_call = 0 ;
    start = time ;
    }
tim_buf[0] = time - start ;
tim_buf[1] = 0 ;
return time - start ;
}

void fdate_(char *buf, ftnlen len)
{
	time_t	t = time(NULL) ;
	char *	p = asctime(localtime(&t)) ;

memcpy( buf, p, min( len, 24 ) ) ;
}
