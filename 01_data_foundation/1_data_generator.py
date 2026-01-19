import pandas as pd
import random
from datetime import datetime, timedelta

# --- Configuration ---
num_agents = 80
num_calls = 10000
# Spreading across 2024 and 2025
start_date_range = datetime(2024, 1, 1)

first_names = ['James', 'Mary', 'Robert', 'Patricia', 'John', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth']
last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez']

# --- 1. Generate Agents ---
queues = ['Tech Support', 'Billing', 'General', 'Claims']
agents = []
used_names = set()

while len(agents) < num_agents:
    full_name = f"{random.choice(first_names)} {random.choice(last_names)}"
    if full_name not in used_names:
        agents.append({
            'AgentID': 100 + len(agents),
            'Name': full_name,
            'Queue': random.choice(queues),
            'Tenure_Months': random.randint(1, 48),
            'HourlyRate': random.randint(18, 28),
        })
        used_names.add(full_name)

# --- 2. Generate Calls with "The Twist" ---
calls = []
reasons = ['Account Access', 'General Account Update', 'Billing Query', 'Technical Issue', 'Cancel Service',
           'General Inquiry']

# Crisis Date: June 1st, 2025
crisis_date = datetime(2025, 6, 1)

for i in range(num_calls):
    agent = random.choice(agents)
    reason = random.choice(reasons)

    # NEW: Wider date range (730 days = 2 years)
    call_date = start_date_range + timedelta(days=random.randint(0, 729), hours=random.randint(8, 20))

    # Base Logic
    if reason == 'General Inquiry':
        resolved = 1 if random.random() < 0.95 else 0
        talk_time = random.randint(100, 300)
    else:
        resolved = 1 if random.random() < 0.85 else 0
        talk_time = random.randint(250, 550)

    # --- THE TWIST: System Update Crisis (After June 2025) ---
    if reason == 'General Account Update':
        if call_date >= crisis_date:
            resolved = 0 if random.random() < 0.90 else 1  # 90% Failure rate
            talk_time = random.randint(900, 1500)  # Massive AHT spike
        else:
            resolved = 0 if random.random() < 0.70 else 1
            talk_time = random.randint(450, 850)

    # Experience penalty
    if agent['Tenure_Months'] < 4:
        talk_time = int(talk_time * 1.25)

    calls.append({
        'CallID': 5000 + i,
        'AgentID': agent['AgentID'],
        'Timestamp': call_date,
        'WaitTime': random.randint(10, 500) if call_date < crisis_date else random.randint(300, 800),
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
        # Determine Score based on Crisis
        if row['Timestamp'] >= crisis_date and row['CallReason'] == 'General Account Update':
            score = 1
            feedback = "System was down, agent couldn't help. Terrible experience."
        elif row['IsResolved'] == 0:
            score = random.randint(1, 2)
            feedback = "Issue not resolved."
        else:
            score = random.randint(4, 5)
            feedback = "Great service."

        surveys.append({
            'SurveyID': 20000 + index,
            'CallID': row['CallID'],
            'CSAT_Score': score,
            'FeedbackText': feedback
        })

# Final Exports
pd.DataFrame(agents).to_csv('agents_data.csv', index=False)
df_calls.to_csv('calls_data.csv', index=False)
pd.DataFrame(surveys).to_csv('surveys_data.csv', index=False)

print("Project Data is Generated!")
