return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = {
        before_init = function(_, config)
          local venv = vim.fn.finddir(".venv", vim.fn.getcwd() .. ";")
          if venv ~= "" then
            config.settings.python.pythonPath = venv .. "/bin/python"
          end
        end,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      },
    },
  },
}

