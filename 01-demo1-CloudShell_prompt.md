
# How to customize a prompt in Azure Cloud Shell

## Bash

Open bash in Azure Cloud Shell and install a powerline-go:

```bash
go get -u github.com/justjanne/powerline-go
```

Add the following code snippet  to ~/.bashrc using your favorite editor in Cloud Shell:

```bash
# set up a prompt with powerline-go
 GOPATH=$HOME/go
 function _update_ps1() {
    PS1="$($GOPATH/bin/powerline-go -error $? -newline -modules user,nix-shell,venv,ssh,cwd,perms,git,hg,jobs,exit,root,vgo)"
 }
 if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
     PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
 fi
```

- Install some Powerline-compatible font to your machine.
I'm using a new Microsoft monospaced font, Cascadia Code PL.
- Change a font settings in your Edge/Chrome for 'Fixed-width font'.
- Don't forget to change font to Monospace in Azure Cloud Shell's settings.

If you want to see the same kind of customized prompt in Visual Studio Code when you connect to Cloud Shell, change the 'Editor: Font Family' setting.

## PowerShell

To customize a prompt in PowerShell, install `posh-git` and `oh-my-posh` modules and add the following code snippet to your $PROFILE.

```powershell

Import-Module posh-git
Import-Module oh-my-posh
# v2-way
Set-Theme Paradox
$DefaultUser = "mas"


Import-Module posh-git
Import-Module oh-my-posh
# v3-way
Set-PoshPrompt -Theme  ~/.oh-my-posh.omp.json
Import-Module Terminal-Icons
```
