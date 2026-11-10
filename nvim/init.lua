-- Minimal Neovim config
vim.g.mapleader = " "

local o = vim.opt
o.number = true            -- line numbers
o.relativenumber = true
o.mouse = "a"
o.clipboard = "unnamedplus" -- system clipboard (needs xclip/wl-clipboard; over SSH uses OSC52)
o.expandtab = true          -- spaces, 4 wide
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.ignorecase = true         -- case-insensitive search unless capitals used
o.smartcase = true
o.termguicolors = true
o.signcolumn = "yes"
o.scrolloff = 8
o.undofile = true           -- persistent undo
o.splitright = true
o.splitbelow = true

-- clear search highlight with <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- ROS file types
vim.filetype.add({ extension = {
  xacro = "xml", urdf = "xml", launch = "xml", sdf = "xml",
  msg = "conf", srv = "conf", action = "conf",  -- gives # comment highlighting
}})

-- Language servers (installed with `uv tool install basedpyright ruff`)
vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "package.xml", ".git" },
  settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
})
vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".git" },
})
vim.lsp.enable({ "basedpyright", "ruff" })

-- Show errors inline (off by default since 0.11)
vim.diagnostic.config({ virtual_text = true })

-- Built-in autocompletion
-- Format manually with :lua vim.lsp.buf.format()
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

-- Telescope (fuzzy finder). Plugins installed by Neovim's built-in vim.pack;
-- update with :lua vim.pack.update()
vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
})
local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Grep in files" })
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Open buffers" })
vim.keymap.set("n", "<leader>fh", tb.help_tags, { desc = "Help" })
vim.keymap.set("n", "<leader>fr", tb.lsp_references, { desc = "LSP references" })
vim.keymap.set("n", "<leader>fs", tb.lsp_document_symbols, { desc = "Symbols in file" })
