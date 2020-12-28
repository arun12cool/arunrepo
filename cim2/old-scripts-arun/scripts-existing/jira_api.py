import jira
import time
from datetime import datetime as dt
import datetime
from time import strptime
import calendar

def jira_connect(url,username,password):
  client=jira.JIRA(url, basic_auth=(username,password))
  return client

def gen_jira_query(month):
  query="project=INC&"
  first_day, last_day = alter_month_details(month)
  q1 = query + "created>=%s&created<=%s"%(first_day,last_day)
  q2 = q1 + "&status not in ('Incident Created','Problem Identified','Problem Resolved')"
  return q1,q2
  
def get_data_from_jira(client,q1,q2):
  jira_data1 = client.search_issues(q1,startAt=0, json_result=True)
  jira_data2 = client.search_issues(q2,startAt=0, json_result=True)
  return jira_data1, jira_data2

def gen_month_day_range(date):
  first_day = date.replace(day = 1)
  last_day = date.replace(day = calendar.monthrange(date.year, date.month)[1])
  return first_day, last_day

def alter_month_details(mnt):
  month_new=strptime(mnt[:3], '%b').tm_mon
  new_date=datetime.date.today()
  updated_date=new_date.replace(month=month_new)
  return gen_month_day_range(updated_date)

def get_jira_inc_reports(client,data,data1):
  jira_inc={}
  jira_inc['total_incidents']=len(data['issues'])
  jira_inc['rca_completed']=len(data1['issues']) 

  jira_urg_info,jira_high_info,total_bugs = get_jira_total_info(client,data)

  jira_inc['total_bugs']=total_bugs
  return jira_inc,jira_urg_info,jira_high_info

def get_jira_total_info(client,data):
  jira_urg_info={}
  jira_high_info={}
  total_bugs=0
  total_high_bugs=0
  total_urg_bugs=0
  open_high_bugs=0
  open_urg_bugs=0
  time_bef_1w_urg=0
  time_bef_3w_urg=0
  time_bef_3w_high=0
  time_bef_5w_high=0
  issues_id=[]
  for x in data['issues']:
    if len(x['fields']['issuelinks']):
      for a in x['fields']['issuelinks']:
        if "inwardIssue" in a and a['inwardIssue']['key'] not in issues_id:
          issues_id.append(a['inwardIssue']['key'])
          if a['inwardIssue']['fields']['priority']['name'] == "Urgent": 
            total_urg_bugs += 1
            if a['inwardIssue']['fields']['status']['name'] not in ["Done","Closed"]:
              open_urg_bugs += 1           
              query1_in_urg="issue=%s"%(a['inwardIssue']['key'])
              d1_in_urg = client.search_issues(query1_in_urg,startAt=0, json_result=True)
 	      c_in_urg_date = d1_in_urg['issues'][0]['fields']['created']
              if int(((datetime.datetime.utcnow() - dt.strptime(c_in_urg_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 21:
                time_bef_3w_urg += 1
              elif int(((datetime.datetime.utcnow() - dt.strptime(c_in_urg_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 7:
                time_bef_1w_urg += 1	       

          if a['inwardIssue']['fields']['priority']['name'] == "High": 
            total_high_bugs += 1
            if a['inwardIssue']['fields']['status']['name'] not in ["Done","Closed"]:
              open_high_bugs += 1
              query1_in_high="issue=%s"%(a['inwardIssue']['key'])
              d1_in_high = client.search_issues(query1_in_high,startAt=0, json_result=True)
              c_in_high_date = d1_in_high['issues'][0]['fields']['created']
              if int(((datetime.datetime.utcnow() - dt.strptime(c_in_high_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 35:
                time_bef_5w_high += 1
              elif int(((datetime.datetime.utcnow() - dt.strptime(c_in_high_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 21:
                time_bef_3w_high += 1

        elif "outwardIssue" in a and a['outwardIssue']['key'] not in issues_id:
          issues_id.append(a['outwardIssue']['key'])
	  if a['outwardIssue']['fields']['priority']['name'] == "Urgent": 
            total_urg_bugs += 1
            if a['outwardIssue']['fields']['status']['name'] not in ["Done","Closed"]:
              open_urg_bugs += 1
              query1_out_urg="issue=%s"%(a['outwardIssue']['key'])
              d1_out_urg = client.search_issues(query1_out_urg,startAt=0, json_result=True)
              c_out_urg_date = d1_out_urg['issues'][0]['fields']['created']
              if int(((datetime.datetime.utcnow() - dt.strptime(c_out_urg_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 21:
                time_bef_3w_urg += 1
              elif int(((datetime.datetime.utcnow() - dt.strptime(c_out_urg_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 7:
                time_bef_1w_urg += 1

          if a['outwardIssue']['fields']['priority']['name'] == "High":           
            total_high_bugs += 1
            if a['outwardIssue']['fields']['status']['name'] not in ["Done","Closed"]:
              open_high_bugs += 1
              query1_out_high="issue=%s"%(a['outwardIssue']['key'])
              d1_out_high = client.search_issues(query1_out_high,startAt=0, json_result=True)
              c_out_high_date = d1_out_high['issues'][0]['fields']['created']
              if int(((datetime.datetime.utcnow() - dt.strptime(c_out_high_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 35:
                time_bef_5w_high += 1
              elif int(((datetime.datetime.utcnow() - dt.strptime(c_out_high_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 21:
                time_bef_3w_high += 1

        else:
          print "Duplicate or Unknown key detected: ",x['key']


  jira_urg_info['total_urg_bugs'] = total_urg_bugs
  jira_urg_info['open_urg_bugs'] = open_urg_bugs
  jira_urg_info['time_1w_urg_bugs'] = time_bef_1w_urg
  jira_urg_info['time_3w_urg_bugs'] = time_bef_3w_urg

  jira_high_info['total_high_bugs'] = total_high_bugs
  jira_high_info['open_high_bugs'] = open_high_bugs
  jira_high_info['time_3w_high_bugs'] = time_bef_3w_high
  jira_high_info['time_5w_high_bugs'] = time_bef_5w_high
      
  return jira_urg_info,jira_high_info,len(issues_id)
