print 'hello from bdierce'
--require 'bdpierce.chatgpt'
require 'bdpierce.luasnip'
require 'bdpierce.remap'
--require 'bdpierce.colors'
vim.cmd 'source ~/.vim/sort23.vim'
-- vim.cmd("source ~/.config/nvim/lua/bdpierce/sort23.vim")
vim.g.mapleader = ','
vim.cmd 'nnoremap <Leader><Leader>S :call Sort_subheads()<return>'

vim.cmd 'au BufNewFile,BufRead *.otl so ~/.vim/vimoutlinerrc'
vim.cmd [[
    let mapleader = ','
    "colo one 
    let g:daylight=0
    if g:daylight
        set background=light
    else
        set background=dark
    endif
    func! Toggle_daylight()
        if g:daylight
            let g:daylight = 0
            set background=dark
        else
            let g:daylight = 1
            set background=light
        endif
    endfunc
    nnoremap <Leader>dl :call Toggle_daylight()<return>
            

    nmap '<Leader>bl' :set background=light
    nmap '<Leader>bd' :set background=dark

]]

--vim.cmd.colorscheme('kanagawa')
--vim.cmd.colorscheme('catppuccin')
vim.cmd.colorscheme 'tokyonight'
