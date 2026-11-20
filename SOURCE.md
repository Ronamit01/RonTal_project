# SOURCE.md - Ticket prices vs. stock price (El Al and Israir)

## 1. Data sources

| | Ticket prices | Stock prices |
|---|---|---|
| Name | Ignav Flight Fares API | Yahoo Finance |
| Address | https://ignav.com/api/fares/one-way | https://finance.yahoo.com/quote/ELAL.TA <br> https://finance.yahoo.com/quote/ISRG.TA |
| Access method | REST API, called from Python with the `requests` library | The `yfinance` Python library |
| Data format | JSON | Table, saved as CSV |
| Key / username required? | Yes, a personal API key | No |
| License / terms of use | Commercial API, 1,000 free requests and then $2 per 1,000 | Free, for personal and educational use |
| Sampling frequency | Once a day, Monday to Thursday, after the market closes | Once a day, together with the ticket prices |

## 2. What is collected

### Ticket prices (from Ignav)

We collect one way ticket prices from Tel Aviv on the three busiest routes of each airline:

| Airline | Routes |
|---|---|
| El Al | New York (`JFK`), Paris (`CDG`), London (`LHR`) |
| Israir | Batumi (`BUS`), Budapest (`BUD`), Athens (`ATH`) |

For each route we check flights 7, 30 and 90 days ahead and keep the cheapest flight of that day (if there is no flight on that date, we take the nearest flight one day before or after it). This gives us 18 prices per day (2 airlines x 3 routes x 3 dates).

### Stock prices (from yfinance)

We collect the closing price of each airline's stock on the Tel Aviv Stock Exchange (El Al: `ELAL.TA`, Israir: `ISRG.TA`).

## 3. Schema (`dataset.csv`)

All the samples are combined into one file, `dataset.csv`. Each row is one ticket price, meaning one airline, one destination and one date ahead, in one collection.

| Column | Content | Units / format |
|---|---|---|
| `collected_at` | Date and time of the collection | `YYYY-MM-DD HH:MM`, Israel time |
| `airline` | The airline | `ELAL` / `ISRAIR` |
| `destination` | Destination airport (all flights leave from Tel Aviv) | IATA code: `JFK`, `CDG`, `LHR`, `BUS`, `BUD`, `ATH` |
| `days_ahead` | Number of days between the collection date and the flight. Usually 7, 30 or 90, and one day more or less when we took the nearest flight | Days |
| `price_usd` | Price of the cheapest flight | US dollars |
| `stock_price_ils` | Closing price of the airline's stock | Shekels |

Example:

```
collected_at,airline,destination,days_ahead,price_usd,stock_price_ils
2026-11-18 22:43,ELAL,JFK,7,1092.00,21.22
2026-11-18 22:43,ISRAIR,BUD,90,99.00,1.76
```

The raw files (`raw/YYYY-mm-dd/HHMM.csv`) have the same columns without `collected_at`, because the date and time are already in the folder name and the file name.

## 4. Why these columns

Ignav returns a lot of information that is not relevant for our research, so we only use 4 of its fields: the price, the destination, the airline code and the departure time. The price and the destination are saved as they are. The airline code tells us which airline the flight belongs to, and we use the departure time to calculate how many days ahead the flight is. All the other fields are dropped, because they are either not relevant or they repeat information we already have.

From yfinance we only need the closing price of each stock, so we don't collect anything else.

We also don't save the daily average price. We calculate it later in the analysis from the individual prices.

### Ignav fields we use

| Ignav field | What we do with it |
|---|---|
| `price.amount` | Saved as `price_usd` |
| `destination` | Saved as `destination` |
| `marketing_carrier_code` | Tells us which airline the flight belongs to, saved as `airline` |
| `departure_time_local` | Used to calculate `days_ahead` |

### Ignav fields we drop

| Ignav field | Why we drop it |
|---|---|
| `origin` | Always TLV |
| `price.currency` | Always USD, and the unit is already in the column name |
| `cabin_class` | Always economy |
| `departure_date` | The date we asked for, `days_ahead` already has the real number of days |
| `flight_number` | We look at prices, not at specific flights |
| `departure_airport`, `arrival_airport` | Same for every route |
| `arrival_time_local`, `departure_time_utc`, `arrival_time_utc` | Flight times, not related to the price |
| `departure_timezone`, `arrival_timezone` | Same for every airport |
| `duration_minutes` (flight and segment) | Same for every route |
| `aircraft` | Not related to our research question |
| `carrier`, `operating_carrier_name` | Already covered by `airline` |
| `has_mixed_carriers` | Always false, because we only ask for one airline and direct flights |
| `bags` | Baggage allowance, not related to price changes |
| `price.status` | Technical status of the price |
| `observed_at` | When Ignav got the data, we already have `collected_at` |
| `ignav_id` | Internal ID for booking links |

### yfinance fields we drop

`Open`, `High`, `Low`, `Volume`, `Dividends` and `Stock Splits`. We only use the closing price (`Close`).

## 5. Field translation (source to schema)

| Field in the source | Column in the schema |
|---|---|
| Ignav `price.amount` | `price_usd` |
| Ignav `marketing_carrier_code` (`LY` / `6H`) | `airline` (`ELAL` / `ISRAIR`) |
| Ignav `departure_time_local` (calculated from it) | `days_ahead` |
| yfinance `Close` | `stock_price_ils` |
| Folder name and file name of the raw file | `collected_at` |

## 6. Expected size after one semester

We plan to collect once a day, Monday to Thursday. A semester is about 13 weeks, so we expect around 52 samples.

`raw/` folder: each sample is one small CSV file with 18 rows (2 airlines x 3 destinations x 3 dates). One file is about 0.5 KB, so after 52 samples the whole folder will be about 30 KB.

`dataset.csv`: 52 samples x 18 rows is about 940 rows. Each row is about 43 characters, so the file will be about 40 KB.

Both are very small, so storage is not a problem for this project.

API requests: each sample needs 18 requests to Ignav, plus a few more on days when we need to look for a flight one day before or after. Over the semester this is around 1,000 requests, which is about the size of Ignav's free tier, so in the worst case it will cost a dollar or two.
