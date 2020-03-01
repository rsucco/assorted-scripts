# This script iterates through all the files in the directory that is passed to it with its first command line arguement, then generates a hash values for the entire directory.

import sys

def GetHashofDirs(directory):
    import hashlib, os
    SHAhash = hashlib.md5()
    if not os.path.exists (directory):
        # This folder doesn't exist. This should never occur if the PowerShell script does its job right.
        return -1

    try:
        for root, dirs, files in os.walk(directory):
            for names in files:
                filepath = os.path.join(root,names)
                try:
                    # Open the file for reading
                    readingFile = open(filepath, 'rb')
                except:
                    # We can't open the file for some reason. Move to the next one
                    readingFile.close()
                    continue

                while 1:
                    # Read file in chunks to be hashed and added to the total
                    buffer = readingFile.read(4096)
                    if not buffer:
                        # Reached the end of the file
                        break
                    # Add the hash of the buffer to our grand total hash
                    SHAhash.update(hashlib.md5(buffer).hexdigest().encode())
                readingFile.close()

    except:
        # Something unexpected went wrong. Print a stack trace and exit
        import traceback
        traceback.print_exc()
        return -2

    return SHAhash.hexdigest()

# Print this to console output, which the PowerShell script will pick up and use
print (GetHashofDirs(sys.argv[1]))
