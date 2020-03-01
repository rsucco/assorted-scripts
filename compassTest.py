import sys

bearing1 = float(sys.argv[1]) - 180
bearing2 = float(sys.argv[2]) - 180
while (bearing1 < 0):
    bearing1 += 360
while (bearing1 > 360):
    bearing1 -= 360
while (bearing2 < 0):
    bearing2 += 360
while (bearing2 > 360):
    bearing2 -= 360
avgBearing = ((bearing1 + bearing2) / 2) + 180
while (avgBearing < 0.0):
    avgBearing += 360
while (avgBearing >= 360.0):
    avgBearing -= 360
print(avgBearing)