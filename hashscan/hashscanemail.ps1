# This script sorts the files for transfer in subfolders that will fit on a disc of the chosen type, then hashes the subfolders before running
# an antivirus scan. The result of the scans and the hashvalues are then emailed to the IT team so that we don't have to scan the files once 
# they're already on a disc, which could be quite tedious.

# Change the $DISCTYPE constant if you run out of or don't want to use Blu-rays. 
# Change this to either CD, DVD, or BD to change the maximum subfolder size.
$DISCTYPE = "BD"

# Transfer base directory. Only change this if you need to change the directory structure on the transfer machine. 

# Get the default maximum size of the subfolders
if ($DISCTYPE -eq "CD") {
    $MAXSUBFOLDERSIZE = 700MB 
} elseif ($DISCTYPE -eq "DVD") {
    $MAXSUBFOLDERSIZE = 4GB
} else {
    $DISCTYPE = "BD"
    $MAXSUBFOLDERSIZE = 22GB
}

# Initialize the string to contain the email text that will be sent
$emailOutput = "Began transfer procedure at $(Get-Date)`r`n`r`n"

# Get the list of all files in the xfer directory. Sort by size for most efficient distribution across discs. 
$files = (Get-ChildItem -Recurse $XFERBASE | Sort-Object -Property Length -Descending)

# Get the list of all folders, as well as the total size of the transfer
$allFolders = @()
$totalSize = 0
foreach ($file in $files) {
    try {
        # If this doesn't throw an exception, the file is actually a file, and we now know its size.
        $fileSize = ($file | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum
        # If this check fails, the file is not going to fit on a disc of the chosen type. The logic for distributing
        # files betwixt the different discs will catch this and move it to an 'orphaned' folder, but for now, just don't
        # add it to the total size. We don't want it messing with our calculations for the number of discs needed. 
        if ($fileSize -lt $MAXSUBFOLDERSIZE) {
            $totalSize += $fileSize
        }
    } catch {
        # This catches an exception whenever the file is actually a folder, which is how we'll create our directory structure.
        # We want the folder name without the full directory structure, as we are simply duplicating the structure in our subfolders.
        $allFolders += (($file | Select-Object -ExpandProperty FullName) -replace [regex]::Escape($XFERBASE),'')
        # Also remove the folder from the files list to prevent it throwing more exceptions down the line.
        $files = @($files | Where-Object {$_ -ne $file})
    }
}

# Get the number of discs needed for transfer. This depends on the constant set earlier for disc type.
$numDiscs = [Math]::Ceiling($totalSize / $MAXSUBFOLDERSIZE)
$emailOutput += "Total size of files for transfer: $([Math]::Ceiling($totalSize / 1MB)) MB`r`n"
$emailOutput += "Total number of ${DISCTYPE}s needed: $numDiscs`r`n`r`n"

# Copy all the files to their appropriate disc folder to prepare them for scanning and hashing, if they fit
$discDirs = @()
for ($i=1; $i -le $numDiscs; $i++) {
    # Make sure each disc is smaller than its maximum capacity
    $headroom = $MAXSUBFOLDERSIZE    
    
    # Create subfolder directory structure
    $subfolderBase = $XFERBASE + $DISCTYPE + [String]$i + "\"
    $discDirs += $subfolderBase
    foreach ($folder in $allFolders) {
        New-Item -Path ($subfolderBase + $folder) -Type Directory -Force | Out-Null
    }
  
    # Fill the folder for this disc with files until it's full, starting from largest to smallest in order to maximize efficiency
    foreach ($file in $files) {
        $fileSize = (($file | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum)
        # Make sure this file will fit on the disc
        if ($fileSize -lt $headroom) {
            # Copy the files into their appropriate subfolders for each disc
            $originalFile = $file | Select-Object -ExpandProperty FullName
            $newFile = $subfolderBase + (($file | Select-Object -ExpandProperty FullName) -replace [regex]::Escape($XFERBASE),'')
            Copy-Item $originalFile -Destination $newFile
            $headroom -= $fileSize
            # Remove the file from the $files list. Anything left after all discs have had their shot will be orphaned.
            $files = @($files | Where-Object { $_ -ne $file})
        }
    }
}

# If there are any files that don't fit on a disc of the chosen type, notify the IT team that they'll have to do those manually.
if ($files.count -gt 0) {
    $emailOutput += "The following files will not fit on a ${DISCTYPE}: $($files | Select-Object -ExpandProperty FullName). They will be moved to C:\xfer\orphaned\.`r`n"
    $orphanedSize = [Math]::Ceiling(($files | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
    $emailOutput += "Total size of ophaned files: ${orphanedSize}MB`r`n"

    # Create directory structure in the orphaned directory
    $subfolderBase = $XFERBASE + "orphaned\"
    foreach ($folder in $allFolders) {
        New-Item -Path ($subfolderBase + $folder) -Type Directory -Force | Out-Null
    }
    $discDirs += $subfolderBase

    # Notify the IT team of which disc type will be required for each file, then copy the leftover files into the orphaned folder
    foreach ($file in $files) {
        $fileSize = ($file | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum
        if ($fileSize -lt 4GB) {
            $emailOutput += "$file will fit on a DVD.`r`n"
        } elseif ($fileSize -lt 22GB) {
            $emailOutput += "$file will fit on a Blu-ray`r`n"
        } else {
            $emailOutput += "$file is too large for a Blu-ray and cannot be transferred in its present state. If this file is an archive, try splitting it into multiple files.`r`n"
        }
        
        # Copy the file to the orphaned directory
        $originalFile = $file | Select-Object -ExpandProperty FullName
        $newFile = $subfolderBase + (($file | Select-Object -ExpandProperty FullName) -replace [regex]::Escape($XFERBASE),'')
        Copy-Item $originalFile -Destination $newFile
    }
} 

# These tasks have to run in a workflow to take advantage of multithreading. The fact that these are all running on separate folders means this should be safe.
# All of the external commands invoked here must be run inside InlineScripts to deal with the eccentricities of PowerShell multithreading.
workflow HashScan ($discDirs) {
    $result = @()
    foreach -Parallel ($dir in $discDirs) {
        # Hash the entire directory. This is a major pain to do in PowerShell, so it calls a short Python script to use the hashlib library instead.
        $hash = InlineScript{C:\Users\ccri\AppData\Local\Programs\Python\Python38-32\python.exe C:\Users\ccri\hash.py $Using:dir}
        $Workflow:result += "Hash for ${dir}: $hash`r`n"

        # Scan the directory with Windows Defender
        $avresult = InlineScript{& "C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 3 -File $Using:dir}
        $Workflow:result += $avresult + "`r`n"
    }
    # Return the results of the scanning and hashing
    $result
}

# Hash and scan the disc directories. This is incredibly time consuming but the multithreading makes it slightly more bearable. The main bottleneck is I/O
$hashScanResults += HashScan($discDirs)

# Sort and organize the results of the multithreading
$hashScanResults = $hashScanResults | Sort-Object
$hashScanResults = @($hashScanResults | Where-Object { $_ -ne "Scan finished."} | Where-Object { $_ -ne "Scan starting..."})
$emailOutput += $hashScanResults

$emailOutput += "`r`n`r`nIf no threats were detected, you may now burn the files to ${discType}s for transfer to the Narnia systems."

# Send the email to the IT team
& "C:\Program Files (x86)\sendemail\sendemail.exe" -f scanner@scan.com -t itteam@scan.com -u "Antivirus Scan Completed" -m "$emailOutput" -s mail.scan.com
