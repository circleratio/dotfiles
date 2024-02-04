#!/usr/bin/env python
# -*- coding: utf-8 -*-

# calc-region.py
#
# Copyright (C) 2023  Teruyoshi FUJIWARA <tf@dsl.gr.jp>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
import re

total = 0
num = 0
comma_separated = False

def get_value(s):
    global comma_separated
    m = re.search(',', s)
    if m:
        s = s.replace(',', '')
        comma_separated = True
    
    v = int(s)
    return v

def val_currency(v):
    if comma_separated == True:
        return '{:,}'.format(v)
    else:
        return v

sys.stdin.reconfigure(encoding="utf_8")
sys.stdout.reconfigure(encoding="utf_8")
sys.stderr.reconfigure(encoding="utf_8")

for line in sys.stdin:
    orig = line
    line = re.sub('\\(.*\\)', '', line)
    m = re.search('{.*}', line)
    if m:
        res = []
        m2 = re.search('total', m.group())
        if m2:
            res.append('total={}'.format(val_currency(total)))

        m2 = re.search('avg', m.group())
        if m2:
            res.append('avg={}'.format(val_currency(total / num)))
            
        print('{' + ', '.join(res) + '}')
        continue
    
    m = re.search('[0-9,]+', line)
    if m:
        v = get_value(m.group())
        num = num + 1
        total = total + v
        
    print(orig, end="")
