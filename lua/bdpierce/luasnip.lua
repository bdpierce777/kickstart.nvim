local ls = require 'luasnip'
ls.add_snippets = {
  all = {
    ls.parser.parse_snippet('func()', 'function()'),
    -- snippets go here
  },
}
