## :scroll: logstalgia-batch: Table of Contents
- [logstalgia-batch](#logstalgia-batch)
  - [Presentation](#mag-Presentation)
  - [Purpose](#question-Purpose)
  - [Installation](#Installation)
    - [Requirements](#arrows_clockwise-Requirements)
    - [Procedure](#memo-Procedure)
    - [Batch-Configuration](#wrench-Batch-Configuration)
  - [Usage](#question-Usage)
  - [Notes](#Notes)
    - [Todo-List](#clipboard-Todo-List)
- [License (is-GNU-GPL3)](#ribbon-License-is-GNU-GPL3)

# logstalgia-batch
Windows MS-DOS command line GUI batch to access Nginx Apache logs via SSH Putty pipe logstalgia

## :mag: Presentation
[acaudwell/Logstalgia](https://github.com/acaudwell/Logstalgia) is a website traffic visualization that replays or streams web-server access logs as a pong-like battle between the web server and an never ending torrent of requests.

![Logstalgia screenshot](https://i.ytimg.com/vi_webp/HeWfkPeDQbY/sddefault.webp)


## :question: Purpose
Logstalgia command line can be quite daunting, and anyway you end up using always the same parameters in the end. Why not offering a simple GUI with default presets?

Since I'm using it on Windows, I created this simple and crappy GUI that I use paired with Putty sessions to quickly access some predefined remote logs.


## Installation

### :arrows_clockwise: Requirements
AFAIK, vanilla Windows does not offer the SSH tools that allows you to connect remotely without prompt. So, you need Putty + pLink + pAgent, and make sure your remote server private key is loaded in pAgent. I will not explain how to remote access a server via SSH nor how to create an excrypted RSA key, there are zillions of posts available on the subject :)

* [Logstalgia portable](https://github.com/acaudwell/Logstalgia/releases/download/logstalgia-1.0.9/logstalgia-1.0.9.win64.zip)
* [Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) do I need to present Putty?
* [pLink](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) the binary used by this batch
* [pAgent](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) you definitely need that
* a Putty session in your registry, that you configure in the script
* your own remote server private key loaded in pAgent

### :memo: Procedure
0) Make sure your created a Putty session, and loaded your remote RSA key in pAgent
1) unzip / install logstalgia somewhere
2) clone this repo somewhere else, or just download the only 2 files needed
3) customize paths and variables in the batch file as indicated
4) enjoy


### :wrench: Batch Configuration
Below is the list of variables to setup in the batch:

* logstalgiaDir - self explanatory

`set logstalgiaDir=Z:\APPS\logstalgia-1.0.9.win64`

* PUTTYBIN - self explanatory; get it from https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

`set PUTTYBIN=S:\wintools\lan\putty\64\plink.exe`

* PUTTY_SESSION=saved putty session in registry - must be password free: use pAgent with loaded RSA key for that purpose

`set PUTTY_SESSION=puttySessionName`

* setup your remote logs path accordingly; it's nginx by default + custom path; LOGS should respect NCSA extended/combined log format and TZ should be set in system/systemd

`set LOGS=/var/log/nginx/access.log /data/www/html/*.com/logs/access.log`

* it's possible to specify a different TZ from the server; use signed integers: -5, +12, etc

`set TZ=0`

* load_config=path to logstalgia config file.ini: start logstalgia with --save-config CONFIG_FILE to generate one; the default viewport=1280x720

`set load_config=%DIRNAME%profile-default.ini`


## :question: Usage
This "GUI" offers only 2 modes:
* log replay
* log follow

Depending on how far back in time you want the replay to start from, this batch will adjust the replay speed. This is a batch and it's up to you to customize that as well if you wish.

Dates and time are calculated automatically for convenience.
```
Replay? [Y/n] n
TODAY        = [ ] = 2019-03-13
FROM yesterday=[y] = 2019-03-12 18:48
FROM midnight= [m] = 2019-03-13 00:01
FROM 1 hour  = [1] = 2019-03-13 17:48
FROM now     = [0] = 2019-03-13 18:48

Please enter one of the options above OR a DATE+TIME in the exact same format as above:
start from? [1]
SPEED? [1]
```

## Notes
This works for a single Putty profile for the moment. Duplicate the script and change the profile name inside at convenience.

### :clipboard: Todo List
- [x] let the user enter its own *startfrom* date
- [x] adapt animations speeds depending on replay speed
- [x] update default replay speed
- [x] show usual GUI command help on screen
- [ ] see if a multi profile setting in the menu is relevant
- [ ] remove logstalgia settings from the batch or remove ini file, either one
- [ ] add multi load_config.ini files
- [ ] rework the main menu

# :ribbon: License (is GNU GPL3)
This project is distributed under [GNU Affero General Public License, Version 3][AGPLv3].

                    GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

install-rkit-portable  Copyright (C) <2019>  <audioscavenger@it-cooking.com>
This program comes with ABSOLUTELY NO WARRANTY;
This is free software, and you are welcome to redistribute it
under certain conditions; https://www.gnu.org/licenses/gpl-3.0.html

