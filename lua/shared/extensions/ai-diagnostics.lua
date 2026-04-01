local M = {}

---@return vim.Diagnostic?
function M.get_most_relevant_diagnostic_at_cursor()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local diagnostics = vim.diagnostic.get(0, { lnum = line - 1 })

    ---@type vim.Diagnostic[]
    local matches = {}
    -- Find diagnostics that overlap with the column of our cursor
    for _, d in pairs(diagnostics) do
        if col >= d.col and col < d.end_col then
            table.insert(matches, d)
        end
    end

    if #matches == 0 then return end

    -- Sort to find the most relevant diagnostic if there are multiple
    table.sort(matches, function(a, b) return a.severity < b.severity end)

    return matches[1]
end

---Copies the diagnostic under the cursor to the clipboard.
function M.copy_diagnostic()
    local diagnostic = M.get_most_relevant_diagnostic_at_cursor()
    if not diagnostic then return end

    -- Copy to system clipboard
    vim.fn.setreg('+', diagnostic.message)
end

function M.codecompanion_fix_diagnostic_at_cursor()
    local diagnostic = M.get_most_relevant_diagnostic_at_cursor()
    M.codecompanion_fix_diagnostic(diagnostic)
end

---@param diagnostic vim.Diagnostic?
function M.codecompanion_fix_diagnostic(diagnostic)
    if not diagnostic then return end

    local lnum = diagnostic.lnum + 1
    local end_lnum = diagnostic.end_lnum + 1

    vim.api.nvim_buf_set_mark(0, '<', lnum, diagnostic.col, {})
    vim.api.nvim_buf_set_mark(0, '>', end_lnum, diagnostic.end_col, {})

    require('codecompanion').inline({
        args = 'Fix the following diagnostic: ' .. diagnostic.message,
        range = end_lnum - lnum + 1
    })
end

return M
