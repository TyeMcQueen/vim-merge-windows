function! PDiff()
    let opt = ""
    if &diffopt =~ "icase"
        let opt = opt . "-i "
    endif
    if &diffopt =~ "iwhite"
        let opt = opt . "-b -B "
    endif
    silent execute "!pdiff -a " . opt . v:fname_in . " " .
        \ v:fname_new . " > " . v:fname_out
endfunction

set diffexpr=PDiff()
