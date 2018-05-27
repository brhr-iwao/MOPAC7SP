#include <stdio.h>
#include <stdlib.h>

#define	F2C	"f2c"
#define	GCC	"gcc"
#define MAXCMD	(31*1024)

#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS	0
#endif
#ifndef EXIT_FAILURE
#define	EXIT_FAILURE	~EXIT_SUCCESS
#endif

int
FortranFile( char *p )
{
p += strlen( p ) - 2 ;
return strcmp( p, ".f" ) == 0 || strcmp( p, ".F" ) == 0 ;
}

int
FortranArg( char *p )
{
return strcmp ( p, "-A"     ) == 0 || strcmp ( p, "-p"    ) == 0 ||
       strncmp( p, "-Nn", 3 ) == 0 || strncmp( p, "-T", 2 ) == 0 ;
}

int
CommonArg( char *p )
{
return strcmp( p, "-g" ) == 0 ;
}

char *
MakeCName( char *p )
{
	char	*c = malloc( strlen( p ) + 1 ) ;

strcpy( c, p ) ;
c[ strlen( c ) - 1 ] = 'c' ;
return c ;
}

int
RunCompiler( char **args )
{
	char	cmd[ MAXCMD ] = "" ;
	int	i ;

for( i = 0 ; args[ i ] != NULL ; i++ ){
    strcat( cmd, args[ i ] ) ;
    if( args[ i+1 ] != NULL )
        strcat( cmd, " " ) ;
    }
return system( cmd ) ;
}

int
main( int argc, char *argv[] )
{
	char	**ftn_fils ;
	char	**ftn_args ;
	char	**fin_args ;
	int	n_ftn_fils = 0 ;
	int	n_ftn_args = 1 ;
	int	n_fin_args = 1 ;
	int	i ;

if( ( ftn_fils = calloc( sizeof( char * ), argc + 1 ) ) == NULL ||
    ( ftn_args = calloc( sizeof( char * ), argc + 1 ) ) == NULL ||
    ( fin_args = calloc( sizeof( char * ), argc + 1 ) ) == NULL ){
    perror( "Out of memory in f77 driver!\n" ) ;
    return EXIT_FAILURE ;
    }
ftn_args[0] = F2C ;
fin_args[0] = GCC ;
for( i = 1 ; i < argc ; i++ ){
         if( FortranFile( argv[i] ) ){
            ftn_fils[ n_ftn_fils++ ] = argv[i] ;
            fin_args[ n_fin_args++ ] = MakeCName( argv[i] ) ;
            }
    else if( FortranArg( argv[i] ) ){
            ftn_args[ n_ftn_args++ ] = argv[i] ;
            }
    else if( CommonArg( argv[i] ) ){
            ftn_args[ n_ftn_args++ ] = argv[i] ;
            fin_args[ n_fin_args++ ] = argv[i] ;
            }
    else {
            fin_args[ n_fin_args++ ] = argv[i] ;
            }
    }
for( i = 0 ; i < n_ftn_fils ; i++ ){
    ftn_args[n_ftn_args] = ftn_fils[i] ;
    if( RunCompiler( ftn_args ) != 0 ){
        fprintf( stderr, "Intermediate compiling %s\n", ftn_fils[i] ) ;
        return EXIT_FAILURE ;
        }
    }
return RunCompiler( fin_args ) ;
}
