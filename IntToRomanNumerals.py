#!/usr/bin/env python3
def convert_to_roman(num, rom_num = ''):
    if num >= 1000:
        return convert_to_roman(num - 1000, rom_num + 'M')
    elif num >= 900:
        return convert_to_roman(num - 900, rom_num + 'CM')
    elif num >= 500:
        return convert_to_roman(num - 500, rom_num + 'D')
    elif num >= 400:
        return convert_to_roman(num - 400, rom_num + 'CD')
    elif num >= 100:
        return convert_to_roman(num - 100, rom_num + 'C')
    elif num >= 90:
        return convert_to_roman(num - 90, rom_num + 'XC')
    elif num >= 50:
        return convert_to_roman(num - 50, rom_num + 'L')
    elif num >= 40:
        return convert_to_roman(num - 40, rom_num + 'XL')
    elif num >= 10:
        return convert_to_roman(num - 10, rom_num + 'X')
    elif num >= 9:
        return convert_to_roman(num - 9, rom_num + 'IX')
    elif num >= 5:
        return convert_to_roman(num - 5, rom_num + 'V')
    elif num >= 4:
        return convert_to_roman(num - 4, rom_num + 'IV')
    elif num >= 1:
        return convert_to_roman(num - 1, rom_num + 'I')
    else:
        return rom_num

print(convert_to_roman(int(input('Enter number to convert to Roman numerals: '))))