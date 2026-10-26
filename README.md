# jsonl.nvim

JSONL / NDJSON filetype support for Neovim with Tree-sitter injection queries.

## lazy.nvim

```lua
return {
	"kristoferssolo/jsonl.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	init = function()
		vim.filetype.add({
			extension = {
				jsonl = "jsonl",
				jsonlines = "jsonl",
				ndjson = "jsonl",
			},
		})
	end,
	ft = { "jsonl", "json" },
	opts = {},
}
```

`json` is included so the reverse conversion works when opening a JSON file in a
fresh session.

## Tree-sitter parser

Install the parser once:

```
:TSInstall jsonl
```

Or add `"jsonl"` to `ensure_installed` in your `nvim-treesitter` setup.

## Converting between JSONL and JSON

The plugin adds a buffer-local `<leader>jc` mapping and the `:JSONLConvert`
command:

- In a JSONL buffer, it writes a sibling `.json` file containing a JSON array of
  all records. The array is formatted with `prettierd` when available.
- In a `.json` buffer containing an array, it writes a sibling `.jsonl` file
  with one JSON value per line.

The buffer must be saved first. The converted file is opened after it is
written.

## conform.nvim

If you use [Conform](https://github.com/stevearc/conform.nvim)'s `injected` formatter, it may also try to format `jsonl`
buffers through the JSON injection query. You can disable that by skipping the
formatter for JSONL-style filenames:

```lua
require("conform").setup({
	formatters = {
		injected = {
			condition = function(_, ctx)
				return not ctx.filename:match("%.jsonl$")
					and not ctx.filename:match("%.ndjson$")
					and not ctx.filename:match("%.jsonlines$")
			end,
		},
	},
})
```

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.
