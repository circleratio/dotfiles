import win32com.client
import sys
import argparse
import re
import os
import pathlib

class mail_draft:
    def __init__(self):
        self.mailfrom = ''
        self.mail_to = ''
        self.cc = ''
        self.bcc = ''
        self.subject = ''
        self.body = ''
        self.attachments = []

    def print(self):
        print('From: ' + self.mailfrom)
        print('To: ' + self.mailto)
        print('Cc: ' + self.cc)
        print('Bcc: ' + self.bcc)
        print('Subject: ' + self.subject)
        print('<Body>\n' + self.body)
        for a in self.attachments:
            print(a)

def parse_file(path):
    md = mail_draft()
    
    with open(path, encoding='utf-8') as f:
        lines = f.readlines()

        in_body = False
        for l in lines:
            l = l.rstrip('\n\r')

            if in_body:
                md.body = md.body + l + '\n'
            else:
                if l == '---':
                    in_body = True
                else:
                    m = re.match('[Ff]rom: *(.*)', l)
                    if m:
                        md.mailfrom = m.group(1)
                        
                    m = re.match('[Tt]o: *(.*)', l)
                    if m:
                        md.mailto = m.group(1)
                        
                    m = re.match('[Cc]c: *(.*)', l)
                    if m:
                        md.cc = m.group(1)
                        
                    m = re.match('[Bb]cc: *(.*)', l)
                    if m:
                        md.bcc = m.group(1)
                        
                    m = re.match('[Ss]ubject: *(.*)', l)
                    if m:
                        md.subject = m.group(1)

                    m = re.match('[Aa]ttachment: *(.*)', l)
                    if m:
                        a = m.group(1).strip('\"')
                        p = str(pathlib.Path(a).expanduser())
                        if os.path.isfile(p):
                            md.attachments.append(p)
                        else:
                            print(f'Warning: {p} does not exist.')
                    
    return md

def compose_mail(md, is_sent):
    outlook = win32com.client.Dispatch('outlook.application')
    mapi = outlook.GetNamespace('MAPI')

    mail = outlook.CreateItem(0)

    if md.mailto != '':
        mail.to = md.mailto
        
    if md.cc != '':
        mail.cc = md.cc
        
    if md.bcc != '':
        mail.cc = md.bcc
        
    if md.subject != '':
        mail.subject = md.subject
        
    mail.body = md.body

    for a in md.attachments:
        mail.Attachments.Add(a)

    if is_sent:
        mail.Send()
    else:
        mail.Save()

def main():
    parser = argparse.ArgumentParser(description='Compose a mail on M365 Outlook.')
    
    parser.add_argument('filename', help='a text file for a mail draft.')
    parser.add_argument('-s', '--send', action='store_true')

    args = parser.parse_args()

    md = parse_file(args.filename)
    compose_mail(md, False)

if __name__ == '__main__':
    main()
