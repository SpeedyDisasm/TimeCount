set term png
set output "h_10.png"
set title "qwer"
set auto x
set yrange [0:90]
set style data histogram
plot 'h_10.txt' using 1:xtic(2) 
unset output