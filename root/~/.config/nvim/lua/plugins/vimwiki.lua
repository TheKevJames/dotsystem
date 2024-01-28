-- Use Vim to open external files with the 'vfile:' scheme.  E.g.:
-- 1) [[vfile:~/src/foo/bar.py]]
-- 2) [[vfile:./|Wiki Home]]
vim.cmd [[
    function! VimwikiLinkHandler(link)
        let link = a:link
        if link =~# '^vfile:'
            let link = link[1:]
        else
            return 0
        endif
        let link_infos = vimwiki#base#resolve_link(link)
        if link_infos.filename == ''
            echomsg 'Vimwiki Error: Unable to resolve link!'
            return 0
        else
            exe 'tabnew ' . fnameescape(link_infos.filename)
            return 1
        endif
    endfunction
]]

vim.g.vimwiki_list = {
    {
        path = '~/sync/work/vimwiki',
        syntax = 'markdown',
        ext = '.md',
    },
    {
        path = '~/sync/vimwiki',
        syntax = 'markdown',
        ext = '.md',
    },
}

return {
    'vimwiki/vimwiki',
}
