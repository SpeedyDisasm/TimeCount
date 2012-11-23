my (@a,$n,$m,$w,$s);
$a[$_]++ while <>;
for (@a){
  $n+=$_;
  $m=$_ if $m<$_;
}
for (0..$#a){
  my $l;
  next if !$a[$_];
  $l=' 'x(length($#a)-length)."$_ - $a[$_]";
  $l.=' 'x(2+length($m)-length $a[$_]).sprintf('(%4.1f)',$a[$_]/$n*100) if $a[$_]/$n>=0.0005;
  print $l.$/;
  $w=length $l if $w<length $l;
  $s+=$_*$a[$_];
}
print '-'x$w.$/;
print 'avg: '.sprintf('%.2f',$s/$n).$/;
