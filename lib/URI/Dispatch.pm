use Modern::Perl;
use MooseX::Declare;

class URI::Dispatch {
    use URI::Dispatch::Route;
    
    has routes => (
        isa     => 'ArrayRef',
        is      => 'ro',
        builder => 'build_routes',
    );
    
    method build_routes {
        return [];
    }
    
    
    method add ( $path, $handler ) {
        my $route = URI::Dispatch::Route->new(
                path => $path,
                handler => $handler
            );
        push @{ $self->routes }, $route;
    }
    method handler ( $path ) {
        foreach my $route ( @{ $self->routes } ) {
            my( $handler, $options ) = $route->match_path( $path );
            return( $handler, $options )
                if defined $handler;
        }
        
        return;
    }
}
