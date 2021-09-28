#!/usr/bin/env python3
# Convert Stellaris pops to a cool-sounding population number
pops = int(input('Enter number of pops: '))
population = int(250000 * (pops ** 3.4))
print('Population:', f'{population:,}')
