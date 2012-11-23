my (@a,$n,$s);
$a[$_]++ while <>;
for (0..$#a){
  next if !$a[$_];
  $n+=$a[$_];
  $s+=$_*$a[$_];
}
print sprintf('%.2f',$s/$n)." ($n)$/";
