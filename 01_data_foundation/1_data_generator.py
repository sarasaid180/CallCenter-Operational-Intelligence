import pandas as pd
import random
from datetime import datetime, timedelta

# --- Configuration ---
num_agents = 80
num_calls = 10000
start_date = datetime(2025, 1, 1)

# Lists for generating "Real" names
first_names = ['James', 'Mary', 'Robert', 'Patricia', 'John', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth',
               'William', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Charles', 'Karen']
last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
              'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin']

# --- 1. Generate Agents ---
queues = ['Tech Support', 'Billing', 'General', 'Claims']
agents = []
used_names = set()

while len(agents) < num_agents:
    full_name = f"{random.choice(first_names)} {random.choice(last_names)}"
    if full_name not in used_names:  # Ensures we don't have duplicate agents
        used_names.add(full_name)
        agents.append({
            'AgentID': 100 + len(agents),
            'Name': full_name,
            'Queue': random.choice(queues),
            'Tenure_Months': random.randint(1, 48),
            'HourlyRate': random.randint(18, 28)
        })
df_agents = pd.DataFrame(agents)

# --- 2. Generate Calls ---
calls = []
reasons = ['Account Access', 'General Account Update', 'Billing Query', 'Technical Issue', 'Cancel Service',
           'General Inquiry']

for i in range(num_calls):
    agent = random.choice(agents)
    reason = random.choice(reasons)

    if reason == 'General Account Update':
        resolved = 0 if random.random() < 0.70 else 1
        talk_time = random.randint(450, 850)
    elif reason == 'General Inquiry':
        resolved = 1 if random.random() < 0.95 else 0
        talk_time = random.randint(100, 300)
    else:
        resolved = 1 if random.random() < 0.85 else 0
        talk_time = random.randint(250, 550)

    if agent['Tenure_Months'] < 4:
        talk_time = int(talk_time * 1.25)

    wait_time = random.randint(10, 500)
    call_date = start_date + timedelta(days=random.randint(0, 60), hours=random.randint(8, 20))

    calls.append({
        'CallID': 5000 + i,
        'AgentID': agent['AgentID'],
        'Timestamp': call_date,
        'WaitTime': wait_time,
        'TalkTime': talk_time,
        'HoldTime': random.randint(0, 150),
        'IsResolved': resolved,
        'CallReason': reason
    })
df_calls = pd.DataFrame(calls)

# --- 3. Generate Surveys ---
surveys = []
for index, row in df_calls.iterrows():
    if random.random() < 0.38:
        if row['IsResolved'] == 0:
            score = random.randint(1, 2)
            feedback = "Issue not resolved after a long conversation."
        elif row['CallReason'] == 'General Account Update':
            score = random.randint(1, 3)
            feedback = "The new account update process is confusing. Agent tried their best."
        elif row['WaitTime'] > 350:
            score = random.randint(2, 3)
            feedback = "Wait time was unacceptable."
        else:
            score = random.randint(4, 5)
            feedback = "Quick and easy, thanks!"

        surveys.append({
            'SurveyID': 20000 + int(index),
            'CallID': row['CallID'],
            'CSAT_Score': score,
            'FeedbackText': feedback
        })
df_surveys = pd.DataFrame(surveys)

# Export to CSV
df_agents.to_csv('agents_data.csv', index=False)
df_calls.to_csv('calls_data.csv', index=False)
df_surveys.to_csv('surveys_data.csv', index=False)

print(f"Project Data Generated! Files: agents_data.csv, calls_data.csv, surveys_data.csv")
