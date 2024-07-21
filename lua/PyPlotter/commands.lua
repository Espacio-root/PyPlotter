local api = vim.api
local Job = require("plenary.job")

local M = {}

function M.setup(opts)
  -- Create global variables
  _G.open_temp_buffer_path = nil
  _G.before = ""
  _G.after = "\nplt.savefig(\"/tmp/output.png\")"

  -- Create a command to open a temporary buffer
  api.nvim_create_user_command('OpenTempBuffer', function()
    -- Store the current buffer's file path
    _G.open_temp_buffer_path = vim.fn.expand('%:p:h')

    -- Create a temporary file
    local temp_file = vim.fn.tempname() .. '.py'
    local buf = api.nvim_create_buf(false, false)
    api.nvim_buf_set_name(buf, temp_file)
    api.nvim_buf_set_option(buf, 'bufhidden', 'delete') -- Delete buffer when hidden
    -- Open the buffer in a new split
    api.nvim_command('split')
    api.nvim_set_current_buf(buf)
    -- Set the filetype to 'python' for syntax highlighting
    api.nvim_buf_set_option(buf, 'filetype', 'python')

    -- Insert the initial Python import statement
    api.nvim_buf_set_lines(buf, 0, 0, false, {'import matplotlib.pyplot as plt'})

    -- Set up an autocmd to handle buffer leave
    api.nvim_create_autocmd('BufLeave', {
      buffer = buf,
      callback = function()
        if opts.run_code_on_buf_leave then
          -- Run the Python code in the current buffer
          vim.cmd('RunPythonCode')
        end
        if opts.destroy_on_buf_leave then
          -- Delete the buffer
          api.nvim_buf_delete(buf, { force = true })
        end
        if opts.paste_on_buf_leave then
          -- Execute the paste_image function
          require("img-clip").paste_image({ copy_images=true, prompt_for_file_name=false }, "/tmp/output.png")
        end
      end
    })
  end, {})

  -- Create a command to execute the Python code in the current buffer
  api.nvim_create_user_command('RunPythonCode', function(opts)
    if not _G.open_temp_buffer_path then
      vim.notify('Error: No buffer path stored. Please run :OpenTempBuffer first.', vim.log.levels.ERROR)
      return
    end

    -- Get the current buffer content
    local buf = api.nvim_get_current_buf()
    local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
    local code = table.concat(lines, '\n')

    -- Append plt.savefig("/tmp/output.png") to the code
    code = _G.before .. code .. _G.after

    -- Write the code to a temporary file
    local temp_file = vim.fn.tempname() .. '.py'
    local file, err = io.open(temp_file, 'w')
    if file == nil then
      vim.notify('Error: Failed to open temporary file. ' .. err, vim.log.levels.ERROR)
      return
    end
    file:write(code)
    file:close()

    -- Run the Python code and generate the graph
    Job:new({
      command = "python3",
      args = { temp_file },
      on_exit = function(j, return_val)
        if return_val ~= 0 then
          vim.notify('Error: Failed to execute Python code.', vim.log.levels.ERROR)
        else
          vim.notify('Python code executed. Output saved to /tmp/output.png')
        end
      end,
    }):start()
  end, { nargs = '?' })
end

return M
