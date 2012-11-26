use 5.016;
use warnings;
use diagnostics;
use List::Util qw (max min sum);
use File::Copy;

$\=$/;

chdir "result";
my @files = glob "*";
my @badResult;
my $tm = localtime();
map {
	&prepareForHistogram($_);
	#&minMaxAvr($_);
	#my $dir =  'measurements_'.$tm.'\\';
	#move($_, $dir.$_) or print "cannot move the file";
} @files;

sub prepareForHistogram {
	my $file = pop @_;
	open my $result, ">", 'h_'.$file  or next;
	open my $source,  "<", $file or next;
	my $count = <$source>;
	my %times;
	map {
		($times{$_}) ? $times{$_} = 0 : $times{$_}++;
	} <$source>;
	foreach (keys %times) {
		print $result $_.' '.$times{$_};
	}
}

sub minMaxAvr {
		my $file = pop @_;
		open my $result, ">", "analysis ".$file  or next;
		open my $source,  "<", $file or next;
		
		my @times = <$source>;
		my $max_time = max @times;
		print $result "Max time = ".$max_time;
		my $min_time = min @times;
		print $result "Min time = ".$min_time;
		my $avg_time = (sum @times)/scalar @times;
		print $result "Average time = ".$avg_time;
		
		close $result; 
		close $source;
}