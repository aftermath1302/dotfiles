require "nvchad.mappings"

-- nvchad.mappings style (vim.keymap.set)

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- command mode shortcut
map("n", ";", ":", { desc = "CMD enter command mode" })

-- exit insert mode
map("i", "jk", "<ESC>", opts)

-- Live Server
map("n", "<leader>ls", "<cmd>LiveServerStart<CR>", { desc = "Start Live Server" })
map("n", "<leader>lx", "<cmd>LiveServerStop<CR>", { desc = "Stop Live Server" })

-- Telescope (optional but recommended)
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
vim.keymap.set("n", "<leader>cn", function()
  require("conform").format {
    async = false,
    lsp_fallback = true,
  }
end, { desc = "Format current buffer" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- scratch buffer
local scratch_buf = nil
map("n", "<leader>sc", function()
  if scratch_buf and vim.api.nvim_buf_is_valid(scratch_buf) then
    -- already exists, just open it in a float
    vim.api.nvim_open_win(scratch_buf, true, {
      relative = "editor",
      width = math.floor(vim.o.columns * 0.6),
      height = math.floor(vim.o.lines * 0.4),
      row = math.floor(vim.o.lines * 0.3),
      col = math.floor(vim.o.columns * 0.2),
      style = "minimal",
      border = "rounded",
    })
  else
    -- create new scratch buffer
    scratch_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(scratch_buf, "scratch")
    vim.api.nvim_open_win(scratch_buf, true, {
      relative = "editor",
      width = math.floor(vim.o.columns * 0.6),
      height = math.floor(vim.o.lines * 0.4),
      row = math.floor(vim.o.lines * 0.3),
      col = math.floor(vim.o.columns * 0.2),
      style = "minimal",
      border = "rounded",
    })
  end
end, { desc = "Toggle scratch buffer" })

map("n", "<leader>md", function()
  vim.cmd("split | terminal glow " .. vim.fn.expand("%"))
end, { desc = "Markdown viewer" })

local M = {}

M.vimtex = {
  n = {
    ["<leader>ll"] = { "<cmd>VimtexCompile<cr>",    "Compile LaTeX" },
    ["<leader>lv"] = { "<cmd>VimtexView<cr>",       "View PDF" },
    ["<leader>lc"] = { "<cmd>VimtexClean<cr>",      "Clean aux files" },
    ["<leader>le"] = { "<cmd>VimtexErrors<cr>",     "Show errors" },
    ["<leader>lt"] = { "<cmd>VimtexTocToggle<cr>",  "Toggle TOC" },
  }
}

map("n", "<leader>dd", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

return M
