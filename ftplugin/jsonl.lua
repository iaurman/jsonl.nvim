vim.opt_local.wrap = false
vim.opt_local.formatoptions:remove("t")

vim.keymap.set("n", "<leader>jc", function()
	require("jsonl.convert").to_json()
end, { buffer = true, desc = "Convert JSONL to a JSON array" })
