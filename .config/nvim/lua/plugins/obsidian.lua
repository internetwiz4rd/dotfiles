return {
  "epwalsh/obsidian.nvim",
  -- the obsidian vault in this default config  ~/obsidian-vault
  -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
  -- event = { "bufreadpre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
  event = { "BufReadPre  */obsidian-vault/*.md" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["gf"] = {
              function()
                if require("obsidian").util.cursor_on_markdown_link() then
                  return "<Cmd>ObsidianFollowLink<CR>"
                else
                  return "gf"
                end
              end,
              desc = "Obsidian Follow Link",
            },
          },
        },
      },
    },
  },
  opts = {
    dir = vim.env.HOME .. "~/Log4Stell", -- specify the vault location. no need to call 'vim.fn.expand' here
    use_advanced_uri = true,
    finder = "telescope.nvim",

    templates = {
      subdir = "99-Meta/02-Templates",
      date_format = "%YY%mm%dd",
      time_format = "T%HH%MM",
    },

    note_frontmatter_func = function(note)
      -- This is equivalent to the default frontmatter function.
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and require("obsidian").util.table_length(note.metadata) > 0 then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    follow_url_func = vim.ui.open or function(url) require("astrocore").system_open(url) end,
  },
}
