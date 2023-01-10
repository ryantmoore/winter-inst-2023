import requests
from bs4 import BeautifulSoup as bSoup

out_filename = "results/data/election2020" + ".csv"

# NYTimes webpage for 2020 election
nytimes_url = "https://www.nytimes.com/interactive/2020/11/03/us/elections/results-president.html?action=click&pgtype=Article&state=default&module=styln-elections-2020&region=TOP_BANNER&context=storyline_menu_recirc"
root_page = requests.get(nytimes_url)
root_soup = bSoup(root_page.content, "html.parser", from_encoding='utf8')

# Find the state results section
state_results = root_soup.findAll("ul", {"class": "e-state-list"})
state_list = state_results[0].findAll("li")

# Create and open an output file
out_file = "election-data" + ".csv"
f = open(out_file, "w")
## Write the column names first
f.write("State" + "," + "Candidate" + "," + "Party" + "," + "Votes" + "," + "Percent" + "," + "EC_vote" + "\n")


for i in range(0, len(state_list)):
    # Find state name
    state =  state_list[i].text.strip()
    # Find state url
    state_url = state_list[i].findAll("a")[0]['href']
    print("Parsing:", state)

    # Download state pages
    state_page = requests.get(state_url)
    state_soup = bSoup(state_page.content, "html.parser", from_encoding='utf8')

    # Subset to the table section
    table_all = state_soup.findAll("table", {"class": "e-table e-results-table"})
    table_tr = table_all[0].findAll("tr")

    # Loop through each row of the table
    for j in range(len(table_tr)-2):
        # Find the specific data fields
        cand = table_tr[j].findAll("span", {"class": "e-last-name"})[0].text.strip().replace("*", "")
        votes = table_tr[j].findAll("span", {"class": "e-votes-display"})[0].text.strip().replace(",", "")
        pct = table_tr[j].findAll("span", {"class": "e-percent-val"})[0].text.strip()
        party = table_tr[j].findAll("span", {"class": "e-party-display"})[0].text.strip()

        # For losers, we assign a 0 for the EC vote instead of "-" on the page
        if (j == 0): 
            ev = table_tr[j].findAll("span", {"class": "e-ev-display"})[0].text.strip()
        else: 
            ev = '0'

        # Track the progress
        print("  ", cand, party, votes, pct, ev)

        # Write the data (one row)
        _ = f.write(state + "," + cand + "," + party + "," + votes + "," + pct + "," + ev + "\n")
        ## Assign f.write to - (an empty object) is to bypass the return message; f.write will return how many characters it wrote, which isn't useful for us.

f.close()