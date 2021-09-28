#!/usr/bin/env python3
from math import pi
radius = int(input('Enter pizza diameter in inches: ')) / 2
cost = float(input('Enter pizza cost: '))
area = pi * radius ** 2
cost_per_square_inch = cost / area
print('Area of the pizza:', area, 'in²')
print('Pizza cost per square inch: $' + str(cost_per_square_inch))
