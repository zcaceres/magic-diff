# magic-diff

magic-diff is a command-line tool that automates the process of generating meaningful git commit messages based on your staged changes.

## Features

- Automatically generates a git commit message based on staged changes using an LLM of your choice
- Copies the generated message to your clipboard for easy pasting
- Supports multiple clipboard tools (pbcopy, xclip, clip)

## Prerequisites

- Git
- [llm](https://github.com/simonw/llm) - A command-line interface for interacting with large language models

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/magic-diff.git
   cd magic-diff
   ```

2. Move the contents of magic_diff.sh into your PATH (.zprofile, .bashrc etc.)
   ```
   chmod +x magic_diff.sh
   ```

## Setup

1. Install the `llm` tool if you haven't already:
   ```
   brew install llm (or pip install llm)
   ```

2. Set up your OpenAI API key:
   ```
   llm keys set openai
   ```

3. (Recommended) Set a cheap but effective default model:
   ```
   llm models default gpt-4o-mini
   ```

## Usage

1. Stage your changes in git as usual:
   ```
   git add .
   ```

2. Run magic-diff:
   ```
   magic_diff
   ```

3. The script will generate a commit message based on your staged changes and copy it to your clipboard.

4. Paste the generated message into your git commit command or GUI.

## Customization

You can modify the prompt used to generate the commit message by editing the `llm` command in the `magic_diff()` function of the script.

## Troubleshooting

- If you encounter issues with clipboard functionality, ensure you have one of the supported clipboard tools installed (pbcopy, xclip, or clip).
- If the `llm` command is not found, make sure it's installed and in your PATH.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Credits

Thanks Chong-U Lim for inspiration for the environment-neutral copy functionality.
