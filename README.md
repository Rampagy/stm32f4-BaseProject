# STM32F4-BaseProject
Starter project for the STM32F407 microcontroller

## Prerequisites

### On Ubuntu (Linux)/macOS
- Tools: `git`, `wget`, and `make`
- Additional Linux requirements: `libgl-dev` and `libxcb-xinerama0`
- Helpful Ubuntu commands:
```bash
sudo apt install git build-essential libgl-dev libxcb-xinerama0 wget git-gui
```
- Helpful macOS tools: 

```bash
brew install stlink
brew install openocd
```

### On Windows
- Chocolately: https://chocolatey.org/install
- Git: https://git-scm.com/download/win. Make sure to click any boxes to add Git to your Environment (aka PATH)

## Install Dev environment and build

### On Ubuntu (Linux)/MacOS
Open up a terminal
1.  `git clone git@github.com:Rampagy/stm32f4-BaseProject.git`
1.  `cd stm32f4-BaseProject`
1.  Continue with [On all platforms](#on-all-platforms)

### On Windows

1.  Open up a Windows Powershell terminal (Resist the urge to run Powershell as administrator, that will break things)
1.  Type `choco install make`
1.  `git clone git@github.com:Rampagy/stm32f4-BaseProject.git`
1.  `cd stm32f4-BaseProject`
1.  Continue with [On all platforms](#on-all-platforms)

### On all platforms

1.  `git checkout origin/master`
1.  `make arm_sdk_install`
1.  `make fw` <-- This will build the firmware and place it into the `stm32f4-BaseProject/builds/` directory

## Important links

https://marketplace.visualstudio.com/items?itemName=marus25.cortex-debug

https://marketplace.visualstudio.com/items?itemName=ms-vscode.makefile-tools

https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack

https://openocd.org/