#!/usr/bin/python3
# -*- coding:utf-8 -*-
import feedparser
import re
from datetime import datetime

rss = "https://www.hanmoto.com/ci/bd/search/sdate/today/edate/today/hdt/%E6%96%B0%E3%81%97%E3%81%84%E6%9C%AC/order/desc/vw/rss20"


class Book:
    def __init__(self, entry):
        self.title = entry.title
        self.published = datetime.strptime(entry.published, "%a, %d %b %Y %H:%M:%S %z")

        self.link = entry.link
        if hasattr(entry, "tags"):
            self.tags = entry.tags
        else:
            self.tags = None

        m = re.search(r"/isbn/(.*)", self.link)
        if m:
            self.isbn = m.group(1)
        else:
            self.isbn = None

        m = re.match(r"^(.*) *- *([^-]+) *\| *([^\|]+)", self.title)
        if m:
            self.title = m.group(1)
            self.author = m.group(2)
            self.publisher = m.group(3)

            self.author = re.sub(r"\([^()]*\)", "", self.author)
        else:
            self.author = None
            self.publisher = None

    def __del__(self):
        pass

    def print(self):
        print(f"書名: {self.title}")
        print(f"著者: {self.author}")
        print(f"出版社: {self.publisher}")

        month = self.published.month
        day = self.published.day
        print(f"公開: {month}/{day}")
        # print(self.link)
        # print(self.tags)
        print(f"ISBN: {self.isbn}")


def main():
    book_list = []

    feed = feedparser.parse(rss)
    for entry in feed.entries:
        book_list.append(Book(entry))

    prev = False
    for book in book_list:
        if prev:
            print("---")
        book.print()
        prev = True


if __name__ == "__main__":
    main()
