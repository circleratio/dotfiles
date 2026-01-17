#!/usr/bin/python3
# -*- coding:utf-8 -*-
import requests
from datetime import datetime
import json
from zoneinfo import ZoneInfo

locations = [
    ["東京", "130000", "130010"],  # 東京
    ["豊田", "230000", "230020"],  # 愛知県東部
]

base_url = "https://www.jma.go.jp/bosai/forecast/data/forecast/{}.json"
human_url = "https://www.jma.go.jp/bosai/forecast/#area_type=offices&area_code={}"

def print_day_info(location, day_info, code):
    print(f"# {location}")
    print(human_url.format(code))
    for di in day_info:
        if not di:
            continue

        if "pop0-6" not in di:
            di["pop0-6"] = "-"
        else:
            di["pop0-6"] += "%"
        if "pop6-12" not in di:
            di["pop6-12"] = "-"
        else:
            di["pop6-12"] += "%"
        if "pop12-18" not in di:
            di["pop12-18"] = "-"
        else:
            di["pop12-18"] += "%"
        if "pop18-24" not in di:
            di["pop18-24"] = "-"
        else:
            di["pop18-24"] += "%"

        pop_str = " ({}/{}/{}/{})".format(
            di["pop0-6"], di["pop6-12"], di["pop12-18"], di["pop18-24"]
        )
        print("  {}: {}{}".format(di["date"], di["weather"], pop_str))

def parse_info(code, sub_code):
    url = base_url.format(code)
    week_map = ["月", "火", "水", "木", "金", "土", "日"]
    res = requests.get(url)
    jst = ZoneInfo("Asia/Tokyo")
    day_info = [{} for _ in range(7)]

    values = json.loads(res.text)

    forecast_weather = values[0]["timeSeries"][0]  # 天気
    forecast_rain = values[0]["timeSeries"][1]  # 降水確率

    # forecast_weather_week = values[1]["timeSeries"][0]  # 週間天気予報
    # forecast_temperature_week = values[1]["timeSeries"][1]  # 週間気温予報

    length = len(forecast_weather["timeDefines"])

    for area in forecast_weather["areas"]:
        if area["area"]["code"] != sub_code:
            continue

        for i in range(0, length):
            dt = datetime.fromisoformat(forecast_weather["timeDefines"][i])
            day_info[i]["weather"] = area["weathers"][i]
            day_info[i]["date"] = "{}/{}({})".format(
                dt.month, dt.day, week_map[dt.weekday()]
            )
            # day_info[i]['weatherCode'] = area['weatherCodes'][0]
            # day_info[i]['wind'] = area['winds'][0]
            # day_info[i]['wave'] = area['waves'][0]

    dt_today = datetime.now(jst)
    length = len(forecast_rain["timeDefines"])

    for area in forecast_rain["areas"]:
        if area["area"]["code"] != sub_code:
            continue

        for i in range(0, length):
            dt = datetime.fromisoformat(forecast_rain["timeDefines"][i])
            delta = -(dt_today - dt).days
            pop = area["pops"][i]

            key_str = "pop{}-{}".format(dt.hour, dt.hour + 6)

            day_info[delta][key_str] = pop
            day_info[delta]["date"] = "{}/{}({})".format(
                dt.month, dt.day, week_map[dt.weekday()]
            )

    return day_info


def main():
    # parser = argparse.ArgumentParser(
    #     description="Get weather info from Japan Meteorological Agency."
    # )

    for location in locations:
        d = parse_info(location[1], location[2])
        print_day_info(location[0], d, location[1])


if __name__ == "__main__":
    main()
