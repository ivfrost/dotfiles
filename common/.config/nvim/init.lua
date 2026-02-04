require("core.keymaps")
require("core.clipboard")
require("core.plugins")

vim.schedule(function()
    local plugin_dir = vim.fn.stdpath('config') .. '/lua/core/plugin_config/'
    for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
        if file:match('%.lua$') then
            require('core.plugin_config.' .. file:gsub('%.lua$', ''))
        end
    end
end)

