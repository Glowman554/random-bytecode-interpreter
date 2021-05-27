mov 127
store some_var

label loop1
load some_var
sub 1
store some_var
out
compare-reverse 33 loop1
call newline
jump more_code

label some_var
nop

label newline
mov 10
out
mov 13
out
return

label exit_code
call newline
exit

label more_code
load some_var
add 5
out
compare 38 exit_code