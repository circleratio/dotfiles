#!/usr/bin/python3
# -*- coding:utf-8 -*-
import requests
import json
from bs4 import BeautifulSoup
from os.path import expanduser

base_url = "https://transit.yahoo.co.jp/diainfo/{}"


def render_info(line_name, code, description):
    url = base_url.format(code)
    return f"{line_name}: {description}, {url}"


def parse_info(code):
    url = base_url.format(code)
    res = requests.get(url)
    soup = BeautifulSoup(res.text, "html.parser")
    status = True

    dt = soup.select("div.elmServiceStatus dl dt")[0].get_text()
    dd = soup.select("div.elmServiceStatus dl dd")[0].get_text()
    if dt == "平常運転":
        dt = "〇"
        dd = ""
    else:
        dt = "×"
        dd = f" ({dd})"
        status = False

    description = f"{dt}{dd}"
    return [status, description]


def main():
    result_ok = []
    result_failure = []
    exit_status = 0
    home = expanduser("~")

    with open(f"{home}/.settings.json") as f:
        d = json.load(f)

    lines = d["train.py"]

    for line in lines:
        s, d = parse_info(line[1])
        if s:
            result_ok.append(line[0])
        else:
            result_failure.append(render_info(line[0], line[1], d))
            exit_status = 1

    if exit_status == 1:
        print("# 正常運行でない区間があります")
        print("\n".join(result_failure))

    print("# 正常運行")
    print("\n".join(result_ok))

    exit(exit_status)


if __name__ == "__main__":
    main()
