# qrencode.py
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

import qrcode
import sys
import argparse

split_len = 800
out_file = '/tmp/tmp.png'

parser = argparse.ArgumentParser(
    prog = 'qrencode.py',
    usage = 'qrencode.py [--work-dir=PATH]',
    description = 'Read a text from stdin and generate a QR code.',
    add_help = True,
)

parser.add_argument('-o', '--outfile', help='Output file')

args = parser.parse_args()

if args.outfile:
    out_file = args.outfile

sys.stdin.reconfigure(encoding="utf_8")
sys.stdout.reconfigure(encoding="utf_8")
sys.stderr.reconfigure(encoding="utf_8")

s_input = sys.stdin.read()

if len(s_input) >= split_len:
    print('The string is too long. Aborted.')
    exit(1)

split_text = [s_input[x:x+split_len] for x in range(0, len(s_input), split_len)]

qr_str = split_text[0]
img = qrcode.make(qr_str)
img.save(out_file)
