vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("NERDTree")
      vim.cmd("wincmd p")
    end
  end
})

