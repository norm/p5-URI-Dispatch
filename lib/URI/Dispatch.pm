use Modern::Perl;
use MooseX::Declare;

class URI::Dispatch {
    use URI::Dispatch::Route;
    
    has routes => (
        isa     => 'HashRef',
        is      => 'ro',
        builder => 'build_routes',
    );
    
    method build_routes {
        return {};
    }
    
    
    method add ( $path, $handler ) {
        my $route = URI::Dispatch::Route->new(
                path => $path,
                handler => $handler
            );
        $self->routes->{ $handler } = $route;
    }
    method handler ( $path ) {
        foreach my $handler ( keys %{ $self->routes } ) {
            my $route   = $self->routes->{ $handler };
            my $options = $route->match_path( $path );
            
            return( $handler, $options )
                if defined $options;
        }
        
        return;
    }
}
