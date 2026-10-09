vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.exrc = true
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
o.colorcolumn = "80"

o.path:append("**")
o.wildoptions = { "pum", "fuzzy" }
o.wildignore:append({ "*/.git/*", "*/node_modules/*", "*/bin/*", "*/obj/*" })


vim.g.clipboard = {
  name = "WSL Clipboard",

  copy = {
    ["+"] = {
      "clip.exe",
    },
    ["*"] = {
      "clip.exe",
    },
  },

  paste = {
    ["+"] = {
      "powershell.exe",
      "-NoProfile",
      "-Command",
      "[Console]::Out.Write((Get-Clipboard -Raw).Replace(\"`r\", \"\"))",
    },
    ["*"] = {
      "powershell.exe",
      "-NoProfile",
      "-Command",
      "[Console]::Out.Write((Get-Clipboard -Raw).Replace(\"`r\", \"\"))",
    },
  },

  cache_enabled = false,
}

local map = vim.keymap.set
map("n", "<leader>fw", "<cmd>w<cr>", { desc = "Write file" })
map("n", "<leader>qq", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>QQ", "<cmd>qa!<cr>", { desc = "Force quit all" })
map("n", "<M-/>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer (oil)" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent dir" })
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<M-h>", "<cmd>vertical resize -3<cr>", { desc = "Shrink width" })
map("n", "<M-l>", "<cmd>vertical resize +3<cr>", { desc = "Grow width" })
map("n", "<M-j>", "<cmd>resize -2<cr>", { desc = "Shrink height" })
map("n", "<M-k>", "<cmd>resize +2<cr>", { desc = "Grow height" })
map("n", "<M-=>", "<C-w>=", { desc = "Equalize panes" })
map("v", "<", "<gv")
map("v", ">", ">gv")
map("i", "<C-Space>", vim.lsp.completion.get, { desc = "Trigger LSP Completion" })
map("n", "<leader>pu", vim.pack.update, { desc = "Update Packages" })

vim.keymap.set("t", "<C-x>", [[<C-\><C-n>]])

for _, p in ipairs({ "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" }) do
  vim.g["loaded_" .. p] = 1
end

vim.pack.add({
  "https://github.com/stevearc/oil.nvim",

  "https://github.com/echasnovski/mini.pick",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.statusline",
  "https://github.com/j-hui/fidget.nvim",

  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/echasnovski/mini.pairs",

  "https://github.com/folke/which-key.nvim",

  "https://github.com/3rd/image.nvim",

  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/m00qek/baleia.nvim",
  "https://github.com/ej-shafran/compile-mode.nvim"
})

require("mini.icons").setup()

require("mini.pick").setup()

require("mini.pairs").setup()

require("mini.statusline").setup()

require('fidget').setup()

vim.keymap.set("n", "<leader><leader>", function() MiniPick.builtin.files() end, { desc = "Quick open" })

require("render-markdown").setup()

require("oil").setup({
  default_file_explorer = true,
  columns = { "permissions", "size", "mtime" },
  constrain_cursor = false,
  view_options = { show_hidden = true },
})

require("image").setup({
  backend = "sixel",
  integrations = {
    typst = {
      enabled = false,
    },
  }
})

local wk = require("which-key")
wk.setup({ icons = { mappings = false } })
wk.add({
  { "<leader>f", group = "file" },
  { "<leader>q", group = "quit" },
  { "<leader>c", group = "code" },
})

vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    source = "if_many",
  },
  signs = true,
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = " ",
  },
})

vim.g.baleia = require("baleia").setup({})
vim.g.compile_mode = {
  bang_expansion = true,
}
--require("compile-mode")

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "if_many",
      scope = "cursor",
    })
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local buf = ev.buf

    local function lmap(keys, fn, desc, modes)
      map(modes or "n", keys, fn, {
        buffer = buf,
        desc = desc,
      })
    end

    lmap("gd", vim.lsp.buf.definition, "Go to definition")
    lmap("gD", vim.lsp.buf.declaration, "Go to declaration")
    lmap("gr", vim.lsp.buf.references, "Find references")
    lmap("gi", vim.lsp.buf.implementation, "Go to implementation")

    lmap("K", vim.lsp.buf.hover, "Hover documentation")
    lmap("<C-k>", vim.lsp.buf.signature_help, "Signature help", "i")

    lmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
    lmap("<leader>rn", vim.lsp.buf.rename, "Rename")
    lmap("<leader>cf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format")

    lmap("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
    lmap("[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "Previous diagnostic")
    lmap("]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "Next diagnostic")
    lmap("<leader>dl", vim.diagnostic.setloclist, "Diagnostics list")

    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, buf, {
        autotrigger = true,
      })

      lmap("<C-Space>", vim.lsp.completion.get, "Trigger completion", "i")
    end

    if client and client:supports_method("textDocument/inlayHint") then
      lmap("<leader>uh", function()
        vim.lsp.inlay_hint.enable(
          not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }),
          { bufnr = buf }
        )
      end, "Toggle inlay hints")
    end
  end,
})

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

vim.cmd.colorscheme("habamax")
