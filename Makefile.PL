use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'URI::Dispatch',
    AUTHOR              => 'Mark Norman Francis <norm@cackhanded.net>',
    VERSION_FROM        => 'lib/URI/Dispatch.pm',
    ABSTRACT_FROM       => 'lib/URI/Dispatch.pm',
    PL_FILES            => {},
    EXE_FILES           => [ 
    ],
    PREREQ_PM => {
        'Modern::Perl'    => 0,
        'version'         => 0,
        'MooseX::Declare' => 0,
        'Ouch'            => 0.03,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'URI-Dispatch-*' },
);
