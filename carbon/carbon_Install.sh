#!/bin/bash
carbon_Install=false
echo "Do you want to install carbon? (y/n)"
read -n 1 carbon_Install
echo
echo
if [ $carbon_Install == "y" ] || [ $carbon_Install == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - carbon- - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/vahab/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew install llvm
    export PATH="$(brew --prefix llvm)/bin:${PATH}"
    git clone https://github.com/carbon-language/carbon-lang
    cd carbon-lang
    bazel run //explorer -- ./explorer/testdata/print/format_only.carbon
    # mkdir -p ~/.config/dunst/
    # cp dunstrc ~/.config/dunst/dunstrc
    sudo apt upgrade
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End carbon- - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
