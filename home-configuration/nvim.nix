{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Neovim + lazy.nvim (bootstraps itself + plugins from GitHub on first launch)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # We manage init.lua ourselves via home.file below; sideload HM's
    # generated provider/lua-path shim through wrapper args instead of
    # writing it to .config/nvim/init.lua (avoids a target-file conflict).
    sideloadInitLua = true;
  };

  # LSP servers, installed declaratively so nvim-lspconfig finds them on PATH
  # instead of mason fetching its own copies. gopls already comes from dev-tools.nix.
  home.packages = with pkgs; [
    lua-language-server
    nixd
    bash-language-server
    typescript-language-server
    typescript
    pyright
  ];

  home.file.".config/nvim/init.lua".source = ./files/nvim/init.lua;
  home.file.".config/nvim/lua/vim_config.lua".source = ./files/nvim/lua/vim_config.lua;
  home.file.".config/nvim/lua/plugin.lua".source = ./files/nvim/lua/plugin.lua;
  home.file.".config/nvim/lua/keys.lua".source = ./files/nvim/lua/keys.lua;
  home.file.".config/nvim/lua/plugins/navigation.lua".source = ./files/nvim/lua/plugins/navigation.lua;
  home.file.".config/nvim/lua/plugins/git.lua".source = ./files/nvim/lua/plugins/git.lua;
  home.file.".config/nvim/lua/plugins/ui.lua".source = ./files/nvim/lua/plugins/ui.lua;
  home.file.".config/nvim/lua/plugins/colorscheme.lua".source = ./files/nvim/lua/plugins/colorscheme.lua;
  home.file.".config/nvim/lua/plugins/cmp.lua".source = ./files/nvim/lua/plugins/cmp.lua;
  home.file.".config/nvim/lua/plugins/lsp.lua".source = ./files/nvim/lua/plugins/lsp.lua;
}
