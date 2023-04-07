command! -nargs=? SaveSession lua require'jam-sessions'.save_session(<f-args>)
command! -nargs=? LoadSession lua require'jam-sessions'.load_session(<f-args>)
command! -nargs=? DeleteSession lua require'jam-sessions'.delete_session(<f-args>)
