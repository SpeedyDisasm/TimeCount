use 5.016;
use warnings;
use diagnostics;
use List::Util qw (max min sum);

$\=$/;

chdir "result";
my @files = glob "*";
my @badResult;
map {
	open my $result, ">", "analysis ".$_  or next;
	open my $source,  "<", $_ or next;
	
	my @times = <$source>;
	my $max_time = max @times;
	print $result "Max time = ".$max_time;
	my $min_time = min @times;
	print $result "Min time = ".$min_time;
	my $avg_time = (sum @times)/scalar @times;
	print $result "Average time = ".$avg_time;
	
} @files;