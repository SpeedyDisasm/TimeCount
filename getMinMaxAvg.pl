use 5.016;
use warnings;
use diagnostics;
use List::Util qw (max min sum);

open my $dirSource, "<", "source.txt" or die "cannot open source.txt";
my @dir = <$dirSource>;
foreach my $name (@dir) {
	chomp;
	opendir my $dir, $name or die "cannot open dir $name :$!";
	my @files = readdir($dir);
	foreach (@files) {
		open my $source, "<", $dir.'\\'.$_ or next;
		open my $result, ">", "min_max_avg_".$_;
		my @times = <$source>;
		my $max_time = max @times;
		print $result "Max time = ".$max_time;
		my $min_time = min @times;
		print $result "Min time = ".$min_time;
		my $avg_time = (sum @times)/scalar @times;
		print $result "Average time = ".$avg_time;
		close $result;
	}
}