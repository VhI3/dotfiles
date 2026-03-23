-- LaTeX: vimtex + texlab (completion/build) + ltex-ls-plus (grammar, German & English)

return {
  -- ── vimtex ────────────────────────────────────────────────────────────────
  {
    "lervag/vimtex",
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_vimtex_conceal", { clear = true }),
        pattern = { "bib", "tex" },
        callback = function()
          vim.wo.conceallevel = 0
        end,
      })
      vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- avoid conflict with LSP hover
      vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_latexmk = {
        aux_dir = "./aux",
        out_dir = "./out",
      }
    end,
  },

  -- ── LSP servers via nvim-lspconfig ────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {

        -- texlab: completion, build, forward search, symbol navigation
        texlab = {
          settings = {
            texlab = {
              build = {
                executable = "latexmk",
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                onSave = true,
              },
              forwardSearch = {
                executable = "zathura",
                args = { "--synctex-forward", "%l:1:%f", "%p" },
              },
              chktex = {
                onEdit = false,
                onSave = true,
              },
            },
          },
        },

        -- ltex-ls-plus: grammar + spell check via LanguageTool
        -- supports German (de-DE) and English (en-US) simultaneously
        ltex = {
          filetypes = { "tex", "bib", "markdown", "rst", "text" },
          settings = {
            ltex = {
              language = "auto",           -- auto-detects de-DE / en-US per paragraph
              additionalRules = {
                enablePickyRules = true,   -- stricter grammar suggestions
                motherTongue = "de-DE",    -- reduces false positives for native German speaker
              },
              disabledRules = {
                ["en-US"] = { "WHITESPACE_RULE" },
                ["de-DE"] = { "WHITESPACE_RULE" },
              },
              dictionary = {
                ["de-DE"] = {},            -- add personal German words here
                ["en-US"] = {},
              },
              hiddenFalsePositives = {},
              latex = {
                commands = {},
                environments = { "lstlisting", "verbatim", "minted" }, -- skip code blocks
              },
            },
          },
        },
      },
    },
  },
}
