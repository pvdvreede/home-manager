return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Add nixls to the list of servers managed by lspconfig
      servers = {
        nil_ls = {}, -- Use default configuration from lspconfig
        -- If you need custom settings later, add them here:
        -- nixls = {
        --   settings = {
        --     nix = {
        --       -- example setting:
        --       -- max_memory = 4096,
        --     }
        --   }
        -- }
      },
      -- Optionally, add setup function for more control if needed,
      -- but relying on mason-lspconfig's defaults is usually sufficient.
      -- setup = {
      --   nixls = function()
      --     -- If you needed very custom setup *before* lspconfig.nixls.setup{}
      --     -- return false -- Prevent mason-lspconfig default setup for nixls
      --   end,
      -- }
    },
  },
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre',     -- Run formatters before saving
    cmd = { "ConformFormat" }, -- Provide the ConformFormat command
    opts = {
      -- Define formatters for specific filetypes
      formatters_by_ft = {
        nix = { "alejandra" }, -- Use nixpkgs-fmt for nix files
        -- Or use alejandra:
        -- nix = { "alejandra" },
        -- Or use nixfmt:
        -- nix = { "nixfmt" },

        -- Add other filetypes and formatters here
        -- python = { "isort", "black" },
        -- javascript = { "prettier" },
      },

      -- Optional: Configure format on save
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true, -- Try LSP formatting if conform fails or isn't configured
      },

      -- Optional: If you need custom arguments for a formatter
      -- formatters = {
      --   nixpkgs_fmt = {
      --     prepend_args = { "--some-flag" },
      --   },
      -- },
    },
  },
}
