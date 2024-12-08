#  Project: Spotify
Yuchen Xu, Yudi Wang.

## Description
The holiday season (November to January) is one of the busiest times for airlines, with frequent delays and cancellations. This project uses data from the U.S. Department of Transportation and National Weather Service to identify patterns in holiday travel disruptions and offer practical tips for passengers to minimize delays and cancellations. Additionally, a predictive model will be developed to estimate gate arrival times, helping travelers better plan their holiday journeys.

## Repository Structure

### 1. Code
- **match1.ipynb**:
  - Organizes raw airport and weather station data.
  - Calculates the distance between latitude and longitude coordinates using the Haversine formula to match each airport with its corresponding weather station.
- **match_faileddownload.ipynb**:
  - Finds the second and third closest weather stations for airports where the initial data download failed.
- **airporttimezone.ipynb**:
  - Determines the timezone associated with each airport.
- **timezone_flight2.ipynb**:
  - Organizes raw flight data.
  - Standardizes the four key times in the flight data (CRSDepTime, CRSArrTime, DepTime, ArrTime) to Central Standard Time (CST).

### 2. Data
- **ghcnh-station-list.csv**: Contains raw data on weather station information.
- **flight_holidayseason.zip**:[Link](https://drive.google.com/drive/folders/1v58ex2g1cIhyhanGa5GJoaqEuNIUv4dI?dmr=1&ec=wgc-drive-hero-goto) Contains raw filght data.
- **weather.zip**:[Link](https://drive.google.com/drive/folders/1v58ex2g1cIhyhanGa5GJoaqEuNIUv4dI?dmr=1&ec=wgc-drive-hero-goto) Contains raw weather data.
- **flight_processed.zip**:[Link](https://drive.google.com/drive/folders/1v58ex2g1cIhyhanGa5GJoaqEuNIUv4dI?dmr=1&ec=wgc-drive-hero-goto) Contains flight data with converted time zones.

### 3. Image
- Contains various images and plots generated during the data analysis and modeling stages.

### 4. Summary
- A document summarizing the key steps in data cleaning, model building, and model evaluation from the project.

## Shiny Link
The Shiny app allows users to interactively . You can access the live app here:
- [Shiny App Link](https://mario2747.shinyapps.io/flightpredict/)
