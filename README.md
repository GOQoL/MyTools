# MyTools

This is bash shell script to automate and batch install a custom list of macOS/Ubuntu terminal packages or GUI applications using the Homebrew (https://brew.sh) package manager.

## Requirements

### Macos
Homebrew does require the Xcode commandline tools. Use the command from a terminal window to install.
```bash
xcode-select --install
```

### Ubuntu
To install build tools, paste at a terminal prompt:
```bash
sudo apt install zsh build-essential procps curl file git
```

## Usage 

### From script installs
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/GOQoL/MyTools/main/auto.sh)"
```

### To customize

1. Download script.
```bash
curl -fsSLO https://raw.githubusercontent.com/GOQoL/MyTools/main/auto.sh
```

1. Edit `auto.sh` with a text editor and modify the `term_list` and `cask_list` variables under the `main()` function with the applications or packages you want to install. Comment out any lists if they not required or leave blank.

2. Run the script
```bash
chmod +x auto.sh && ./auto.sh
```
