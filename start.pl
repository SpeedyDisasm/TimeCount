use 5.016;
use warnings;

#my $dir = pop @ARGV;
open my $source, "<", "source.txt" or die "cannot open source.txt";
while(<$source>) {
	system("test.bat ".$_);
}