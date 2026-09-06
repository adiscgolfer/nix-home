return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      -- blink.cmp advertises richer completion capabilities than nvim's
      -- built-in defaults; every server picks this up automatically.
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      -- Buffer-local keymaps only make sense once a server has actually
      -- attached, so wire them from the LspAttach autocmd rather than per-server.
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gd', function() Snacks.picker.lsp_definitions() end, opts)
          vim.keymap.set('n', 'gr', function() Snacks.picker.lsp_references() end, opts)
          vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        end,
      })

      -- Nix-installed servers (see nvim.nix home.packages); nvim-lspconfig
      -- ships their default configs, so just naming them here is enough.
      vim.lsp.enable({ 'lua_ls', 'gopls', 'nixd', 'bashls', 'ts_ls', 'pyright' })
    end,
  },
}
