#!/usr/bin/env python3
def convert_to_int(rom_num, num = 0):
    if len(rom_num) == 0:
        return num
    else:
        if rom_num[0] == 'M':
            return convert_to_int(rom_num[1:], num + 1000)
        elif rom_num[:2] == 'CM':
            return convert_to_int(rom_num[2:], num + 900)
        elif rom_num[0] == 'D':
            return convert_to_int(rom_num[1:], num + 500)
        elif rom_num[:2] == 'CD':
            return convert_to_int(rom_num[2:], num + 400)
        elif rom_num[0] == 'C':
            return convert_to_int(rom_num[1:], num + 100)
        elif rom_num[:2] == 'XC':
            return convert_to_int(rom_num[2:], num + 90)
        elif rom_num[0] == 'L':
            return convert_to_int(rom_num[1:], num + 50)
        elif rom_num[:2] == 'XL':
            return convert_to_int(rom_num[2:], num + 40)
        elif rom_num[0] == 'X':
            return convert_to_int(rom_num[1:], num + 10)
        elif rom_num[:2] == 'IX':
            return convert_to_int(rom_num[2:], num + 9)
        elif rom_num[0] == 'V':
            return convert_to_int(rom_num[1:], num + 5)
        elif rom_num[:2] == 'IV':
            return convert_to_int(rom_num[2:], num + 4)
        elif rom_num[0] == 'I':
            return convert_to_int(rom_num[1:], num + 1)

print(convert_to_int(input('Enter Roman numerals to convert to integer: ')))