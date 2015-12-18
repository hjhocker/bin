#!/usr/bin/env python

import requests
import json
from requests.auth import HTTPBasicAuth

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    BLUE = '\033[34m'
    OKGREEN = '\033[92m'
    GREEN = '\033[22m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    RED = '\033[31m'
    CYAN = '\033[36m'
    ENDC = '\033[0m'
    BRED = '\033[41m'
    YELLOW = '\033[33m'

proxies = {}
body = json.dumps({})
header = {}
auth = HTTPBasicAuth('fake@example.com', 'not_a_real_password')
url = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22neworleans%2C%20la%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
response = requests.get(url, headers={}, data=body, proxies=proxies, auth=auth, verify=True, stream=False)

if response.ok:
    response_headers = response.headers
    data = json.loads(response.content)
    atmosphere = data['query']['results']['channel']['atmosphere']
    forecast = data['query']['results']['channel']['item']['forecast'][1]
    print bcolors.OKGREEN + "Today is going to be " + forecast['text'] + bcolors.ENDC
    print bcolors.WARNING + "The high is " + bcolors.RED + forecast['high'] + bcolors.WARNING + " and the low is " + bcolors.OKBLUE + forecast['low'] + bcolors.ENDC

exit
