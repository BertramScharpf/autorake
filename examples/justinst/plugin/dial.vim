"
"  phone.vim  --  Handle phone numbers
"

" call external program `dial'
func Dial( ...)
  let s="[-+./()0-9 ]*"
  let nr=matchstr( getline("."), "\\<".s."\\%".col(".")."c".s."\\>")
  if nr == ""
    throw "No phone number under cursor."
  endif
  call system( "dial '".nr."'")
  " possible implemetation of `dial':
  "     echo "atdt,,$1;h0" >/dev/ttyS0
endf
command -nargs=0 Dial call Dial()

