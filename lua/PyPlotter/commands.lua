local api = vim.api

-- Create a global variable to store the buffer path
_G.open_temp_buffer_path = nil
_G.before = ""
_G.after = "\nplt.savefig(\"output.png\")"

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
  
  -- Set up an autocmd to delete the buffer when it's left
  api.nvim_create_autocmd('BufLeave', {
    buffer = buf,
    callback = function()
      api.nvim_buf_delete(buf, { force = true })
    end
  })
end, {})

-- Create a command to execute the Python code in the current buffer
api.nvim_create_user_command('RunPythonCode', function(opts)
  if not _G.open_temp_buffer_path then
    vim.notify('Error: No buffer path stored. Please run :OpenTempBuffer first.', vim.log.levels.ERROR)
    return
  end

  -- Get the stored buffer path
  local parent_dir = _G.open_temp_buffer_path
  local assets_dir = parent_dir .. '/assets'

  -- Get the current buffer content
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local code = table.concat(lines, '\n')

  -- Append plt.savefig("output.png") to the code
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

  -- Ensure the assets directory exists
  if vim.fn.isdirectory(assets_dir) then
    vim.fn.mkdir(assets_dir, 'p')
  end

  -- Generate the output file path
  local image_name = opts.args ~= '' and opts.args or os.date('%Y%m%d_%H%M%S') .. '.png'
  local output_file = assets_dir .. '/' .. image_name

  -- Run the Python code and generate the graph
  local command = string.format('python3 %s && mv output.png %s', temp_file, output_file)
  local success = os.execute(command)
  if not success then
    vim.notify('Error: Failed to execute Python code.', vim.log.levels.ERROR)
    return
  end

  -- Notify the user
  vim.notify('Python code executed. Output saved to ' .. output_file)
end, { nargs = '?' })
