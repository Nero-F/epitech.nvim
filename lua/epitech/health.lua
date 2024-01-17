local M = {}

local required_plugins = {
    telescope = "nvim-telescope/telescope.nvim",
}

local check_for_coding_style_docker_image = function()
    local image_name = "coding-style-checker:latest"
    local image_src = "ghcr.io/epitech/" .. image_name

    vim.health.report_start("Check required_image")

    local id = vim.fn.jobstart("docker image inspect " .. image_src, {
        on_exit = function(_, data, _)
            if data ~= 0 then
                vim.health.report_ok("Docker image " .. image_name .. " is installed.")
            else
                vim.health.report_error("Docker image " .. image_name .. " not installed")
                vim.health.report_warn("Please pull this docker image " .. image_src)
            end
        end
    })
    vim.fn.jobwait({id})
end

M.check = function()
    vim.health.report_start("Check required_plugins")

    for plugin_name, _source in pairs(required_plugins) do
        local has_plug, _ = pcall(require, plugin_name)

        if not has_plug then
            vim.health.report_error(plugin_name .. " not installed, take a look at: https://github.com/" .. source)
        else
            vim.health.report_ok(plugin_name .. " installed.")
        end
    end
    check_for_coding_style_docker_image()
end

return M
