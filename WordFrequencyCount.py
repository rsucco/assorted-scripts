#!/usr/bin/python3

def getCounts(filePath, toSort = False):
    try:
        with open(filePath) as f:
            wordList = [word.lower() for line in f for word in line.split()]
    except Exception as e:
        print("Invalid file path")
        print(e)

    counts = {}
    for word in wordList:
        if word not in counts:
            counts[word] = 1
        else:
            counts[word] = counts[word] + 1
    if toSort:
        sortedCounts = [(i, counts[i]) for i in sorted(counts, key=counts.get, reverse=True)]
        return sortedCounts
    else:
        return counts

from sys import argv

# Get user input
try:
    filePath = argv[1]
except:
    # Display usage
    print("Usage: WordFrequencyCount [filename]\n--sorted outputs sorted list. Default is unsorted dictionary.")

# Determine if --sorted flag is set
toSort = False
try:
    sortArg = argv[2].lower()
    if sortArg == "--sort":
        toSort = True
except:
    pass

print(getCounts(filePath, toSort))