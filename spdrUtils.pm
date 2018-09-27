package spdrUtils;

BEGIN {

   use Exporter;

   $VERSION = 1.00;

   @ISA = qw( Exporter );
   @EXPORT = qw( &arguments &decode_chars &make_safe );

}

sub arguments( @ ) {
   $arguments = <STDIN>;
   if ( $_[ 0 ] ) {
      if ( open( ACCESS, ">>/Logs/CGI.log" ) ) {
         unless ( $user = $ENV{ 'REMOTE_USER' } ) {
            $user = '-';
         }
         print ACCESS "$ENV{ 'REMOTE_ADDR' } $user [". localtime() .
               "] $ENV{ 'HTTP_HOST' }$ENV{ 'SCRIPT_NAME' } $arguments\n";
         close( ACCESS );
      }
   }
   $arguments =~ s/
//g;
   return split( /[=&]/, $arguments );
}

sub decode_chars {
   for ( @_ ) {
      $_ =~ s/\+([^\+])/ $1/g; #Keeps trailing pluses (often unencoded) safe.
      $_ =~ s/%(\w)(\w)/sprintf( "%c", hex( "$1$2" ) )/eg;
      $_ =~ s/\%26/\&/g;
   }
}

sub make_safe {
   for ( @_ ) {
      $_ =~ s/&/&#38;/g;
      $_ =~ s/</&#60;/g;
   } 
}

END { }

1;