#!/usr/bin/python

import glob
import re

def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(text):
    return [ atoi(c) for c in re.split(r'(\d+)', text) ]

header1 = '''<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <link rel="icon" type="image/png" sizes="16x16"  href="/favicons/favicon.ico">
</head>
<style>
  .container ul {
    display: grid;
    grid-template-columns: repeat('''

header2 = ''', 100%);
    scroll-snap-type: x mandatory;
    overflow-x: auto;
}

.container ul li {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    list-style: none;
    scroll-snap-align: start;
}
</style>
<body>
  <div class="container">
    <ul>'''

footer = '''    </ul>
  </div>
</body>
</html>
'''

files = glob.glob('*.jpg')
files = sorted(files)
files = sorted(files, key=natural_keys)

print(header1 + str(len(files)) + header2)
for f in files:
    print('        <li><a href="{}"><img src="{}" width="100%"></a></li>'.format(f, f))
print(footer)
