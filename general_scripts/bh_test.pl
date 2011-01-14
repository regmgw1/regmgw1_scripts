#! perl -sw

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Performs Benjamini-Hochberg p-value correction

=cut

########################
# Performs Benjamini-Hochberg p-value correction
#######################
use strict;
use List::Util qw[ min ];

my %pvalues = (
    1=> 0.5453980,
    2=> 0.4902384,
    3=> 0.8167950,
    4=> 0.2821822,
    5=> 0.4693030,
    6=> 0.6491767,
    7=> 0.9802138,
    8=> 0.1155778,
    9=> 0.9585124,
    10=> 0.4069490
);

my @orderedKeys = sort {
    $pvalues{ $b } <=> $pvalues{ $a }
} keys %pvalues;

my $d = my $n = values %pvalues;

$pvalues{ $_ } *= $n / $d-- for @orderedKeys;

$pvalues{ $orderedKeys[ $_ ] } =
    min( @pvalues{ @orderedKeys[ 0 .. $_ ] } )
    for 1 .. $n-1;

$pvalues{ $_ } = min( $pvalues{ $_ }, 1 ) for keys %pvalues;

foreach my $key (keys %pvalues)
{
	print "$key\t$pvalues{$key}\n";
}
