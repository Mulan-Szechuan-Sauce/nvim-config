vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,

    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
        },

        texthl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
            [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
            [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
        },
    }
});
