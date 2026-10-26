vim.keymap.set("n", "<leader>jc", function()
	require("jsonl.convert").to_jsonl()
end, { buffer = true, desc = "Convert a JSON array to JSONL" })
