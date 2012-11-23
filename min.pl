my $n;
while (<>){
  $n=$_ if !$n || $_<$n;
}
print $n.$/;
