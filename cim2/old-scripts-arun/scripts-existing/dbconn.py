#!/usr/bin/python
import pymysql
import datetime
import settings


class DBBase(object):

  def __init__(self):
    self.host = settings.mysql_host
    self.user = settings.mysql_username
    self.password = settings.mysql_password
    self.dbname = settings.mysql_db

  def dbc(self):
    db = pymysql.connect(self.host,self.user,self.password,self.dbname)
    return db

  def pod_create(self,cur,product):
    cur.execute("INSERT INTO products (product_name) values ('%s')"%(product)) 
    return True

  def get_woy(self):
    woy = datetime.date.today().strftime("%W")
    return int(woy)

  def pod_details(self,cur):
    cur.execute("select * from products")
    data=cur.fetchall()
    cur.execute("desc products")
    colmn=cur.fetchall()
    return data, colmn

  def get_pod_id(self,cur, pod_name):
    cur.execute("select product_id from products where product_name='%s'"%pod_name)
    get_pod_id=cur.fetchall()
    for pod1 in range(len(get_pod_id)):
      for pod in get_pod_id[pod1]:
        pod_id=pod
    return pod_id

  def get_pod_name(self,cur,pod_id):
    cur.execute("select product_name from products where product_id = %s"%pod_id)
    get_pod_name = cur.fetchall()
    return get_pod_name[0][0]

  def reports(self,cur):
    cur.execute("select product_name from products")
    product_detail=cur.fetchall()
    pod_detail=[]
    for p1 in range(len(product_detail)):
      for p2 in product_detail[p1]:
        pod_detail.append(p2)
    return pod_detail
 
  def get_bg_jobs_ds(self,cur,table_name,pod_id):
    wks_dct={'lastweek':1,'last2week':2,'last3week':3,'last4week':4,'last5week':5,'last6week':6}
    weeks=wks_dct['lastweek']
    woy=int(datetime.date.today().strftime("%W")) - weeks    
    colmn=['worker_class','total_jobs','picked_under_5sec','picked_processed_under_5sec','delight_percentage']
    qu1 = "select %s from bg_jobs_delight_score where product_id=%s and week=%s"%(str(colmn).replace("'","").replace("[","").replace("]",""),pod_id,woy)
    cur.execute(qu1)
    data = cur.fetchall()
    return data, colmn


  def gen_query_extend(self,q1,weeks,woy,value):
    emp_list=[] 
    while weeks:
      emp_list.append(q1%(woy-weeks,value,woy-weeks))
      weeks = weeks - 1
    return emp_list


  def gen_query_aggr(self,q2,weeks,woy):
    piv_list=[]
    while weeks:
      piv_list.append(q2%(woy-weeks,woy-weeks))
      weeks = weeks - 1
    return piv_list

  def get_lastuploaded_week(self,table_name,cur):
    cur.execute("select distinct(week) from %s order by week desc limit 1;"%table_name)
    last_week=cur.fetchall()
    return int(str(last_week).replace(",","").replace("(","").replace(")",""))

  def add_weekly_report(self,cur,table_name,col,value,rpt_wks,pod_id,res_dct):
    wks_dct={'lastweek':1,'last2week':2,'last3week':3,'last4week':4,'last5week':5,'last6week':6}
    weeks=wks_dct[rpt_wks]
    woy=int(datetime.date.today().strftime("%W"))

    q1="case when week = %s then %s end as week_%s"

    for k in res_dct.keys():
      for x in res_dct[k]:
  	get_sub_pod_id = self.get_cust_delight_records(cur,pod_id,x,k)
        out_q1=self.gen_query_extend(q1,weeks,woy,value)
        hist_ext="CREATE view hist_ext_sub_pod_id_%s as ( select %s.* ,%s from %s where sub_product_id=%s)"%(get_sub_pod_id,table_name,str(out_q1).replace("'","").replace("[","").replace("]",""),table_name,get_sub_pod_id)
        cur.execute("drop view if exists hist_ext_sub_pod_id_%s"%get_sub_pod_id)
        cur.execute(hist_ext)
 
        q2="sum(week_%s) as week_%s"
    
        out_q2=self.gen_query_aggr(q2,weeks,woy)
        hist_piv="CREATE view hist_pivot_sub_pod_id_%s as ( select %s, %s from hist_ext_sub_pod_id_%s group by %s)"%(get_sub_pod_id,col,str(out_q2).replace("'","").replace("[","").replace("]",""),get_sub_pod_id,col)
        cur.execute("drop view if exists hist_pivot_sub_pod_id_%s"%get_sub_pod_id)
        cur.execute(hist_piv)
    return True 

  def perf_5xx_add_weekly_report(self,cur,table_name,col,value,rpt_wks,pod_id):

    wks_dct={'lastweek':1,'last2week':2,'last3week':3,'last4week':4,'last5week':5,'last6week':6}
    weeks=wks_dct[rpt_wks]
    woy=int(datetime.date.today().strftime("%W"))

    q1="case when week = %s then %s end as week_%s"

    out_q1=self.gen_query_extend(q1,weeks,woy,value)
    hist_ext="CREATE view hist_ext_perf_5xx_pod_id_%s as ( select %s.* ,%s from %s where product_id=%s)"%(pod_id,table_name,str(out_q1).replace("'","").replace("[","").replace("]",""),table_name,pod_id)
    print hist_ext
    cur.execute("drop view if exists hist_ext_perf_5xx_pod_id_%s"%pod_id)
    cur.execute(hist_ext)

    q2="sum(week_%s) as week_%s"

    out_q2=self.gen_query_aggr(q2,weeks,woy)
    hist_piv="CREATE view hist_pivot_perf_5xx_pod_id_%s as ( select %s, %s from hist_ext_perf_5xx_pod_id_%s group by %s)"%(pod_id,col,str(out_q2).replace("'","").replace("[","").replace("]",""),pod_id,col)
    cur.execute("drop view if exists hist_pivot_perf_5xx_pod_id_%s"%pod_id)
    cur.execute(hist_piv)
    print hist_piv
    return True

  def get_cust_delight_records(self,cur,pod_id,sub_product,ctype):
    cur.execute("select sub_product_id from customer_delight_info where product_id=%s and sub_product='%s' and type='%s'"%(pod_id,sub_product,ctype))
    rec1 = cur.fetchall()
    return rec1[0][0]

  def round_of_table_value(self,value):
    rou_of_val=[]
    for val in value:
      if val[0].startswith("week"):
        rou_of_val.append("Round(%s,2)"%val[0])
      else:
        rou_of_val.append(val[0])
    return rou_of_val

  def gen_weekly_report(self,cur,pod_id,res_dct):
    cust_rep_dct={}
    for k in res_dct.keys():
      for x in res_dct[k]:
        get_sub_pod_id = self.get_cust_delight_records(cur,pod_id,x,k) 

        cur.execute("desc hist_pivot_sub_pod_id_%s"%get_sub_pod_id)
        colmn = cur.fetchall()
   
        get_rou_of_query=self.round_of_table_value(colmn)
     
        fin_query = str(get_rou_of_query).replace("'","").replace("[","").replace("]","")
        cur.execute("select %s from hist_pivot_sub_pod_id_%s"%(fin_query,get_sub_pod_id))
        rows = cur.fetchall()

        cust_rep_dct[x+"_"+k]={'%s_%s_rows'%(x,k): rows,'%s_%s_colmn'%(x,k): colmn}
    return cust_rep_dct

  def newrelic_rec_create(self,cur,pod_id,sub_product,acct_id,app_key,app_id,c_code,c_type):
    newrelic_check_query="select * from newrelic_info where product_id=%s and sub_product='%s' and acct_id=%s and app_key='%s' and app_id='%s'and region='%s' and type='%s'"%(pod_id,sub_product,acct_id,app_key,app_id,c_code,c_type)
    cur.execute(newrelic_check_query)
    out_newrelic = cur.fetchall()
    if len(out_newrelic) == 0:
      cur.execute("insert into newrelic_info (product_id,sub_product,acct_id,app_key,app_id,region,type) values ('%s','%s','%s','%s','%s','%s','%s')"%(pod_id,sub_product,acct_id,app_key,app_id,c_code,c_type))
      return True
    else:
      return False

  def newrelic_rec_view(self,cur):
    cur.execute("select sub_product,acct_id,app_id,region,type from newrelic_info")
    data = cur.fetchall()
    colmn = ['Sub Product','Account ID','APP ID','Region', 'Type']
    return data, colmn

  def call_bk_cust_delight_info_create(self,cur,pod_id,sub_product,ctype):
    cur.execute("insert into customer_delight_info (product_id,sub_product,type) values ('%s','%s','%s')"%(pod_id,sub_product,ctype))
    return True
