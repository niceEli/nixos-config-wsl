-- minimal nvim config: native vim.pack, a few small plugins, native LSP
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.termguicolors = true
o.signcolumn = "yes"
o.scrolloff = 10
o.sidescrolloff = 10
o.smoothscroll = true
o.splitright = true
o.splitbelow = true
o.undofile = true
o.swapfile = false
o.updatetime = 250
o.cmdheight = 1
o.mouse = "a"
o.incsearch = true
o.hlsearch = true
o.lazyredraw = true
o.completeopt = { "menu", "menuone", "noselect", "fuzzy", "popup" }

-- clipboard provider lookup is slow (worst on WSL) and blocks startup,
-- so set it once the UI is up
-- vim.api.nvim_create_autocmd("UIEnter", {
--   once = true,
--   callback = function() o.clipboard = "unnamedplus" end,
-- })

-- quick open: native :find with fuzzy matching, no finder plugin
o.path:append("**")
o.wildoptions = { "pum", "fuzzy" }
o.wildignore:append({ "*/.git/*", "*/node_modules/*", "*/bin/*", "*/obj/*" })

-- keymaps
local map = vim.keymap.set
map("n", "<leader>fw", "<cmd>w<cr>", { desc = "Write file" })
map("n", "<leader>qq", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>QQ", "<cmd>qa!<cr>", { desc = "Force quit all" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer (oil)" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent dir" })
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "<M-/>", "<cmd>nohlsearch<CR>")
map("i", "<C-Space>", vim.lsp.completion.get, { desc = "Trigger LSP Completion" })

-- skip some builtin plugins we never use
for _, p in ipairs({ "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" }) do
  vim.g["loaded_" .. p] = 1
end

-- plugins (native package manager, needs nvim 0.12+)
vim.pack.add({
  "https://github.com/stevearc/oil.nvim",

  "https://github.com/echasnovski/mini.pick",
  "https://github.com/nvim-mini/mini.icons",

  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",

  "https://github.com/folke/which-key.nvim",

  "https://github.com/navarasu/onedark.nvim",
})

require("mini.pick").setup()
vim.keymap.set("n", "<leader><leader>", function() MiniPick.builtin.files() end, { desc = "Quick open" })

require("render-markdown").setup()

require("oil").setup({
  default_file_explorer = true,
  -- dired-style `ls -l` listing, and no icons so no nerd font needed
  columns = { "permissions", "size", "mtime" },
  constrain_cursor = false, -- cursor can go anywhere, not just on the filename
  view_options = { show_hidden = true },
})

-- which-key (no icons, no nerd font)
local wk = require("which-key")
wk.setup({ icons = { mappings = false } })
wk.add({
  { "<leader>f", group = "file" },
  { "<leader>q", group = "quit" },
  { "<leader>c", group = "code" },
})

-- diagnostics
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded", source = true },
})

-- LSP: native client, nvim-lspconfig only supplies the server definitions.
-- name -> binary. Servers whose binary isn't on PATH are skipped silently,
-- so install them through nix and they just turn on.
local servers = {
  lua_ls = "lua-language-server",
  ts_ls = "typescript-language-server",
  pyright = "pyright-langserver",
  clangd = "clangd",
  csharp_ls = "csharp-ls",
  kotlin_language_server = "kotlin-language-server",
}

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

-- enable after the UI is up: executable() walks all of PATH, and on WSL that
-- includes the slow /mnt/c Windows entries
-- vim.api.nvim_create_autocmd("UIEnter", {
--   once = true,
--   callback = function()
--     for name, bin in pairs(servers) do
--       if vim.fn.executable(bin) == 1 then
--         vim.lsp.enable(name)
--       end
--     end
--   end,
-- })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local function lmap(keys, fn, desc)
      map("n", keys, fn, { buffer = ev.buf, desc = desc })
    end
    lmap("gd", vim.lsp.buf.definition, "Go to definition")
    lmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
    lmap("<leader>rn", vim.lsp.buf.rename, "Rename")
    lmap("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")
    lmap("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
    -- built-in completion popup as you type
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

-- transparent background: strip bg from the main groups, keep their fg.
-- hooked to ColorScheme so it survives switching themes.
local function transparent()
  local groups = {
    "Normal", "NormalNC", "NormalFloat", "FloatBorder", "SignColumn",
    "EndOfBuffer", "LineNr", "CursorLineNr", "FoldColumn", "WinSeparator",
  }
  for _, g in ipairs(groups) do
    local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
    hl.bg, hl.ctermbg = "none", "none"
    vim.api.nvim_set_hl(0, g, hl)
  end
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = transparent })

-- vim.cmd.colorscheme("habamax")

require('onedark').setup {
    style = 'darker'
}
require('onedark').load()
