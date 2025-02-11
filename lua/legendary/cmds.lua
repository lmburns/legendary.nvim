local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local string = _tl_compat and _tl_compat.string or string; require('legendary.types')

 LegendaryCmds = {}





local M = {}

M.cmds = {
   {
      ':Legendary',
      function(opts)
         if not opts or not opts.args then
            require('legendary.bindings').find()
            return
         end

         if vim.trim((opts.args):lower()) == 'keymaps' then
            require('legendary.bindings').find({ kind = 'legendary.keymap' })
            return
         end

         if vim.trim((opts.args):lower()) == 'commands' then
            require('legendary.bindings').find({ kind = 'legendary.command' })
            return
         end

         if vim.trim((opts.args):lower()) == 'autocmds' then
            require('legendary.bindings').find({ kind = 'legendary.autocmd' })
            return
         end

         require('legendary.bindings').find()
      end,
      description = 'Find keymaps and commands with vim.ui.select()',
      opts = {
         nargs = '*',
         complete = function(arg_lead)
            if arg_lead and vim.trim(arg_lead):sub(1, 1):lower() == 'k' then
               return { 'keymaps' }
            end

            if arg_lead and vim.trim(arg_lead):sub(1, 1):lower() == 'c' then
               return { 'commands' }
            end

            if arg_lead and vim.trim(arg_lead):sub(1, 1):lower() == 'a' then
               return { 'autocmds' }
            end

            return { 'keymaps', 'commands', 'autocmds' }
         end,
      },
   },
   {
      ':LegendaryScratch',
      require('legendary.scratchpad').create_scratchpad_buffer,
      description = 'Create a Lua scratchpad buffer to help develop commands and keymaps',
   },
   {
      ':LegendaryEvalLine',
      function()
         if vim.bo.ft ~= 'lua' then
            vim.api.nvim_err_write("Filetype must be 'lua' or 'LegendaryEditor' to eval lua code")
            return
         end
         require('legendary.scratchpad').lua_eval_current_line()
      end,
      description = 'Eval the current line as Lua',
   },
   {
      ':LegendaryEvalLines',
      function(range)
         if vim.bo.ft ~= 'lua' then
            vim.api.nvim_err_write("Filetype must be 'lua' or 'LegendaryEditor' to eval lua code")
            return
         end
         require('legendary.scratchpad').lua_eval_line_range(range.line1, range.line2)
      end,
      description = 'Eval lines selected in visual mode as Lua',
      opts = {
         range = true,
      },
   },
   {
      ':LegendaryEvalBuf',
      require('legendary.scratchpad').lua_eval_buf,
      description = 'Eval the whole buffer as Lua',
   },
   {
      ':LegendaryApi',
      function()
         vim.cmd(string.format('e %s/%s', vim.g.legendary_root_dir, 'doc/legendary-api.txt'))
         local buf_id = vim.api.nvim_get_current_buf()
         vim.api.nvim_buf_set_option(buf_id, 'filetype', 'help')
         vim.api.nvim_buf_set_option(buf_id, 'buftype', 'help')
         vim.api.nvim_buf_set_name(buf_id, string.format('Legendary API Docs [%s]', buf_id))
         vim.api.nvim_win_set_buf(0, buf_id)
         vim.api.nvim_buf_set_option(buf_id, 'modifiable', false)
      end,
      description = "Show Legendary's full API documentation",
   },
}




M.bind = function()
   vim.tbl_map(function(item)
      require('legendary.utils').set_command(item)
   end, M.cmds)
end



M.register = function()
   local items = vim.deepcopy(M.cmds)
   vim.tbl_map(function(item)
      item[2] = nil
   end, items)
   require('legendary.bindings').bind_commands(items)
end

return M
