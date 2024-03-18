return {
  'jackMort/ChatGPT.nvim',
  event = 'VeryLazy',
  config = function()
    require('chatgpt').setup()
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'folke/trouble.nvim',
    'nvim-telescope/telescope.nvim',
  },
  extra_curl_params = {
    '-H',
    'Origin: https://example.com',
  },
  -- api_key_cmd = 'secret-tool lookup openai neovim',
}
