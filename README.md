Libre Flutter Android Widget

This repo is a Flutter app that has a native Android widget to display the percentage time in-range in the last 24 hours. 
It uses the Libre link up api to get the data from the Libre 2 sensor.

It updates every 5 minutes on the widget.

It is not pretty, but it works.

To use this, because enter your username and password (for the libre link up account) in the inputs of the getPercentInRange function. Only do this locally for security reasons.

This uses a dart version of the librelinkup I use [here](https://github.com/smpurkis/libre-api-pg/blob/main/src/LibrelinkClient.py)
