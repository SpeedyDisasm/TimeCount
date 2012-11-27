use 5.016;
use warnings;
use diagnostics;

$\ = $/;
my $dirName = pop @ARGV;
opendir  my $dir, $dirName or die "cannot open dir $dirName : $!";
my @files = grep {/^(\d+).*/} readdir($dir);
#say "@files";
map {
	open my $source, "<", "$dirName\\$_" or die "cannot open file $_ : $!";
	open my $result, ">", "h_$_" or die "cannot open file h_.$_ : $!";
	#open my $result, ">", "..\\histogramm\\$dirName\\$_" or die "cannot open dir for result: $!";
	#mkdir "..\\histogramm\\$dirName";
	#open my $result, ">", "..\\histogramm\\$dirName\\$_" or die "cannot open dir for result: $!";
	
	my @times = <$source>;
	my %times;
	map {
		chomp;
		$times{$_}++;
	}@times;
	map {
		print $result "$_ $times{$_}";# unless 0 == $times{$_};
	} keys %times;
	close $source;
	close $result;
} @files;