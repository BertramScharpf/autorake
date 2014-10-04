"
"  yesno.vim --  Toggle yes/no
"

function s:ToggleYesNo()
  let w=expand("<cword>")
  if     w == "yes"     | let w="no"
  elseif w == "no"      | let w="yes"
  elseif w == "YES"     | let w="NO"
  elseif w == "NO"      | let w="YES"
  elseif w == "Yes"     | let w="No"
  elseif w == "No"      | let w="Yes"
  elseif w == "on"      | let w="off"
  elseif w == "off"     | let w="on"
  elseif w == "ON"      | let w="OFF"
  elseif w == "OFF"     | let w="ON"
  elseif w == "auto"    | let w="manual"
  elseif w == "manual"  | let w="auto"
  elseif w == "ja"      | let w="nein"
  elseif w == "nein"    | let w="ja"
  elseif w == "true"    | let w="false"
  elseif w == "false"   | let w="true"
  elseif w == "TRUE"    | let w="FALSE"
  elseif w == "FALSE"   | let w="TRUE"
  elseif w == "True"    | let w="False"
  elseif w == "False"   | let w="True"
  elseif w == "up"      | let w="down"
  elseif w == "down"    | let w="up"
  elseif w == "enable"  | let w="disable"
  elseif w == "disable" | let w="enable"
  elseif w == "left"    | let w="right"
  elseif w == "right"   | let w="left"
  else                  | let w=""
  endif
  if w!=""
    exec "normal! \"_ciw\<C-R>=w\<cr>\<Esc>b"
  endif
endfunc
nnoremap gy  :call <SID>ToggleYesNo()<cr>

