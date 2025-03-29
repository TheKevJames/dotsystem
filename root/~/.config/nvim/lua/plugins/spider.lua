return {
  'chrisgrieser/nvim-spider',
  keys = {
    -- TODO: remove these if I don't like the default behaviour update
    { 'w', '<cmd>lua require("spider").motion("w")<CR>', mode = { 'n', 'o', 'x' } },
    { 'e', '<cmd>lua require("spider").motion("e")<CR>', mode = { 'n', 'o', 'x' } },
    { 'b', '<cmd>lua require("spider").motion("b")<CR>', mode = { 'n', 'o', 'x' } },

    -- TODO: remove these if I do
    { ',w', '<cmd>lua require("spider").motion("w")<CR>', mode = { 'n', 'o', 'x' } },
    { ',e', '<cmd>lua require("spider").motion("e")<CR>', mode = { 'n', 'o', 'x' } },
    { ',b', '<cmd>lua require("spider").motion("b")<CR>', mode = { 'n', 'o', 'x' } },
  },
}
