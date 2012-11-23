my (@a,$n,$p);
$a[$_]++ while <>;
$n=length $#a;
$p=' 'x$n;
for (0..$#a){
  my $s;
  next if !$a[$_];
  $s=$p.$_;
  print substr($s,-$n)." - $a[$_]$/";
}
