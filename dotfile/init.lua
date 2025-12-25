-- set leader to ","
vim.g.mapleader = ","

-- Indenting
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.tabstop = 4
vim.o.softtabstop = 4

-- enable 24bit color support
vim.opt.termguicolors = true

-- line numbers
vim.o.number = true
vim.o.relativenumber = true

-- color column
vim.o.colorcolumn = '120'

-- disable mouse
vim.opt.mouse = ""

-- editor behavior
-- vim.opt.undofile = true  -- persistent undo history
vim.opt.updatetime = 300  -- faster completion (default 4000ms)
vim.opt.signcolumn = "yes"  -- always show sign column (prevent layout shift)

-- mappings
-- 1. map window switching keys
vim.keymap.set('n', '<C-h>', ':wincmd h<cr>', {
    silent = true
})
vim.keymap.set('n', '<C-j>', ':wincmd j<cr>', {
    silent = true
})
vim.keymap.set('n', '<C-k>', ':wincmd k<cr>', {
    silent = true
})
vim.keymap.set('n', '<C-l>', ':wincmd l<cr>', {
    silent = true
})
-- 2. resize windows
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', {
    silent = true
})
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', {
    silent = true
})
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', {
    silent = true
})
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', {
    silent = true
})

----------------
-- Plugins...
----------------

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({{"Failed to clone lazy.nvim:\n", "ErrorMsg"}, {out, "WarningMsg"},
                           {"\nPress any key to exit..."}}, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

---------------
-- lazy.nvim
---------------
require("lazy").setup({
    spec = { -- plugins to load
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000, -- make sure to load this before all the other start plugins
        opts = {},
        config = function()
            -- load the colorscheme here
            vim.cmd([[colorscheme tokyonight]])
        end
    }, -- tokyonight
    -- {
    --     "ellisonleao/gruvbox.nvim",
    --     lazy = false,
    --     priority = 1000, -- make sure to load this before all the other start plugins
    --     config = function()
    --         -- load the colorscheme here
    --         vim.cmd([[colorscheme gruvbox]])
    --     end
    -- }, -- gruvbox theme
    {
        'nvim-lualine/lualine.nvim',
        lazy = false,
        dependencies = {'nvim-tree/nvim-web-devicons'},
        config = function()
            require("lualine").setup({
                options = {
                    theme = 'tokyonight'
                },
                sections = {
                    lualine_c = {{
                        'filename',
                        path = 1
                    }}
                }
            })
        end
    }, -- statusline plugin 
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {"nvim-tree/nvim-web-devicons"},
        init = function()
            -- disable netrw at the very start of your init.lua
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
        config = function()
            require("nvim-tree").setup()
        end
    }, -- nvim-tree
    {
        "lewis6991/gitsigns.nvim",
        lazy = false,
        config = function()
            require('gitsigns').setup()
        end
    }, -- gitsigns
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        cmd = "Telescope",
        keys = {
            "<Leader>f",
            "<Leader>g"
        },
        dependencies = {"nvim-lua/plenary.nvim"},
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-j>"] = "move_selection_next",
                            ["<C-k>"] = "move_selection_previous",
                        }
                    }
                }
            })
        end
    }, -- telescope
    {
        "nvim-treesitter/nvim-treesitter",
        build = ':TSUpdate',
        config = function()
            local configs = require("nvim-treesitter.configs")

            configs.setup({
                ensure_installed = {"bash", "c", "go", "lua", "luadoc", "markdown_inline", "markdown", "python",
                                    "query", "vim", "vimdoc"},
                highlight = {
                    enable = true
                },
                indent = {
                    enable = true
                }
            })
        end
    }, -- nvim-treesitter
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- 定义通用的 base_on_attach 函数
            local base_on_attach = function(client, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

                local bufopts = function(desc)
                    return {
                        desc = desc,
                        noremap = true,
                        silent = true,
                        buffer = bufnr
                    }
                end

                -- LSP keymaps
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts("lsp: go to definition"))
                vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, bufopts("lsp: go to type definition"))
                vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts("lsp: hover"))
                vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts("lsp: rename"))

                -- Telescope-based LSP keymaps (lazy loads telescope)
                vim.keymap.set("n", "gr", function()
                    require("telescope.builtin").lsp_references()
                end, bufopts("lsp: go to references"))

                vim.keymap.set("n", "gi", function()
                    require("telescope.builtin").lsp_implementations()
                end, bufopts("lsp: go to implementations"))
            end

            -- 使用 Neovim 0.11+ 的新 API
            -- pyright 配置
            vim.lsp.config("pyright", {
                on_attach = base_on_attach,
                settings = {
                    pyright = {
                        disableOrganizeImports = true
                    },
                    python = {
                        analysis = {
                            ignore = {'*'}
                        }
                    }
                }
            })

            -- ruff 配置
            vim.lsp.config("ruff", {
                on_attach = function(client, bufnr)
                    -- 调用基础 on_attach 设置 keymaps
                    base_on_attach(client, bufnr)
                    -- ruff 特定配置
                    if client.name == 'ruff' then
                        client.server_capabilities.hoverProvider = false
                    end
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        pattern = "*.py",
                        callback = function()
                            vim.lsp.buf.format({
                                async = false,
                                bufnr = bufnr,
                                id = client.id
                            })
                        end
                    })
                end
            })

            -- gopls 配置
            vim.lsp.config("gopls", {
                on_attach = function(client, bufnr)
                    -- 调用基础 on_attach 设置 keymaps
                    base_on_attach(client, bufnr)
                    -- gopls 特定配置：保存时自动组织 imports
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        pattern = {"*.go", "go.mod", "go.work"}, -- go files
                        callback = function()
                            local params = vim.lsp.util.make_range_params()
                            params.context = {
                                only = {"source.organizeImports"}
                            }
                            local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
                            for cid, res in pairs(result or {}) do
                                for _, r in pairs(res.result or {}) do
                                    if r.edit then
                                        local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                                        vim.lsp.util.apply_workspace_edit(r.edit, enc)
                                    end
                                end
                            end
                            vim.lsp.buf.format({
                                async = false
                            })
                        end
                    })
                end,
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true
                        },
                        staticcheck = true,
                        gofumpt = true
                    }
                }
            })

            -- rust_analyzer 配置
            vim.lsp.config("rust_analyzer", {
                on_attach = function(client, bufnr)
                    -- 调用基础 on_attach 设置 keymaps
                    base_on_attach(client, bufnr)
                    -- rust_analyzer 特定配置：启用 inlay hints
                    vim.lsp.inlay_hint.enable(true, {
                        bufnr = bufnr
                    })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        pattern = "*.rs",
                        callback = function()
                            vim.lsp.buf.format({
                                async = false,
                                bufnr = bufnr,
                                id = client.id
                            })
                        end
                    })
                end
            })

            -- 延迟启用 LSP 服务器，确保在文件打开时才启动
            vim.api.nvim_create_autocmd("FileType", {
                pattern = {"python", "go", "rust"},
                callback = function()
                    local ft = vim.bo.filetype
                    if ft == "python" then
                        vim.lsp.enable("pyright", "ruff")
                    elseif ft == "go" then
                        vim.lsp.enable("gopls")
                    elseif ft == "rust" then
                        vim.lsp.enable("rust_analyzer")
                    end
                end
            })
        end
    }, -- nvim-lspconfig
    {
        "hrsh7th/nvim-cmp",
        dependencies = {"hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline"},
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert({
                    -- Use <C-b/f> to scroll the docs
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    -- Use <C-k/j> to switch in items
                    ['<C-k>'] = cmp.mapping.select_prev_item(),
                    ['<C-j>'] = cmp.mapping.select_next_item(),
                    -- Use <CR>(Enter) to confirm selection
                    ['<CR>'] = cmp.mapping.confirm({
                        select = true
                    })
                }),

                -- Set source precedence
                sources = cmp.config.sources({{
                    name = 'nvim_lsp'
                }, -- For nvim-lsp
                {
                    name = 'buffer'
                } -- For buffer word completion
                })
            })

            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline({'/', '?'}, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {{
                    name = 'buffer'
                }}
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({{
                    name = 'path'
                }, {
                    name = 'cmdline'
                }}),
                matching = {
                    disallow_symbol_nonprefix_matching = false
                }
            })
        end
    } -- nvim-cmp
    -- {
    --     "vhyrro/luarocks.nvim",
    --     opts = {
    --         rocks = {"mimetypes", "xml2lua"} -- Specify LuaRocks packages to install
    --     }
    -- }, -- luarocks
    -- {
    --     "rest-nvim/rest.nvim",
    --     dependencies = {"vhyrro/luarocks.nvim"}
    -- } -- rest-nvim
    },
    install = {
        colorscheme = {"tokyonight"}
    },
    checker = {
        enabled = false
    }
})

--------------
-- nvim-tree
--------------
vim.keymap.set("n", "<Leader>nn", ":NvimTreeToggle<CR>", {
    desc = "nvim-tree: toggle",
    noremap = true,
    silent = true,
    nowait = true
})
vim.keymap.set("n", "<Leader>nf", ":NvimTreeFindFile<CR>", {
    desc = "nvim-tree: find current file",
    noremap = true,
    silent = true,
    nowait = true
})
-- a/d/r/c/p: create/delete/rename/copy/paste a node
-- <C-x>/<C-v>: horizontal split/vertical split

--------------
-- telescope
--------------
vim.keymap.set("n", "<Leader>f", ":Telescope find_files<CR>", {
    desc = "find files"
})
vim.keymap.set("n", "<Leader>g", ":Telescope live_grep<CR>", {
    desc = "live grep"
})
