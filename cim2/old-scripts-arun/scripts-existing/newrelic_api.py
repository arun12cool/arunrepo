import urllib2
import datetime
from datetime import timedelta

def get_newrelic_record(app_key,acct_id):
  url = "https://api.newrelic.com/v2/applications/%s/metrics/data.json"%acct_id
  header = {'X-Api-Key': '%s'%app_key}
  to_date = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
  from_date = (datetime.datetime.now()-timedelta(days=7)).strftime("%Y-%m-%dT%H:%M:%S")
  data = 'names[]=Apdex&names[]=EndUser/Apdex&values[]=score&from=%s&to=%s&summarize=true'%(from_date,to_date)
  request = urllib2.Request(url,data,header)
  response = urllib2.urlopen(request)
  return response.read()

def newrelic_parse_record(rec, ctype):
  for x in rec['metric_data']['metrics']:
      if ctype == "Backend" and x['name'] == "Apdex":
        apdex_score = x['timeslices'][0]['values']['score']
      if ctype == "Frontend" and x['name'] == "EndUser/Apdex":
        apdex_score = x['timeslices'][0]['values']['score'] 
  return float(apdex_score)

def gen_month_day_range(date):
  first_day = date.replace(day = 1)
  last_day = date.replace(day = calendar.monthrange(date.year, date.month)[1])
  return first_day, last_day

def alter_month_details(mnt):
  month_new=strptime(mnt[:3], '%b').tm_mon
  new_date=datetime.date.today()
  updated_date=new_date.replace(month=month_new)
  return gen_month_day_range(updated_date)
