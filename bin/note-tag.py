#!/usr/bin/python3
# -*- coding:utf-8 -*-

import pathlib
import argparse
import re

home = pathlib.Path.home()
doc_file = f"{home}/doc/note.txt"


def split_text_by_hash_lines(file_path):
    """
    Split a text file into a list of sections, using lines that start with '#' as the delimiters.

    Args:
        file_path (str): Path to the text file to be read.

    Returns:
        list: A list of divided text sections.
    """
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    sections = []
    current_section = []

    for line in lines:
        if line.strip().startswith("# "):
            if current_section:
                sections.append("".join(current_section).strip())
                current_section = []
                current_section.append(line)
        else:
            current_section.append(line)

    if current_section:
        sections.append("".join(current_section).strip())

    return sections


def get_title(text):
    first_line = text.splitlines()[0]
    return first_line


def tag_match(text, tag):
    first_line = text.splitlines()[0]
    pattern = f"# +(\[{tag}\])"
    return re.match(pattern, first_line)


def main():
    parser = argparse.ArgumentParser(description="note management")
    parser.add_argument("tag", type=str, help="Tag to find")
    parser.add_argument("-t", "--title", action="store_true", help="show only title")

    args = parser.parse_args()

    sections = split_text_by_hash_lines(doc_file)
    for i in sections:
        if tag_match(i, args.tag):
            if args.title:
                print(get_title(i))
            else:
                print(i + "\n")


if __name__ == "__main__":
    main()
