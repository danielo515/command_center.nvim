local Keymap = require("commander.model.Keymap")
local keymap_modes = { "n", "v", "x", "s", "o", "!", "i", "l", "c", "t", }

describe("Keymap:parse()", function()
	it("correct keymap", function()
		local item, keymap, err

		item = { "n", "<leader>j" }
		keymap, err = Keymap:parse(item)
		assert.Nil(err)
		assert.equal("n", keymap.modes[1])
		assert.equal("<leader>j", keymap.lhs)
		assert.equal(0, #keymap.opts)

		item = { { "n", "v", "i" }, "<leader>k" }
		keymap, err = Keymap:parse(item)
		assert.Nil(err)
		assert.equal("n", keymap.modes[1])
		assert.equal("v", keymap.modes[2])
		assert.equal("i", keymap.modes[3])
		assert.equal("<leader>k", keymap.lhs)
		assert.equal(0, #keymap.opts)

		item = { "n", "<leader>h", { noremap = true } }
		keymap, err = Keymap:parse(item)
		assert.Nil(err)
		assert.equal("n", keymap.modes[1])
		assert.equal("<leader>h", keymap.lhs)
		assert.True(keymap.opts.noremap)

		item = { { "n", "v", "i" }, "<leader>l", { noremap = false, buffer = true } }
		keymap, err = Keymap:parse(item)
		assert.Nil(err)
		assert.equal("n", keymap.modes[1])
		assert.equal("v", keymap.modes[2])
		assert.equal("i", keymap.modes[3])
		assert.equal("<leader>l", keymap.lhs)
		assert.False(keymap.opts.noremap)
		assert.True(keymap.opts.buffer)
	end)

	it("keymap with desc", function()
		local item, keymap, err, desc

		item = { { "n" }, "<leader>l", { noremap = false, buffer = true } }
		desc = "[L]ogs"
		keymap, err = Keymap:parse(item, desc)
		assert.Nil(err)
		assert.equal("n", keymap.modes[1])
		assert.equal("<leader>l", keymap.lhs)
		assert.equal("[L]ogs", keymap.opts.desc)
		assert.False(keymap.opts.noremap)
		assert.True(keymap.opts.buffer)
	end)

	it("keymap without mode", function()
		local item = { nil, "<leader>a", nil }
		local keymap, err = Keymap:parse(item)
		assert.Nil(keymap)
		assert.equal('[1]: expected vim-mode(s) (one or a list of ' .. vim.inspect(keymap_modes) .. '), got nil', err)
	end)

	it("keymap without correct mode", function()
		local item = { "a", "<leader>a", nil }
		local keymap, err = Keymap:parse(item)
		assert.Nil(keymap)
		assert.equal('[1]: expected vim-mode(s) (one or a list of ' .. vim.inspect(keymap_modes) .. '), got "a"', err)
	end)

	it("keymap without lhs", function()
		local item = { "n", nil, nil }
		local keymap, err = Keymap:parse(item)
		assert.Nil(keymap)
		assert.equal("[2]: expected string, got nil", err)
	end)
end)

describe("Keymap:str()", function()
	it("keymap with one mode", function()
		local item = { "n", "<leader>l", { noremap = false, buffer = true } }
		local keymap, err = Keymap:parse(item)
		assert.Nil(err)
		assert.equal("n|<leader>l", keymap:str())
	end)

	it("keymap with multiple mode", function()
		local item = { { "n", "v", "i" }, "<leader>l", { noremap = false, buffer = true } }
		local keymap, err = Keymap:parse(item)
		assert.Nil(err)
		assert.equal("n,v,i|<leader>l", keymap:str())
	end)
end)
