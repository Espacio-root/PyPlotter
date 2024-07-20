# PyPlotter

PyPlotter is a Neovim plugin designed to streamline Python plotting and code execution directly within the Neovim editor. It offers commands for creating temporary Python buffers, executing code, and saving output plots as PNG files.

## Features

- **Create Temporary Buffer**: Open a new temporary buffer with Python syntax highlighting.
- **Execute Python Code**: Run Python code from the current buffer and save the resulting plot as a PNG file.
- **Automatic Buffer Deletion**: Temporary buffers are automatically deleted when you leave them.
- **Customizable Output Filename**: Option to specify the output filename for generated plots.

## Installation

To install PyPlotter, you can use a plugin manager like `packer.nvim` or install it manually.

### Using `packer.nvim`

Add the following to your `packer.nvim` configuration:

```lua
use { 'espacio-root/pyplotter' }
```

### Using `lazy`

Add the following to your `lazy` configuration:

```lua
{ 'espacio-root/pyplotter' }


## Usage

### Open Temporary Buffer

Open a new temporary buffer with Python syntax highlighting:

```vim
:OpenTempBuffer
```

This command will create a new buffer with Python syntax highlighting and pre-fill it with import matplotlib.pyplot as plt. The buffer will be automatically deleted when you leave it.

### Run Python Code

Run Python Code
Execute the Python code from the current buffer and save the output plot:

```vim
:RunPythonCode [filename.png]
```

filename.png (optional): Provide a custom filename for the output plot. If not specified, a timestamp-based filename will be used.
