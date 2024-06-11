# Linux Notes.

<!--toc:start-->
- [Linux Notes.](#linux-notes)
  - [The problem with running Chrome, Github-dektop, ...](#the-problem-with-running-chrome-github-dektop)
  - [To preview the markdown for notes taking](#to-preview-the-markdown-for-notes-taking)
<!--toc:end-->

## The problem with running Chrome, Github-dektop, ...

One way is to add a this commend in /etc/environment

sudo vim /etc/environment

add following this:
export LIBVA_DRIVER_NAME=disable

source /etc/environment

## To preview the markdown for notes taking

1. Install the ungoogle-chromium

   make link in ~/.local/

   ln -s -f ~/.opt/chromium/ungoogled-chromium.AppImage ~/.local/bin/ungoogled-chromium

2. Install deno
   ```bash
   curl -fsSL https://deno.land/install.sh | sh 
   ```
   Manually add the directory to your $HOME/.bashrc (or similar)
   
   ```bash
   export DENO_INSTALL="/home/vahab/.deno"
   export PATH="/$DENO_INSTALL/bin:$PATH"
   ```
3. Open neovim and run: 
   ```bash
   Lazy build peek.nvim
   ```

