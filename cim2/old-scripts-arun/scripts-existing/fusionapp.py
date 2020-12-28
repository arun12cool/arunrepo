from flask import Flask, render_template, request
from werkzeug import secure_filename
import dbconn
import csv
import json
import urllib2
import datetime
import newrelic_api as nr_api
import jira_api
import perf_jira_api
import fd_5xx


app = Flask(__name__)

@app.route('/')
def main():
    return render_template('index.html')

@app.route('/pod_create')
def create_pod():
  return render_template('pod_creator.html')

@app.route('/pod_creator', methods = ['POST'])
def creater_pod():
  if request.method == "POST":
      product = request.form['product']
      cur.execute("select * from products where product_name='%s'"%(product))
      pod_details = cur.fetchall()
      if len(pod_details) == 0:
        call_pod_create = c.pod_create(cur,product)
        db.commit()
        return "Inserted Successfully"
      else:
        return "Product name already exists. <br><a href = '/pod_create'></b> "+ \
            "click here to recreate the pod name</b></a>"

@app.route('/pod_details')
def pod_details():
  data, colmn = c.pod_details(cur)
  return render_template('pod_details.html', data=data, colmn=colmn)

@app.route('/upload')
def file_upload():
  return render_template('upload.html')  

@app.route('/upload_bk')
def upload_bk():
  return render_template('upload_bk.html')

@app.route('/uploader_bk',methods = ['POST'])
def uploader_bk():
  if request.method == "POST":
    wks_dct1={'lastweek':1,'last2week':2,'last3week':3,'last4week':4,'last5week':5,'last6week':6}
    pod_name=request.form['product']
    rpt1_wks=request.form['wks']

    pod_id = c.get_pod_id(cur,pod_name) 

    f = request.files['file']
    file_con=csv.reader(f)
    cols = next(file_con)
    fin_cols = str(cols).replace("\'","").replace("[","").replace("]","")
    query = ("INSERT INTO bg_jobs_delight_score (%s) VALUES %s")

    linedata = []
    for x in file_con:
      if x:
        linedata.append(x)

    for n in range(len(linedata)):
      values=[]
      for i in range(len(cols)):
        values.append(linedata[n][i])
      weeks=wks_dct1[rpt1_wks]
      woy=int(datetime.date.today().strftime("%W")) - weeks
      values.append(woy)
      fin_val=[pod_id]+values
      fin_query=(query%("product_id, "+fin_cols+", week",tuple(fin_val)))
      cur.execute(fin_query)

    db.commit()
    return "file saved successfully"

@app.route('/upload_perf_5xx_perc')
def upload_perf_5xx_perc():
  return render_template('upload_perf_5xx_perc.html')

@app.route('/uploader_perf_5xx_perc', methods=["POST"])
def uploader_perf_5xx_perc():
  if request.method == "POST":
    wks_dct1={'lastweek':1,'last2week':2,'last3week':3,'last4week':4,'last5week':5,'last6week':6}
    pod_name=request.form['product']
    rpt1_wks=request.form['wks']

    pod_id = c.get_pod_id(cur,pod_name)

    f = request.files['file']
    file_con=csv.reader(f)
    cols = next(file_con)
    fin_cols = str(cols).replace("\'","").replace("[","").replace("]","")
    query = "INSERT INTO perf_5xx_error_perc (%s) values %s"

    linedata = []
    for x in file_con:
      if x:
        linedata.append(x)

    for n in range(len(linedata)):
      values=[]
      for i in range(len(cols)):
        values.append(linedata[n][i])
        #values.append(datetime.date.today().strftime("%W"))
      weeks=wks_dct1[rpt1_wks]
      woy=int(datetime.date.today().strftime("%W")) - weeks
      values.append(woy)
      fin_val=[pod_id]+values
      fin_query=(query%("product_id, "+fin_cols+", week",tuple(fin_val)))
      print "Final Query: ",fin_query
      cur.execute(fin_query)

    db.commit()
    return "file saved successfully"


@app.route('/uploader', methods = ['GET','POST'])
def file_uploader():
  if request.method == "POST":
    wks_dct1={'lastweek':1,'last2week':2,'last3week':3,'last4week':4,'last5week':5,'last6week':6}
    pod_name=request.form['product']
    rpt1_wks=request.form['wks'] 
    sub_product=request.form['sub_product']
    ctype = request.form['ctype']
   
    f = request.files['file']

    file_con=csv.reader(f)
    cols = next(file_con)

    fin_cols = str(cols).replace("\'","").replace("[","").replace("]","")
    
    pod_id =  c.get_pod_id(cur,pod_name)
    sub_query="select sub_product_id from customer_delight_info where product_id=%s and type='%s' and sub_product='%s'"%(pod_id,ctype,sub_product)
    cur.execute(sub_query)
    get_sub_query=cur.fetchall()

    sub_pod_id=get_sub_query[0][0]

    query = ("INSERT INTO customer_delight (%s) VALUES %s")

    linedata = []
    for x in file_con:
      if x:
        linedata.append(x)
    for n in range(len(linedata)):
      values=[]
      for i in range(len(cols)):
        values.append(linedata[n][i])
      weeks=wks_dct1[rpt1_wks]
      woy=int(datetime.date.today().strftime("%W")) - weeks 
      values.append(woy)
      fin_val=[sub_pod_id]+values
      fin_query=(query%("sub_product_id, "+fin_cols+", week" ,tuple(fin_val)))
      cur.execute(fin_query)

    db.commit()
    return "file saved successfully"


@app.route('/reports')
def reports():
  pod_details = c.reports(cur)
  return render_template('reports.html', data=pod_details)

@app.route('/report_generate', methods = ["POST"])
def report_generate():
  if request.method == "POST":
    pod_name=request.form['product']
    rpt_wks=request.form['wks']
    res_dct = {'weighted_avg':['freshdesk','falcon_api'],'min_avg':['freshdesk','falcon_api']}
    pod_id = c.get_pod_id(cur,pod_name)
    data, colmn=c.get_bg_jobs_ds(cur,table_name="bg_jobs_delight_score",pod_id=pod_id)   

    cust_delight_week=c.add_weekly_report(cur=cur,table_name="customer_delight",col="module",value="delight_perc",rpt_wks=rpt_wks,pod_id=pod_id,res_dct=res_dct)

    perf_5xx_error=c.perf_5xx_add_weekly_report(cur,table_name="perf_5xx_error_perc",col="status",value="count",rpt_wks=rpt_wks,pod_id=pod_id)
#    get_perf_5xx_error=c.get_perf_5xx_report_data(cur,pod_id)
    get_perf_5xx_parse = fd_5xx.parse_data(cur)
    if get_perf_5xx_parse:
      db.commit()
      out_perf_insert_db=fd_5xx.perf_data_insert_db(cur)
      if out_perf_insert_db:
        db.commit()
        fin_perf_5xx_err = fd_5xx.add_weekly_report(cur=cur,table_name='sample_t',col='status',value='count',rpt_wks=rpt_wks,pod_id=pod_id)
        if fin_perf_5xx_err:
          db.commit()
    get_perf_5xx_row, get_perf_5xx_col = fd_5xx.get_5xx_report_data(cur)

    if cust_delight_week:
      db.commit()   

    report_gen_dct = c.gen_weekly_report(cur, pod_id, res_dct)
    
    falcon_api_min_avg_colmn=report_gen_dct['falcon_api_min_avg']['falcon_api_min_avg_colmn']
    falcon_api_min_avg_rows=report_gen_dct['falcon_api_min_avg']['falcon_api_min_avg_rows']
    falcon_api_weighted_avg_colmn=report_gen_dct['falcon_api_weighted_avg']['falcon_api_weighted_avg_colmn']
    falcon_api_weighted_avg_rows=report_gen_dct['falcon_api_weighted_avg']['falcon_api_weighted_avg_rows']

    freshdesk_min_avg_colmn=report_gen_dct['freshdesk_min_avg']['freshdesk_min_avg_colmn']
    freshdesk_min_avg_rows=report_gen_dct['freshdesk_min_avg']['freshdesk_min_avg_rows']
    freshdesk_weighted_avg_rows=report_gen_dct['freshdesk_weighted_avg']['freshdesk_weighted_avg_rows']
    freshdesk_weighted_avg_colmn=report_gen_dct['freshdesk_weighted_avg']['freshdesk_weighted_avg_colmn']
  

    return render_template('bg_jobs_delight_score.html', data=data, colmn=colmn,falcon_api_min_col=falcon_api_min_avg_colmn, falcon_api_min_row=falcon_api_min_avg_rows, falcon_api_weight_col=falcon_api_weighted_avg_colmn, falcon_api_weight_row=falcon_api_weighted_avg_rows, fd_min_col=freshdesk_min_avg_colmn,fd_min_row=freshdesk_min_avg_rows,fd_weight_col=freshdesk_weighted_avg_colmn,fd_weight_row=freshdesk_weighted_avg_rows, get_perf_5xx_row=get_perf_5xx_row, get_perf_5xx_col=get_perf_5xx_col)

@app.route('/bk_customer_delight_record_create')
def bk_customer_delight_record_create():
  pod_details = c.reports(cur)
  return render_template('bk_customer_delight_record_creat.html', data=pod_details)

@app.route('/bk_customer_delight_record_creator', methods = ['POST'])
def bk_customer_delight_record_creator():
  if request.method == "POST":
    pod_name = request.form['product']
    pod_id = c.get_pod_id(cur,pod_name)
    sub_product = request.form['name']
    ctype = request.form['ctype']
    call_bk_cust_delight_info_create = c.call_bk_cust_delight_info_create(cur,pod_id,sub_product,ctype)
    if call_bk_cust_delight_info_create:
      db.commit()
      return "Inserted Successfully" 

@app.route('/newrelic_record_create')
def newrelic_record():
  pod_details = c.reports(cur)
  return render_template('newrelic_record_creator.html', data=pod_details)

@app.route('/newrelic_record_creator', methods = ['POST'])
def newrelic_record_creator():
  if request.method == "POST":
      pod_name=request.form['product']
      pod_id = c.get_pod_id(cur,pod_name)     
      sub_product = request.form['name']
      acct_id = request.form['accid']
      app_key = request.form['appkey']
      app_id = request.form['appid']
      c_code = request.form['countrycode']
      c_type = request.form['ctype']
      call_newrelic_rec_create = c.newrelic_rec_create(cur,pod_id,sub_product,acct_id,app_key,app_id,c_code,c_type)
      if call_newrelic_rec_create:
        db.commit()
        return "Inserted Successfully"
      else:
        return "Given Newrelic Record already exists. <br><a href = '/newrelic_record_create'></b> "+ \
            "click here to recreate the record</b></a>"

@app.route('/newrelic_record_view')
def newrelic_record_view():
  data, colmn = c.newrelic_rec_view(cur) 
  return render_template('newrelic_record_view.html', data=data, colmn= colmn)

@app.route('/newrelic_report_gen')
def newrelic_report_gen():
  cur.execute("select app_key,app_id,region,sub_product_id,type from newrelic_info")
  out1 = cur.fetchall()
  nr_woy = c.get_woy() - 1
  cur.execute("select * from newrelic_appdex where week=%s"%(nr_woy))
  verify_check_rec = cur.fetchall()
  if len(verify_check_rec) == 0:
    for x in out1:
      c1 = nr_api.get_newrelic_record(x[0],x[1])
      print c1
      if c1:
        rec_out = nr_api.newrelic_parse_record(json.loads(c1),x[-1])
        q1 = "insert into newrelic_appdex (sub_product_id,region,apdex_score,week) values ('%s','%s','%s','%s')"%(x[3],x[2],rec_out,nr_woy)
        cur.execute(q1)
        db.commit()
    return "Inserted all successfully"
  else:
    return "Newrelic Record already generated for lastweek.<br><a href = '/newrelic_record_update'></b> "+ \
             "click here to update the record for lastweek</b></a>"

@app.route('/newrelic_record_update')
def newrelic_record_update():
  cur.execute("select app_key,app_id,region,sub_product_id,type from newrelic_info")
  out1 = cur.fetchall()

  nr_woy = c.get_woy() - 1
  cur.execute("delete from newrelic_appdex where week=%s"%(nr_woy))
  for x in out1:
    c1 = nr_api.get_newrelic_record(x[0],x[1])
    if c1:
      rec_out = nr_api.newrelic_parse_record(json.loads(c1),x[-1])
      q1 = "insert into newrelic_appdex (sub_product_id,region,apdex_score,week) values ('%s','%s','%s','%s')"%(x[3],x[2],rec_out,nr_woy)
      cur.execute(q1)
  db.commit()
  return "Lastweek Record updated successfully"

@app.route('/newrelic_report', methods=['POST','GET'])
def newrelic_report():
  if request.method == 'POST':
    month = request.form['month']
    first_woy, woy = nr_api.alter_month_details(month)
  elif request.method == 'GET':
    cur.execute("select distinct(week) from newrelic_appdex order by week desc limit 1")
    d1 = cur.fetchall()
    woy = str(d1).replace(",","").replace("(","").replace(")","")

  if woy:
    cur.execute("drop view if exists newrelic_s")
    cur.execute("create view newrelic_s as (select ni.sub_product, na.region,na.apdex_score from newrelic_appdex as na inner join newrelic_info as ni on ni.sub_product_id = na.sub_product_id where week=%s)"%(woy))

    cur.execute("drop view if exists hist_ext_newrelic")
    cur.execute("create view hist_ext_newrelic as (select sub_product,case when region = 'US' then apdex_score end as US,case when region = 'EUC' then apdex_score end as EUC, case when region = 'AUS' then apdex_score end as AUS from newrelic_s)")

    cur.execute("drop view if exists hist_piv_newrelic")
    cur.execute("create view hist_piv_newrelic as (select sub_product as products, sum(US) as US, sum(EUC) as EUC, sum(AUS) as AUS from hist_ext_newr group by sub_product)")

    db.commit()
 
    cur.execute("select products,ROUND(US,2),ROUND(EUC,2),ROUND(AUS,2) from hist_piv_newrelic")
    data1 = cur.fetchall()
    cur.execute("desc hist_piv_newrelic")
    col1 = cur.fetchall()
    return data1, col1
  else:
    return False

@app.route('/create_jira_report')
def create_jira_report():
  list_of_months = ['January','February','March','April','May','June','July','August','September','October','November','December']
  return render_template("jira_report_gen.html",month=list_of_months)
  

@app.route('/gen_jira_report', methods = ['POST'])
def gen_jira_report():
  if request.method == "POST":
    pod_name=request.form['product']  
    pod_month=request.form['month']

    jira_pod_id = c.get_pod_id(cur,pod_name)
    
    jira_session = jira_api.jira_connect("https://jira.freshworks.com","pranesh.venkat","Jira@321")
   
    jira_q1, jira_q2 = jira_api.gen_jira_query(pod_month)
    
    jira_d1, jira_d2 = jira_api.get_data_from_jira(jira_session,jira_q1,jira_q2)
    jira_inc_repo = jira_api.get_jira_inc_reports(jira_session,jira_d1,jira_d2)

    for x1 in jira_inc_repo:
      if "total_incidents" in x1:
        cur.execute("insert into jira_incidents (product_id,months,total_incidents,rca_completed,total_bugs) values ('%s','%s','%s','%s','%s')"%(jira_pod_id,pod_month,x1['total_incidents'],x1['rca_completed'],x1['total_bugs']))
      elif "total_urg_bugs" in x1:
        cur.execute("insert into jira_bugs (product_id,months,total_bugs,open_bugs,timeline_bef_1w,timeline_bef_3w,priority) values ('%s','%s','%s','%s','%s','%s','%s')"%(jira_pod_id,pod_month,x1['total_urg_bugs'],x1['open_urg_bugs'],x1['time_1w_urg_bugs'],x1['time_3w_urg_bugs'],"Urgent"))
      elif "total_high_bugs" in x1:
	cur.execute("insert into jira_bugs (product_id,months,total_bugs,open_bugs,timeline_bef_3w,timeline_bef_5w,priority) values ('%s','%s','%s','%s','%s','%s','%s')"%(jira_pod_id,pod_month,x1['total_high_bugs'],x1['open_high_bugs'],x1['time_3w_high_bugs'],x1['time_5w_high_bugs'],"High"))
    db.commit()

    return "Inserted Successfully"

@app.route('/jira_report')
def jira_report():
  cur.execute("select months as 'FD & FS Incident', total_incidents as 'No of Incidents',rca_completed as 'RCA Completed',total_bugs as 'Total Bugs' from jira_incidents")  
  inc_data = cur.fetchall()
  inc_colmn = ['FD & FS Incident','No of Incidents','RCA Completed','Total Bugs']
  

  cur.execute("select months as 'FD & FS Incident', total_bugs as 'Total Bugs',open_bugs as 'Open Bugs',timeline_bef_1w as 'Timeline > 1weeks',timeline_bef_3w as 'Timeline > 3weeks' from  jira_bugs where priority='Urgent'")
  urg_data = cur.fetchall()
  urg_colmn = ['FD & FS Incident','Total Bugs','Open Bugs','Timeline > 1weeks','Timeline > 3weeks']

  cur.execute("select months as 'FD & FS Incident', total_bugs as 'Total Bugs',open_bugs as 'Open Bugs',timeline_bef_3w as 'Timeline > 3weeks',timeline_bef_5w as 'Timeline > 5weeks' from  jira_bugs where priority='High'")
  high_data = cur.fetchall()
  high_colmn = ['FD & FS Incident','Total Bugs','Open Bugs','Timeline > 3weeks','Timeline > 5weeks']

  return render_template('jira_reports.html',data=urg_data,colmn=urg_colmn, data1=high_data, colmn1=high_colmn, data2=inc_data, colmn2=inc_colmn)

@app.route('/gen_jira_perf_report', methods= ['GET','POST'])
def gen_jira_perf_report():
    jira_session=perf_jira_api.jira_connect("https://jira.freshworks.com","pranesh.venkat","Jira@321")

    gen_jira_perf_data = perf_jira_api.parse_jira_perf_data(jira_session)

    for k, v in gen_jira_perf_data.iteritems():
      pod_id = c.get_pod_id(cur,k)
      q1 = "insert into jira_perf_bugs (product_id,total_bugs, total_open_bugs, total_inprog_bugs, time_bef_1w_open, time_bef_3w_open ,time_bef_3w_inprog, time_bef_5w_inprog) values ('%s','%s','%s','%s','%s','%s','%s','%s')"%(pod_id,v['total_bugs'],v['total_open_bugs'],v['total_inprog_bugs'],v['time_bef_1w_open'],v['time_bef_3w_open'],v['time_bef_3w_inprog'],v['time_bef_5w_inprog'])
      cur.execute(q1)
    db.commit()
    return "Inserted Successfully"

@app.route('/jira_perf_report')
def jira_perf_report():
    jira_perf_q1="select * from jira_perf_bugs where updated_time = (select updated_time from jira_perf_bugs order by updated_time desc limit 1)"
    cur.execute(jira_perf_q1)
    perf_jira_row1 = cur.fetchall()

    print perf_jira_row1
    fd_perf_list=[]
    fs_perf_list=[]
    for x in perf_jira_row1:
      get_pod_name = c.get_pod_name(cur,x[0])
      print get_pod_name
      if get_pod_name == "Freshdesk":
        fd_perf_list.append('Freshdesk')
        for n in x[1:]:
          fd_perf_list.append(n)
      if get_pod_name == "Freshservice":
        fs_perf_list.append('Freshservice')
        for n in x[1:]:
          fs_perf_list.append(n)

    cols = ['Product','Total Bugs','Total Open Bugs','Open_bugs Timeline > 3 weeks','Open_bugs Timeline > 5 weeks','Total Inprogress Bugs', 'Inprogess_bugs Timeline>3weeks','Inprogress Bugs Timeline > 5weeks']
    return render_template('jira_perf_report.html',cols = cols, fd_perf=fd_perf_list[:-1], fs_perf=fs_perf_list[:-1])

    
if __name__ == '__main__':
  c = dbconn.DBBase()
  db = c.dbc()
  cur = db.cursor()
  app.run(host='0.0.0.0',port='8080',debug = True)
