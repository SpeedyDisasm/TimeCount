use 5.016;
use warnings;
use List::Util qw(min);

open my $source, "<", "result.txt";
open my $res, ">", "analysis.txt";

my @times = <$source>;
my $q = min @times;
print $res $q;

close $source;
close $res;