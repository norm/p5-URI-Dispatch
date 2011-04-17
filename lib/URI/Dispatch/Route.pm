use Modern::Perl;
use MooseX::Declare;

class URI::Dispatch::Route {
    use Ouch    qw( :traditional );
    
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
    has path_match => (
        isa     => 'Str',
        is      => 'ro',
        lazy    => 1,
        builder => 'build_match',
    );
    my $STRIP_ARGS = qr{
        ^
            (?'before' [^\#]+ )
            (?:
                \#
                (?: (?'name' \w+ ) : )?
                (?:
                    (?'anything' \*           ) |
                    (?'builtin'  \w+          ) |
                    (?'regexp'   \( [^\)]+ \) )
                )
            )?
    }x;
    
    method build_match {
        my $path  = $self->path;
        my $match = '^';
        
        # replace (named) params with captures
        while ( $path =~ s{$STRIP_ARGS}{}x ) {
            my %arg = %+;
            
            $arg{'before'} =~ s{([^\w])}{\\$1}g;
            $match .= $arg{'before'};
            
            next
                unless defined $arg{'anything'}
                or defined $arg{'builtin'}
                or defined $arg{'regexp'};
            
            if ( defined $arg{'regexp'} ) {
                $match .= $arg{'regexp'};
            }
            else {
                my $builtin = $arg{'builtin'};
                $builtin = 'anything'
                    if defined $arg{'anything'};
                
                my $builder = "param_$builtin";
                
                if ( $self->can( $builder ) ) {
                    my $name = $arg{'name'};
                    
                    $match .= '('
                            . ( $name ? "?<$name> " : '' )
                            . $self->$builder()
                            . ')';
                }
                else {
                    throw 'no_param', "No param of type '$builtin'", $builtin;
                }
            }
        }

        # exchange [] for non-capturing groups
        my $opening = $match =~ s{\\\[}{(?:}g;
        my $closing = $match =~ s{\\\]}{)?}g;
        throw(
                'unmatched_braces',
                sprintf( "Unmatched braces found in %s", $self->path ),
            ) if $opening != $closing;
        
        return "$match\$";
    }
    
    
    method match_path ( $path ) {
        my $match = $self->path_match;
        
        if ( $path =~ m{$match}x ) {
            my %match = %+;
            my @args;

            push @args, $1 if defined $1;
            push @args, $2 if defined $2;
            push @args, $3 if defined $3;
            push @args, $4 if defined $4;
            push @args, $5 if defined $5;
            push @args, $6 if defined $6;
            push @args, $7 if defined $7;
            push @args, $8 if defined $8;
            push @args, $9 if defined $9;
            
            return (
                    {
                        args => \@args,
                        keys => \%match,
                    },
                );
        }
        
        return;
    }
    
    
    method param_id {
        return "[0-9]+";
    }
    method param_year {
        return "[0-9]{4}";
    }
    method param_month {
        return "01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12";
    }
    method param_day {
        return "0[1-9] | [12][0-9] | 30 | 31";
    }
    method param_slug {
        return "[a-z0-9-]+";
    }
    method param_anything {
        return ".+?";
    }
}
