Checking correlation between Elal stock price to flight ticket prices.

We want to check the prices of the following routes: TLV - JFK, TLV - LHR and TLV - CDG.
WE will use Ignav website (a self-serve API that provides live flight prices) to collect the data for ticket prices:
URL: https://ignav.com/
We will gather info on the stock from yahoo! finance:
https://finance.yahoo.com/quote/ELAL.TA
We will collect the data once a day for each of the routes, and show the avarage price of three different time slots (1 week, 1 month, 3 months).
The data collection will take place when the stock market is open for trade between Monday and Friday.
Overall we expect around 390 samples (43 trading days X 3 time slots X 3 destinations).
In order to use the mentioned API we opened accounts in Ignav website, we can use it's free trial up until 1,000 samples, oh yeah.
We expect the dataset's size to be between around 50KB, so no worries about that matter.




Second project option
Comparison between Moovit and Egg applications accuracy.
We use both apps and want to know empirically which one is more accurate.
We'll do it by comparing predicted arrival time in both apps to the acctual arrival time.
We will choose bus line 347 wich gets us to the university as a study case.
In order to get the relevant data we will need to ask access via: 
https://www.gov.il/he/pages/real_time_information_siri
we will compare the real time arrival data to Egg and Moovit
egg(via Egged site):
https://www.egged.co.il/journey-planner
Moovit: https://moovitapp.com
we plan to check every 15 minutes on rush and relevant hours 7:00 to 19:00
we expect around 4000-5000 samples
we relay on public website and free info so we only need to gain access to the server of mot



 
