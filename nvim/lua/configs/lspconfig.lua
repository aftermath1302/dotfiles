-- Load NvChad defaults
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require("nvchad.configs.lspconfig")

-- Define server configs using the new API
vim.lsp.config("clangd", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
})

vim.lsp.config("pyright", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
})

vim.lsp.config("gopls", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
})

vim.lsp.config("ts_ls", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
})

vim.lsp.config("eslint", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
})

vim.lsp.config("lua_ls", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
})

-- Enable servers
vim.lsp.enable({
  "clangd",
  "pyright",
  "gopls",
  "lua_ls",
  "ts_ls",
  "eslint",
})

