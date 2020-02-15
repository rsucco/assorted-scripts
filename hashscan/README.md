This requires the free command-line tool "sendemail" http://caspian.dotconf.net/menu/Software/SendEmail/, as well as an up to date installation of Python 3. It has only been tested on Windows, and also depends on Windows Defender. It could probably be re-worked to run on Linux with PowerShell core and ClamAV with minimal effort. There are very few if any Windows-specific PowerShell commands.

These scripts are meant to help automate the process of physical data transfer between air-gapped systems. You can schedule it to run via Task Scheduler, and not have to wait for hours for your
optical discs to finish burning and being scanned. Instead, you can scan and get a checksum for all the files prior to burning them, then just run the checksum again once they're disc. This will
prove that the files haven't been altered and compromised since they were first scanned, and will remove the time-consuming step of scanning the files once they're already on a disc.
