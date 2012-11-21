use 5.016;
use warnings;
use List::Util qw (max min sum);
use File::Copy;

#use constant COUNT => 2_000_000;
use constant COUNT => 10;
use constant MIN =>30;

$\=$/;
	
opendir my $sourcedir, "source" or die "cannot open dir source: $!";
foreach my $file (readdir $sourcedir) {
	chdir 'source'; #�������� ����������, ���� �� ������ ��� ���������� ����������
	open my $source, "<", $file or next;
	chdir '..';
	print $file;

	# storage for times
	my @times;

	my $start = " 
			.686
			.MMX
			.XMM
			.model	flat,stdcall
			option	casemap:none
			BSIZE equ 15

	include windows.inc
	include user32.inc
	includelib user32.lib
	include kernel32.inc		
	includelib kernel32.lib

			.data
	ifmt	db \"%0lu\", 0
	outp	db BSIZE dup(?)
	FileNam db 'result.txt', 0
	hParametr dd 0h
	nemA dd 0h
			.data?
		var db BSIZE dup(?)

			.code
	main proc
		push edx
		push eax
		push ebx
		push ecx
		
		
	commands MACRO 
			rept ";
	my $end = '
				endm
			endm
			
			mov ecx, 1
			mov edi, 1
			lea edi, var
			;mov [edi], 1
			
			rdtsc
			push eax
			push edx
			lfence
			commands
			lfence
			rdtsc
			
			mov ebx, eax
			mov ecx, edx
			pop edx
			pop eax
			sub ebx, eax
			sub ecx, edx
			push ecx			
				invoke CreateFile, addr FileNam, GENERIC_WRITE, FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
				mov hParametr, eax
			pop ecx
			cmp ecx, 0
			je equal
			invoke	wsprintf, addr outp, addr ifmt, ecx
			invoke WriteFile, hParametr, addr outp, 16, addr nemA, NULL
equal:
			invoke	wsprintf, addr outp, addr ifmt, ebx
			invoke WriteFile, hParametr, addr outp, 16, addr nemA, NULL
			invoke CloseHandle, hParametr
			
		pop edx
		pop eax
		pop ebx
		pop ecx
		
			invoke	ExitProcess, 0

			main endp
		end main';

	while(<$source>) {
		chomp;
		s'//.*'';
		
		if (length($_) != 0) {
			my $instr = $_;
			&asmMaker($instr) or die "error in asmMaker";
			system("ml /c /coff instr.asm");
			system("link /subsystem:console instr.obj");
			open my $result, ">>", $instr.".txt" or die "cann't create ".$instr.".txt";
			
			for (0..1_000) {
				system("instr.exe");
				open my $asm_res, "<", "result.txt" or die ("result.txt not found");
				my $line = <$asm_res>;
				$line =~ s/(\D+)//;
				#$line -= MIN;
				print $result $line;
				close $asm_res;
		
				#save time
				push @times, $line;
				
			}
			unlink("instr.exe", "instr.obj", "result.txt");
			close $result;
			move($instr.'.txt', 'result\\'.$instr.'.txt') or print "cannot move the file";
			undef @times;
		
		}
	}


	close $source;

	sub asmMaker {
		my $inp = pop @_;
		my @mass = split /</, $inp;
		my $instr = ($mass[1]) ?  $mass[1]."\n\t\t".$mass[0] : COUNT."\n\t\t".$mass[0];
		open my $result, ">", "instr.asm" or return 0;
		print $result $start.$instr.$end;
		close $result;
		return 1;
	}
}