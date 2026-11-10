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

-- Language servers, installed by Mason into ~/.local/share/nvim/mason
-- (:Mason to browse/update). Missing ones are installed on startup.
vim.pack.add({ "https://github.com/mason-org/mason.nvim" })
require("mason").setup()
local registry = require("mason-registry")
registry.refresh(function()
  for _, name in ipairs({ "basedpyright", "ruff", "yaml-language-server" }) do
    local pkg = registry.get_package(name)
    if not pkg:is_installed() then
      vim.notify("Mason: installing " .. name)
      pkg:install()
    end
  end
end)

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
vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_markers = { ".git" },
  -- schemastore picks schemas by file name (docker-compose.yml, GitHub workflows, ...)
  settings = { redhat = { telemetry = { enabled = false } } },
})
vim.lsp.enable({ "basedpyright", "ruff", "yamlls" })

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

-- Search directories (needs fd) and open the chosen one in the file explorer (netrw)
vim.keymap.set("n", "<leader>fd", function()
  tb.find_files({
    prompt_title = "Find directory",
    find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
    attach_mappings = function(prompt_bufnr)
      local actions = require("telescope.actions")
      actions.select_default:replace(function()
        local entry = require("telescope.actions.state").get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then vim.cmd.edit(vim.fn.fnameescape(entry.path or entry[1])) end
      end)
      return true
    end,
  })
end, { desc = "Find directory -> explorer" })
vim.keymap.set("n", "<leader>e", "<cmd>Explore<CR>", { desc = "Explorer at current file" })
