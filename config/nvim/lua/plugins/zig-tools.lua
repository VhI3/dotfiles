return {
  "NTBBloodbath/zig-tools.nvim",
  -- Load zig-tools.nvim only in Zig buffers
  ft = "zig",
  config = function()
    -- Initialize with default config
    require("zig-tools").setup()
  end,
}
