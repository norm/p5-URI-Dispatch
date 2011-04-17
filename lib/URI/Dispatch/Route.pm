use Modern::Perl;
use MooseX::Declare;

class URI::Dispatch::Route {
    has path => (
        isa      => 'Str',
        is       => 'ro',
        required => 1,
    );
    has handler => (
        isa      => 'Str',
        is       => 'ro',
        required => 1,
    );
    
    
    method match_path ( $path ) {
        return 1
            if $path eq $self->path;
    }
}