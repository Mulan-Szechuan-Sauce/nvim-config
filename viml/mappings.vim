nnoremap <Space> <nop>
let g:mapleader = "\<Space>"
let g:maplocalleader = "\\"

" Fast saving
nnoremap <leader>w :<C-u>update<cr>

" Make j and k behave like they should for wrapped lines
nnoremap j gj
nnoremap k gk

" Buffer navigation keybinds
nnoremap <leader>b :b#<cr>
nnoremap <leader>k :bd<cr>

" Don't lose visual selection with < >
xnoremap < <gv
xnoremap > >gv

" Shift + J/K moves selected lines down/up in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Telescope
nnoremap <leader>m <cmd>Telescope buffers<cr>
nnoremap <leader>g <cmd>Telescope live_grep<cr>
nnoremap <leader>p <cmd>Telescope projects<cr>
nnoremap <leader>f <cmd>lua telescope_find_files_dwim()<cr>
nnoremap <leader>r <cmd>Telescope resume<cr>

" Lsp
nnoremap <leader>lx <cmd>lua require('telescope.builtin').lsp_code_actions(require('telescope.themes').get_cursor({}))<cr>
nnoremap <leader>lr <cmd>lua vim.lsp.buf.rename()<cr>
nnoremap <leader>lu <cmd>Telescope lsp_references<cr>
nnoremap <leader>li <cmd>Telescope lsp_implementations<cr>

" Edit relative to current buffer
nnoremap <leader>e :e <C-R>=expand("%:h") . "/" <CR>

" Git good
nnoremap <leader>G <cmd>Neogit<cr>

" Terminal
tnoremap <Esc> <C-\><C-n>
