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

The plugin adds the `:JSONLConvert` command:

- In a JSONL buffer, it writes a sibling `.json` file containing a JSON array of
  all records.
- In a `.json` buffer containing an array, it writes a sibling `.jsonl` file
  with one JSON value per line. JSONL output is never reformatted.

The buffer must be saved first. The converted file is opened after it is
written. No formatter runs by default; see [Formatting](#formatting) to opt in.

### Keymaps

There is no default mapping, so nothing is overwritten. Map the command to
whatever fits your setup. With lazy.nvim, add this to the spec above:

```lua
keys = {
	{
		"<leader>jc",
		"<cmd>JSONLConvert<cr>",
		ft = { "jsonl", "json" },
		desc = "Convert between JSONL and JSON",
	},
},
```

Or, without a plugin manager, add a buffer-local mapping in
`after/ftplugin/jsonl.lua` (and in `after/ftplugin/json.lua` for the reverse
direction):

```lua
vim.keymap.set("n", "<leader>jc", "<cmd>JSONLConvert<cr>", {
	buffer = true,
	desc = "Convert between JSONL and JSON",
})
```

### Formatting

Conversion never invokes a formatter, so it behaves the same whether you use
Conform, prettierd, or nothing at all. Opt in with the `json_formatter` option:
it receives the generated JSON as a list of lines and the target path, and
returns the lines to write. Returning `nil` keeps the unformatted output, and a
formatter error is reported without aborting the conversion.

With `prettierd`:

```lua
opts = {
	json_formatter = function(lines, path)
		local prettierd = vim.fn.exepath("prettierd")
		if prettierd == "" then
			return lines
		end
		local stdin = table.concat(lines, "\n")
		local result = vim.system({ prettierd, path }, { stdin = stdin, text = true }):wait()
		if result.code ~= 0 then
			return lines
		end
		return vim.split(vim.trim(result.stdout), "\n", { plain = true })
	end,
}
```

Or with Conform, which also reformats through your project's config:

```lua
opts = {
	json_formatter = function(lines)
		local err, formatted = require("conform").format_lines({ "prettier" }, lines, { bufnr = 0 })
		if err or not formatted then
			return lines
		end
		return formatted
	end,
}
```

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
