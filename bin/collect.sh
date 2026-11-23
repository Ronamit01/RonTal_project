#!/bin/bash

DAY=$(date +%Y-%m-%d)
TIME=$(date +%H%M)
mkdir -p "raw/$DAY"
OUT="raw/$DAY/$TIME.csv"
TMP=$(mktemp)

#this is a function that gives us the stock price for each company in ils from yahoo finance
get_stock() {
    curl -s -A "Mozilla/5.0" "https://query1.finance.yahoo.com/v8/finance/chart/$1" > "$TMP"
    jq -r '.chart.result[0].meta.regularMarketPrice / 100' "$TMP"
}
ELAL_STOCK=$(get_stock ELAL.TA)
ISRAIR_STOCK=$(get_stock ISRG.TA)

# this is a function that gives us the cheapest filght for each route if there is any using ignav
get_fare() {   # $1=carrier code  $2=destination  $3=days ahead
    local date
    date=$(date -d "+$3 days" +%Y-%m-%d)
    curl -s -X POST "https://ignav.com/api/fares/one-way" \
        -H "X-Api-Key: $IGNAV_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"origin\":\"TLV\",\"destination\":\"$2\",\"departure_date\":\"$date\",\"airlines_include\":[\"$1\"],\"max_stops\":0}" \
        > "$TMP"


    jq -r --arg c "$1" --arg d "$3" '
        [.itineraries[]?
         | select(.outbound.segments[0].marketing_carrier_code == $c)
         | .price.amount]
        | min // empty
        | "\($d),\(.)"' "$TMP"
}

echo "airline,destination,days_ahead,price_usd,stock_price_ils" > "$OUT"

# this function adds the rows to the csv and find alternatives in case there is no flights at the exact day(+-1 day from original date)
add_row() {   # $1=carrier code  $2=airline name  $3=destination  $4=days ahead  $5=stock price
    for d in $4 $(($4 - 1)) $(($4 + 1)); do
        result=$(get_fare "$1" "$3" "$d")
        if [ -n "$result" ]; then
            echo "$2,$3,$result,$5" >> "$OUT"
            return
        fi
    done
}

#this part loops over the different time windows and destinations for ELAL
for dest in JFK CDG LHR; do
    for n in 7 30 90; do
        add_row LY ELAL "$dest" "$n" "$ELAL_STOCK"
    done
done

#this does the sae but for ISRAIR
for dest in BUS BUD ATH; do
    for n in 7 30 90; do
        add_row 6H ISRAIR "$dest" "$n" "$ISRAIR_STOCK"
    done
done

#this part removes the tmp files the JSONS are stored in
rm -f "$TMP"
echo "Saved $OUT"
