# help to check if AllUtils is missing anything

use 5.10.0;

use strict;
use warnings;

use List::AllUtils;
use Module::Runtime qw/ use_module /;

for my $module ( keys %List::AllUtils::ALL_EXPORTS ) {
    use_module( $module );

    say "## ", $module;

    for my $function ( eval '@'.$module.'::EXPORT_OK' ) {
        my $f = $List::AllUtils::EXPORTED_FUNCTIONS{$function} or do {
            say "we're missing $function";
            next;
        };
        my ($source) = keys %$f;
        say "using $source\'s $function" if $source ne $module;
    }

}