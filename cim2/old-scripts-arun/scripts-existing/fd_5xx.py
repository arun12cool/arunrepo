import dbconn
import datetime

def perf_5xx_error_perc(cur):
   cur.execute("desc hist_pivot_perf_5xx_pod_id_6")
   colmn =  cur.fetchall()
   cur.execute("select * from hist_pivot_perf_5xx_pod_id_6") 
   data = cur.fetchall()
   return data, colmn 


def parse_data(cur):
  row, col = perf_5xx_error_perc(cur)
  cur.execute("drop table if exists demo_table")
  cur.execute("create table demo_table (product_id INT,status varchar(45), count FLOAT,week INT NOT NULL)")
  for c1 in col:
    if c1[0].startswith("week"):
      total_5xx_q1="select sum(%s) as total_5xx from hist_pivot_perf_5xx_pod_id_6 where  status like '5__'"%(c1[0])
      cur.execute(total_5xx_q1)
      data_tot_5xx = cur.fetchall()
      if data_tot_5xx[0][0] == None:
        total_5xx = "NULL"
      else:
        total_5xx=data_tot_5xx[0][0]


      total_5xx_perc_q1="select (a.tot_5xx / b.all_req) as 5xx_perc from (select sum(%s) as tot_5xx from hist_pivot_perf_5xx_pod_id_6 where  status like '5__') a, (select %s as all_req from hist_pivot_perf_5xx_pod_id_6 where status like 'all_requests') b"%(c1[0],c1[0])
      cur.execute(total_5xx_perc_q1)
      data_5xx_perc = cur.fetchall()
      if data_5xx_perc[0][0] == None:
        total_5xx_perc = "NULL"
      else:
        total_5xx_perc=data_5xx_perc[0][0]

      actual_5xx_q1="select sum(%s) as actual_5xx from hist_pivot_perf_5xx_pod_id_6 where status='530' or status='504' or status='503'"%(c1[0])
      cur.execute(actual_5xx_q1)
      data_actual_5xx = cur.fetchall()
      if data_actual_5xx[0][0] == None:
        actual_5xx = "NULL"
      else:
        actual_5xx = data_actual_5xx[0][0]

      actual_5xx_perc_q1="select (a.actual_5xx / b.all_req) as actual_5xx_perc from (select sum(%s) as actual_5xx from hist_pivot_perf_5xx_pod_id_6 where status='530' or status='504' or status='503') a, (select %s as all_req from hist_pivot_perf_5xx_pod_id_6 where status like 'all_requests') b"%(c1[0],c1[0])
      cur.execute(actual_5xx_perc_q1)
      data_actual_5xx_perc_q1 = cur.fetchall()
      if data_actual_5xx_perc_q1[0][0] == None:
        actual_5xx_perc = "NULL"
      else:
        actual_5xx_perc = data_actual_5xx_perc_q1[0][0]

      woy=c1[0].split("_")[-1]
      t_q1="insert into demo_table (product_id,status,count,week) values('6','total_5xx',%s,%s)"%(total_5xx,woy)
      t_q2="insert into demo_table (product_id,status,count,week) values('6','total_5xx_perc',%s,%s)"%(total_5xx_perc,woy)
      t_q3="insert into demo_table (product_id,status,count,week) values('6','actual_5xx',%s,%s)"%(actual_5xx,woy)
      t_q4="insert into demo_table (product_id,status,count,week) values('6','actual_5xx_perc',%s,%s)"%(actual_5xx_perc,woy)

      for db_q in (t_q1,t_q2,t_q3,t_q4):
        cur.execute(db_q)
  return True

def gen_query_extend(q1,weeks,woy,value):
    emp_list=[]
    while weeks:
      emp_list.append(q1%(woy-weeks,value,woy-weeks))
      weeks = weeks - 1
    print emp_list
    return emp_list

def gen_query_aggr(q2,weeks,woy):
    piv_list=[]
    while weeks:
      piv_list.append(q2%(woy-weeks,woy-weeks))
      weeks = weeks - 1
    return piv_list

def perf_data_insert_db(cur):
    perf_def_q1="create view sample_t as select product_id, status, count, week from perf_5xx_error_perc union select product_id,status,count,week from demo_table"
    cur.execute("drop view if exists sample_t")
    cur.execute(perf_def_q1)
    return True

def add_weekly_report(cur,table_name,col,value,rpt_wks,pod_id):
    wks_dct={'lastweek':1,'last2week':2,'last3week':3,'last4week':4,'last5week':5,'last6week':6}
    weeks=wks_dct[rpt_wks]
    woy=int(datetime.date.today().strftime("%W"))

    q1="case when week = %s then %s end as week_%s"

    out_q1=gen_query_extend(q1,weeks,woy,value)
    hist_ext="CREATE view hist_ext_perf_5xx_id_%s as ( select %s.* ,%s from %s where product_id=%s)"%(pod_id,table_name,str(out_q1).replace("'","").replace("[","").replace("]",""),table_name,pod_id)
    print hist_ext
    cur.execute("drop view if exists hist_ext_perf_5xx_id_%s"%pod_id)
    cur.execute(hist_ext)

    q2="sum(week_%s) as week_%s"

    out_q2=gen_query_aggr(q2,weeks,woy)
    hist_piv="CREATE view hist_pivot_perf_5xx_id_%s as ( select %s, %s from hist_ext_perf_5xx_id_%s group by %s)"%(pod_id,col,str(out_q2).replace("'","").replace("[","").replace("]",""),pod_id,col)
    cur.execute("drop view if exists hist_pivot_perf_5xx_id_%s"%pod_id)
    cur.execute(hist_piv)
    print hist_piv
    return True


def get_5xx_report_data(cur):
    cur.execute("select * from hist_pivot_perf_5xx_id_6")
    perf_5xx_row = cur.fetchall()
    cur.execute("desc hist_pivot_perf_5xx_id_6")
    perf_5xx_col = cur.fetchall()
    return perf_5xx_row, perf_5xx_col
