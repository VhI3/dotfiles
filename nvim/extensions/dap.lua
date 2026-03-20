return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- UI for debugging
			"mfussenegger/nvim-dap-python", -- Python debugging
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Load DAP UI
			dapui.setup()

			-- Automatically open/close UI when debugging
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Python Debugger Setup
			require("dap-python").setup("python") -- Adjust if using virtualenv

			-- Keybindings for DAP
			vim.api.nvim_set_keymap(
				"n",
				"<leader>dc",
				":DapContinue<CR>",
				{ noremap = true, silent = true, desc = "Start/Continue Debugging" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>db",
				":DapToggleBreakpoint<CR>",
				{ noremap = true, silent = true, desc = "Toggle Breakpoint" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>di",
				":DapStepInto<CR>",
				{ noremap = true, silent = true, desc = "Step Into" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>do",
				":DapStepOver<CR>",
				{ noremap = true, silent = true, desc = "Step Over" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>dr",
				":DapRestart<CR>",
				{ noremap = true, silent = true, desc = "Restart Debugging" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>dq",
				":DapTerminate<CR>",
				{ noremap = true, silent = true, desc = "Stop Debugging" }
			)
		end,
	},
}
