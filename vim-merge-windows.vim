com! -nargs=? M call MergeWindows( <f-args> )
" ":M lrB" hides Merged, diffs Local+Remote (on left),
"   and shows Base w/o diff Base (on right)
function! MergeWindows( ... )
    let l:spec = '' | if a:0 | let l:spec = a:1 | endif
    let l:quiet =  1 < a:0  ?  a:2  :  0
    let l:buf = bufnr('%') " The buffer to leave cursor in when done.
    let l:bufs = { }
    if  ! exists("t:mergeBufNums")  ||  l:spec =~ '\v^[.]([a-zA-Z]{2,})?$'
        " Set which letters to use for each of the current windows.
        " let t:mergeBufNums = [ 1, 2, 3, 4 ]
        " let t:mergeBufLets = "mlbr"
        let t:mergeBufNums = [ ]
        let t:mergeBufLets = ""
        let l:seq = 0
        let l:win = winnr() | windo
        \   if 2 < len(l:spec)
        \|      let l:seq += 1
        \|      let l:l = tolower(l:spec[l:seq])
        \|      if '' == l:l
        \|          echoerr "Too few letters given."
        \|          return 'FewerLetters'
        \|      endif
        \|  else
        \|      let l:f = bufname('%')
        \|      let l:p = match( l:f, '\v[._]([A-Z])[A-Z]*[._]\d+[.]?[^.]*$' )
        \|      if -1 == l:p
        \|          let l:l = 'm'
        \|      else
        \|          let l:l = tolower( l:f[ 1 + l:p ] )
        \|      endif
        \|  endif
        \|  if has_key( l:bufs, l:l )
        \|      let l:bn = bufname( l:bufs[l:l] )
        \|      echoerr "Used same letter (" l:l ") for:" l:bn "and" bufname('%')
        \|      return 'DupLetter'
        \|  endif
        \|  if 2 < len(l:spec)
        \|      if l:l == l:spec[l:seq]
        \|          diffthis
        \|      else
        \|          set nodiff
        \|      endif
        \|  endif
        \|  let l:bn = bufnr('%')
        \|  let t:mergeBufNums += [ l:bn ]
        \|  let t:mergeBufLets .= l:l
        \|  let l:bufs[ l:l ] = l:bn
        \|  let l:bufs[ l:bn ] = l:l
        exec l:win "wincmd w"
    else
        let l:i = 0
        while l:i < len(t:mergeBufNums)
            let l:bufs[ t:mergeBufLets[l:i] ] = t:mergeBufNums[l:i]
            let l:bufs[ t:mergeBufNums[l:i] ] = t:mergeBufLets[l:i]
            let l:i += 1
        endwhile
    endif
    if  '' == l:spec  ||  '.' == l:spec[0]
        let l:spec = ''
        if l:quiet | return '' | endif
        let l:win = winnr() | windo
        \   let l:bn = bufnr('%')
        \|  if has_key( l:bufs, l:bn )
        \|      let l:l = l:bufs[ l:bn ]
        \|      if ! &diff | let l:l = toupper(l:l) | endif
        \|      if l:win == winnr() | let l:l = '('.l:l.')' | endif
        \|      let l:spec .= l:l
        \|  endif
        exec l:win "wincmd w"
        redraws | echo "'Merge' window state:" l:spec
        return ''
    endif
    "
    " Simply adjust the current window:
    if l:spec =~ '^[-+=]$'
        if '-' == l:spec
            set nodiff | hide
        elseif '+' == l:spec
            diffthis
        elseif '=' == l:spec
            set nodiff
        endif
        return MergeWindows( '', l:quiet )
    endif
    "
    " Show / move to a specific window, maybe move it:
    if l:spec =~# '\v^[a-z][0-9]?$'
        let l:l = l:spec[0]
        let l:pos = l:spec[1]
        let l:bn = l:bufs[l:l]
        let l:w = bufwinnr(l:bn)
        if -1 != l:w
            exec l:w "wincmd w"
        else
            wincmd v
            if '5' != l:pos | exec 'wincmd l' | endif
            exec "buf" l:bn
            let l:w = winnr()
        endif
        if l:pos =~ '\v^[05]?$' | return MergeWindows('',l:quiet) | endif
        let l:spec = l:pos
    elseif l:spec =~ '^[1-46-9]$'
        let l:w = winnr()
    endif
    "
    " Adjust listed windows:
    if l:spec =~ '^[-+=]'
        let l:want = 'op' | let l:sub = ''
        for l:c in split( l:spec, '\zs' ) + [ '' ]
            if  '' != l:sub  &&  l:c !~ '[0-9]'
                call MergeWindows( l:sub[0], 1 ) | call MergeWindows( l:op, 1 )
                if  2 == len(l:sub)  &&  '-' != l:op
                    call MergeWindows( l:sub[1], 1 )
                endif
                let l:sub = ''
            endif
            if l:c =~ '[-+=]'
                let l:got = 'op' | let l:next = 'buf'
                let l:op = l:c
            elseif l:c =~ '[a-z]'
                let l:got = 'buf' | let l:next = 'op,buf,pos,end'
                let l:sub = l:c
            elseif l:c =~ '[1-46-9]'
                let l:got = 'pos' | let l:next = 'op,buf,end'
                let l:sub .= l:c
            elseif l:c == ''
                let l:got = 'end' | let l:next = ''
            else
                echoerr "Invalid character (".l:c.") in" l:spec
                return 'InvArg'
            endif
            if l:want !~ l:got
                echoerr "Expected" l:want "got" l:got "(".l:c.") in" l:spec
                return 'InvArg'
            endif
            let l:want = l:next
        endfor
        let l:win = bufwinnr(l:buf)
        if -1 != l:win | exec l:win "wincmd w" | endif
        return MergeWindows( '', l:quiet )
    endif
    "
    " Show specific windows:
    if  l:spec =~ '\v^[a-zA-Z]{2,4}$'  ||  l:spec =~# '^[A-Z]$'
        "
        " Make sure desired windows are showing:
        for l:l in split( l:spec, '\zs' )
            let l:bn = l:bufs[ tolower(l:l) ]
            let l:w = bufwinnr(l:bn)
            if -1 == l:w
                wincmd v
                exec "buf" l:bn
            endif
        endfor
        "
        " Hide undesired windows and en/disable 'diff'
        wincmd t
        while 1
            let l:bn = bufnr('%')
            if ! has_key( l:bufs, l:bn )
                wincmd w
                if 1 == winnr() | break | endif
            else
                let l:l = l:bufs[l:bn]
                if l:spec !~? l:l
                    let l:l = winnr()
                    set nodiff | hide
                    if winnr() < l:l | break | endif
                else
                    if 1 == len(l:spec)     | diffoff
                    elseif l:spec =~# l:l   | diffthis
                    else                    | set nodiff | endif
                    wincmd w
                    if 1 == winnr() | break | endif
                endif
            endif
        endwhile
        if 1 == len(l:spec) | return MergeWindows( '', l:quiet ) | endif
    elseif l:spec !~ '^[1-46-9]$'
        echoerr "Invalid specification (" . l:spec . ")"
        return "InvArg"
    endif
    "
    " Get numbers of windows we control:
    let l:wins = [ ]
    windo
    \   let l:bn = bufnr('%')
    \|  if has_key( l:bufs, l:bn ) | let l:wins += [ winnr() ] | endif
    "
    if l:spec =~ '^[1-46-9]$'
        let l:spec -= 1
        if 4 < l:spec | let l:spec = l:spec - 9 | endif
        let l:n = l:wins[l:spec]
        if ! l:n
            echoerr "Too few windows for position" l:spec
            return "FewWin"
        endif
        exec l:w "wincmd w"
        exec l:n "wincmd x"
        exec l:n "wincmd w"
        redraw
        return MergeWindows( '', l:quiet )
    endif
    "
    " Put windows in proper order:
    for l:l in split( l:spec, '\zs' )
        let l:bn = l:bufs[ tolower(l:l) ]
        let l:w = bufwinnr( l:bn )
        let l:n = remove( l:wins, 0 )
        if l:w != l:n
            exec l:w "wincmd w"
            exec l:n "wincmd x"
        endif
    endfor
    wincmd = " Make all current windows equal width
    let l:win = bufwinnr(l:buf)
    if -1 != l:win | exec l:win "wincmd w" | endif
    redraw
    return MergeWindows( '', l:quiet )
endfunction

" [mlbr][50]?       # Move into a window
" [mlbr][1-46-9]    # Place window in given position
" [MLBR]            # Show only one window and :diffoff
" [-+=]             # Hide, diff, nodiff current window
" ([-+=][mlbr]+)+   # Hide, diff, nodiff listed windows
" [mlbrMLBR]{2,4}   # Position and set all windows (upper case: nodiff)
" .                 # Resets letters for current windows
" .[a-zA-Z]{2,}     # Sets letters for current windows, diffs lowercase
