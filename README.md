Neovim setup for both windows and linux. My primary focus is to have an environment that I can use both at work in Windows and at home in Linux.

Note: This requires version 0.12+ of neovim

# Windows
## Requirements
- git
- nodejs
- vs build tools 

## Setup
Clone this repo to the root of the c drive and symlink it to nvim's expected config location. This makes it easier to maintain
rather than having to go into your user folder all the time.
```shell
mklink /d c:\Users\{Username}\AppData\local\nvim c:\nvim-config
```

Create an alias command to first initialize the visual studio developer console, and then launch nvim 
so that plugins have access to the dev tools. Toss it in the bin directory of nvim so its in your path.

`%*` passes through any arguments given to the command
```shell
setlocal
if not defined DevEnvDir (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64
)
nvim %*
endlocal
```

# Linux
## Requirements
- git
- nodejs

## Setup
Clone this repo to your user directory or wherever you store your source files and symlink it to nvim's expected config location. This makes it easier to maintain rather than having to go into your user folder all the time.
```shell
ln -s ~\.config\nvim ~\nvim-config
```

# Tutorials
- Video Tutorials
  - [Vim as your editor - ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE)
  - [Horizontal Movements - ThePrimeagen](https://www.youtube.com/watch?v=5JGVtttuDQA)
  - [Vertical Movements - ThePrimeagen](https://www.youtube.com/watch?v=KfENDDEpCsI)
  - [Advanced Motions 1 - ThePrimeagen](https://www.youtube.com/watch?v=qZO9A5F6BZs)
  - [Advanced Motions 2 - ThePrimeagen](https://www.youtube.com/watch?v=uL9oOZStezw)
  - [Tips and Tricks - ThePrimeagen](https://www.youtube.com/watch?v=FrMRyXtiJkc)
