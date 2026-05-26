return {
  "David-Kunz/gen.nvim",
  opts = {
    model = "qwen2.5-coder:1.5b",
    host = "localhost",
    port = "11434",
    display_mode = "float",
    show_prompt = false,
    show_model = true,
    no_auto_close = false,
  },
  keys = {
    { "<leader>ag", ":Gen<CR>", mode = { "n", "v" }, desc = "Ollama Gen" },
    { "<leader>ac", ":Gen Chat<CR>", mode = { "n", "v" }, desc = "Ollama Chat" },
  },
}
