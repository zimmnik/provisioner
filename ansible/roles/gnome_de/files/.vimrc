colorscheme pablo
set guifont=Bitstream\ Vera\ Sans\ Mono\ 14

vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <C-r><C-o>+

" CTRL-A is Select all
noremap <C-A> gggH<C-O>G
inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
cnoremap <C-A> <C-C>gggH<C-O>G

" change font size on Ctrl + mouse wheel
if has('gui_running')
    function! s:ChangeFont(delta)
        let l:expr = '\=submatch(1)+' . a:delta
        let l:font = substitute(&guifont, '\v(\d+)', l:expr, '')
        let &guifont = l:font
    endfunction

    nnoremap <silent> <C-ScrollWheelUp> :call <SID>ChangeFont(+1)<cr>
    nnoremap <silent> <C-ScrollWheelDown> :call <SID>ChangeFont(-1)<cr>
endif
