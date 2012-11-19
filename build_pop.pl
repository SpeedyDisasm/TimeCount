use warnings;
use List::Util qw (max min sum);

open my $source, "<source.txt" or die "source.txt not found\n";
open my $result, ">>result.txt" or die "result.txt not found\n";
truncate $result, 0;

$\=$/;
# storage for times
my @times;

my $start = q { .686
		.model	flat,stdcall
		option	casemap:none
		BSIZE equ 15
		COUNT equ 1000000 ;1 000 000

include windows.inc
include user32.inc
includelib user32.lib
include kernel32.inc		
includelib kernel32.lib

		.data
ifmt	db "%0lu", 0
outp	db BSIZE dup(?)
FileNam db '\result.txt', 0
hParametr dd 0h
nemA dd 0h
var dw 0h

		.code
main proc
	push edx
	push eax
	push ebx
	push ecx
	
commands MACRO 
		rept };
my $end = '
			endm
		endm
		
		invoke	GetStdHandle, STD_OUTPUT_HANDLE
		mov esi, eax
	
		lea edi, var
		mov [edi], 1
		mov ecx, 1
		mov esi, 1
		
		rept COUNT
			push eax
		endm
		
		rdtsc
		push eax
		push edx
		
		commands
		rdtsc
		mov ebx, eax
		mov ecx, edx
		pop edx
		pop eax
		sub ebx, eax
		sub ecx, edx
		
		invoke	wsprintf, addr outp, addr ifmt, ebx
		invoke	WriteConsoleA, esi, addr outp, 10, 0, 0
		
		invoke CreateFile, addr FileNam, GENERIC_WRITE, FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
		mov hParametr, eax
		invoke WriteFile, hParametr, addr outp, 10, addr nemA, NULL
		invoke CloseHandle, hParametr
		
	pop edx
	pop eax
	pop ebx
	pop ecx
	
		invoke	ExitProcess, 0

		main endp
	end main';

for (my $i = 0; $i < 100; $i++) {
	while(<$source>) {
		chomp;
		print STDOUT "\nRead from source.txt = ".${_};
		if (length($_) != 0) {
			&asmMaker($_) or die;
			system("ml /nologo /c /coff instr.asm");
			system("link /nologo /subsystem:console instr.obj");
			system("instr.exe>insrt.txt");
			unlink("instr.exe", "instr.obj");
	
			open my $asm_res, "<C:\\result.txt" or die ("C:\\result.txt not found");
			$line = <$asm_res>;
			print $result $line." on operation ".$_." times\n";
			print STDOUT "Result from = ".$line;
			close $asm_res;
	
			#save time
			(@times) = ($line, @times);
		}
	}
	print STDOUT $i;
	seek $source, 0, 0;
}
system ("del C:\\result.txt");

&showTimes();

close $source;
close $result;

sub asmMaker {
	my $instr = pop @_;
	#$instr =~ s/([\w\s]+)(.\<)(\w+)/${3}\n\t\t${1}/g;
	@mass = split /</, $instr;
	$instr = $mass[1]."\n\t\t".$mass[0];
	open my $result, ">", "instr.asm" or return 0;
	select $result;
	print $start.$instr.$end;
	close $result;
	return 1;
}

sub showTimes {
	select $result; 
	# find max
	$max_time = max @times;
	print "Max time = ".$max_time;
	$min_time = min @times;
	print "Min time = ".$min_time;
	$avg_time = (sum @times)/scalar @times;
	print "Average time = ".$avg_time;
		
	undef @times;
}