import jira
import datetime
import calendar
from datetime import timedelta
from time import strptime
from datetime import datetime as dt


def jira_connect(url,username,password):
    client=jira.JIRA(url, basic_auth=(username,password))
    return client

def jira_perf_query(project):
    perf_inc_query = "project=%s & summary ~ 'Investigate low minimum delight score in' AND priority=High ANd status != Closed"%(project)
    return perf_inc_query 

def get_jira_perf_rec(client,pro):
    v2 = jira_perf_query(pro)
    fin_perf_report = client.search_issues(v2,startAt=0, json_result=True)
    return fin_perf_report

def parse_jira_perf_data(client):
    projects = ['Freshdesk','Freshservice']
    perf_jira_records = {}
    for pro in projects:
      bulk_perf_data = get_jira_perf_rec(client,pro)
      total_bugs = bulk_perf_data['total'] 
      total_open_bugs = 0 
      total_inprog_bugs = 0
      time_bef_1w_open = 0
      time_bef_3w_open = 0
      time_bef_3w_inprog = 0
      time_bef_5w_inprog = 0
      if bulk_perf_data:
        for x in bulk_perf_data['issues']:
          if (x['fields']['status']['name']).lower() in ["open","reopen","deferred"] or (x['fields']['status']['statusCategory']['colorName']).lower() == "blue-gray":
            total_open_bugs += 1 
            c_open_bugs_date = x['fields']['created'] 
            if int(((datetime.datetime.utcnow() - dt.strptime(c_open_bugs_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 21:
              time_bef_3w_open += 1
            elif int(((datetime.datetime.utcnow() - dt.strptime(c_open_bugs_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 7:
              time_bef_1w_open += 1 
          if (x['fields']['status']['name']).lower() in ["inprogress"] or (x['fields']['status']['statusCategory']['colorName']).lower() == "yellow":
            total_inprog_bugs += 1
            c_inprog_bugs_date = x['fields']['created']
            if int(((datetime.datetime.utcnow() - dt.strptime(c_inprog_bugs_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 35:
              time_bef_5w_inprog += 1
            elif int(((datetime.datetime.utcnow() - dt.strptime(c_inprog_bugs_date.split('.')[0],'%Y-%m-%dT%H:%M:%S')).total_seconds())/(86400*7)) > 21:
              time_bef_3w_inprog += 1

      perf_jira_records[pro] = {'total_bugs':total_bugs,'total_open_bugs': total_open_bugs,'total_inprog_bugs': total_inprog_bugs,'time_bef_1w_open': time_bef_1w_open,'time_bef_3w_open': time_bef_3w_open ,'time_bef_3w_inprog':time_bef_3w_inprog,'time_bef_5w_inprog': time_bef_5w_inprog}
    return perf_jira_records
