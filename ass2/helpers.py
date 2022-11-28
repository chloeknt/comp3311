# COMP3311 21T3 Ass2 ... Python helper functions
# add here any functions to share between Python scripts 
# you must submit this even if you add nothing

ALPHA = "abcdefghijklmnopqrstuvwxyzABCEDFGHIJKLMNOPQRSTUVWXYZ"
SORT_ORDER_ONE = {"CC": 0, "PE": 1, "GE": 2, "FE":3}
SORT_ORDER_TWO = {"STREAM": 0, "PROGRAM": 1}

def getProgram(db,code):
  cur = db.cursor()
  cur.execute("select * from Programs where code = %s",[code])
  info = cur.fetchone()
  cur.close()
  if not info:
    return None
  else:
    return info

def getStream(db,code):
  cur = db.cursor()
  cur.execute("select * from Streams where code = %s",[code])
  info = cur.fetchone()
  cur.close()
  if not info:
    return None
  else:
    return info

def getStudent(db,zid):
  cur = db.cursor()
  qry = """
  select p.*, c.name
  from   People p
         join Students s on s.id = p.id
         join Countries c on p.origin = c.id
  where  p.id = %s
  """
  cur.execute(qry,[zid])
  info = cur.fetchone()
  cur.close()
  if not info:
    return None
  else:
    return info

'''
Prints relevant student information from zid
'''
def printStudentInfo(db, zid):
  cur = db.cursor()
  query = 'select People.family, People.given from People where People.id = %s'
  cur.execute(query, [zid])
  for tup in cur.fetchall():
    print(f"{zid} {tup[0]}, {tup[1]}")
  cur.close()

'''
Sorts enrolment information based on term, then course code
'''
def sortEnrolment(db, subjects):
  unsorted = []
  for subject in subjects:
    cur = db.cursor()
    query = "select Subjects.code, Terms.id from Subjects join Courses on Courses.subject = Subjects.id join Terms on Courses.term = Terms.id where Courses.id = %s"
    cur.execute(query, [subject[0]])
    info = cur.fetchone()
    cur.close()
    unsorted.append((subject[0], info[0], info[1]))
  sorted_data = sorted(unsorted, key=lambda element: (element[2], element[1]))
  sorted_subjects = []
  for data in sorted_data:
    for subject in subjects:
      if subject[0] == data[0]:
        sorted_subjects.append(subject)
  return sorted_subjects

'''
Retrieve relevant subject information from subject code 
'''
def getSubjectInfo(db, code):
  cur = db.cursor()
  query = "select Subjects.code, Terms.code, Subjects.name from Subjects join Courses on Courses.subject = Subjects.id join Terms on Courses.term = Terms.id where Courses.id = %s"
  cur.execute(query, [code])
  info = cur.fetchone()
  cur.close()
  if not info:
    return None
  else:
    return info

'''
Print relevant name from Orgunits based on faculty 
'''
def printOfferedByName(db, faculty):
  cur = db.cursor()
  query = 'select Orgunits.longname from Orgunits where Orgunits.id = %s'
  cur.execute(query, [faculty])
  for tup in cur.fetchone():
    print(f"- offered by {tup}")
  cur.close()

'''
Retrieve list of rule_ids for the relevant program code
'''
def getProgramRules(db, code):
  cur = db.cursor()
  query = "select rule from Program_rules where program = %s"
  cur.execute(query, [code])
  tup = cur.fetchall()
  rule_ids = list(sum(tup, ()))
  cur.close()
  return rule_ids

'''
Retrieve stream id for the relevant stream code
'''
def getStreamId(db, code):
  cur = db.cursor()
  query = "select id from Streams where code = %s"
  cur.execute(query, [code])
  tup = cur.fetchone()
  cur.close()
  return tup[0]

'''
Retrieve list of rule_ids for the relevant stream code
'''
def getStreamRules(db, code):
  cur = db.cursor()
  query = "select rule from Stream_rules where stream = %s"
  cur.execute(query, [code])
  tup = cur.fetchall()
  rule_ids = list(sum(tup, ()))
  cur.close()
  return rule_ids

'''
Retrieve rule information based on rule id
'''
def getRuleInfo(db, rule):
  cur = db.cursor()
  query = "select name, type, min_req, max_req, ao_group from Rules where id = %s"
  cur.execute(query, [rule])
  tup = cur.fetchone()
  cur.close()
  return tup

'''
Print the relevant academic object group information from academic object group id
'''
def printAOGInfo(db, ao_group_id):
  cur = db.cursor()
  query = "select definition from Academic_object_groups where id = %s"
  cur.execute(query, [ao_group_id])
  tup = cur.fetchone()
  cur.close()
  done = False
  for data_list in tup:
    data = data_list.split(",")
    for x in data:
      if x == 'GEN#####':
        return ''
      if x.find('#') != -1:
        line = ','.join([str(x) for x in data])
        print(f"- courses matching {line}")
        done = True
        break
    if done:
      break
    for x in data:
      if x.find(";") != -1:
        x = x[1:len(x) - 1]
        x = x.split(";")
        if str(getCourseName(db, x[0])) == '':
          name1 = '???'
        else:
          name1 = str(getCourseName(db, x[0]))
        if str(getCourseName(db, x[1])) == '':
          name2 = '???'
        else:
          name2 = str(getCourseName(db, x[1]))
        x = x[0] + ' ' + name1 + '\n  ' + 'or ' + x[1] + ' ' + name2
        print(f"- {x}")
      else: 
        if str(getCourseName(db, x)) == '':
          name = '???'
        else:
          name = getCourseName(db, x)
        print(f"- {x} {name}")

'''
Retrieve name of a particular stream based on subject code
'''
def getCourseName(db, code):
  cur = db.cursor()
  query = "select name from Subjects where code = %s"
  cur.execute(query, [code])
  tup = cur.fetchone()
  cur.close()
  if tup is not None:
    return tup[0]
  cur = db.cursor()
  query = "select name from Streams where code = %s"
  cur.execute(query, [code])
  tup = cur.fetchone()
  if tup is not None:
    return tup[0]
  else:
    return ''

'''
Retrieve relevant student enrolment information from zid
'''
def getStudentEnrolment(db, zid):
  cur = db.cursor()
  query = "select Program_enrolments.program, Program_enrolments.id from Program_enrolments where Program_enrolments.student = %s"
  cur.execute(query, [zid])
  p_id = cur.fetchone()
  cur.close()
  cur = db.cursor()
  query = "select Programs.code, Programs.name from Programs where Programs.id = %s"
  cur.execute(query, [p_id[0]])
  program = cur.fetchone()
  cur.close()
  cur = db.cursor()
  query = "select Stream_enrolments.stream from Stream_enrolments where Stream_enrolments.partof = %s"
  cur.execute(query, [p_id[1]])
  s_id = cur.fetchone()
  cur.close()
  cur = db.cursor()
  query = "select Streams.code, Streams.name from Streams where Streams.id = %s"
  cur.execute(query, [s_id])
  stream = cur.fetchone()
  cur.close()
  return [program[0], program[1], stream[0], stream[1]]

'''
Check if the subject is part of the 'ADK Courses' academic object group 
'''
def checkAOGInfo(db, rule, subject):
  cur = db.cursor()
  query = "select ao_group from Rules where id = %s"
  cur.execute(query, [rule])
  aog_id = cur.fetchone()
  cur.close()
  cur = db.cursor()
  query = "select definition, name from Academic_object_groups where id = %s and name != 'ADK Courses'"
  cur.execute(query, [aog_id])
  tup = cur.fetchone()
  if tup == None:
    return None
  cur.close()
  for data_list in tup:
    data = data_list.split(",")
    for x in data:
      if x.find('#') != -1:
        new_x = x.replace("#", "")
        if new_x in subject:
          return tup[1]
      elif x.find(";") != -1:
        x = x[1:len(x) - 1]
        x = x.split(";")
        if x[0] == subject or x[1] == subject:
          return tup[1]
      else:
        if x == subject: 
          return tup[1]
  return None

'''
Retrieve required program and stream information as a dictionary where each key is 
the academic object group name, and uoc information is stored along with specific
subject codes if applicable
'''
def getReqs(db, program, stream):
  rule_ids = []
  reqs = {}
  program_rules = getProgramRules(db, program)
  for rule in program_rules:
    rule_ids.append(rule)
  stream_id = getStreamId(db, stream)
  stream_rules = getStreamRules(db, stream_id)
  for rule in stream_rules:
    rule_ids.append(rule)
  for rule_id in rule_ids:
    cur = db.cursor()
    query = "select name, type, min_req, max_req, ao_group from Rules where id = %s"
    cur.execute(query, [rule_id])
    info = cur.fetchone()
    cur.close()
    if info[1] != 'DS' and info[2] is None and info[3] is None:
      subjects = getAOGSubjects(db, info[4])
      for subject in subjects:
        cur = db.cursor()
        query = "select uoc, code from Subjects where code = %s"
        cur.execute(query, [subject.split(' ')[0]])
        uoc = cur.fetchone()
        cur.close()
        if info[0] in reqs:
          uoc_int = int(reqs[info[0]][0]) + uoc[0]
          reqs[info[0]][0] = str(uoc_int)
          reqs[info[0]][1].append(uoc[1])
        else:
          reqs[info[0]] = []
          reqs[info[0]].append(str(uoc[0]))
          reqs[info[0]].append([])
          reqs[info[0]][1].append(uoc[1])
    elif info[1] != 'DS' and info[2] is not None and info[3] is not None:
      reqs[info[0]] = str(info[2]) + ' < ' + str(info[3])
    elif info[1] != 'DS' and info[2] is not None:
      reqs[info[0]] = '> ' + str(info[2])
    elif  info[1] != 'DS':
      reqs[info[0]] = '< ' + str(info[3])
  return reqs

'''
Retrieve the subjects part of a particular academic object group if applicable
'''
def getAOGSubjects(db, aog_id):
  subjects = []
  cur = db.cursor()
  query = "select definition from Academic_object_groups where id = %s"
  cur.execute(query, [aog_id])
  tup = cur.fetchone()
  cur.close()
  for data_list in tup:
    data = data_list.split(",")
    for x in data:
      if x.find(";") != -1:
        x = x[1:len(x) - 1]
        x = x.split(";")
        x = x[0] + '  ' + x[1] 
      subjects.append(x)
  return subjects

'''
Verify if the subject is part of the 'ADK Courses' academic object group
'''
def checkADK(db, rule, subject):
  cur = db.cursor()
  query = "select definition from Academic_object_groups where name = 'ADK Courses'"
  cur.execute(query)
  tup = cur.fetchall()
  subjects = list(sum(tup, ()))
  cur.close()
  subject_list1 = subjects[0].split(',')
  subject_list2 = subjects[1].split(',')
  if subject in subject_list1 or subject in subject_list2:
    return True
  return False

'''
Check if this subject is part of a pairing where students can choose from two subjects
'''
def checkSpecialCase(db, subject):
  cur = db.cursor()
  query = "select definition from Academic_object_groups"
  cur.execute(query)
  for tup in cur.fetchall():
    subjects = tup[0].split(',')
    for element in subjects:
      if element.find('{') != -1 and element.find(subject) != -1:
        return element
  cur.close()
  return None

'''
Sort the leftover dictionary based on 'CC Streams', 'CC Programs', 'PE Streams', 'PE Programs', 
'GE' and 'FE'
'''
def sortLeftDict(db, left, program, stream):
  unsorted_left = []
  for key in left:
    cur = db.cursor()
    query = "select type, id from Rules where name = %s"
    cur.execute(query, [key])
    rule_info = cur.fetchall()
    cur.close
    # if there are multiple rule_ids for the same name
    if len(rule_info) > 1:
      rule_id = selectRule(db, rule_info, program, stream)
    else:
      rule_id = rule_info[0][1]
    result = streamOrProgram(db, rule_id)
    unsorted_left.append((rule_info[0][0], rule_id, result, key))
  sorted_left = sorted(unsorted_left, key=lambda element: (SORT_ORDER_ONE[element[0]], SORT_ORDER_TWO[element[2]], element[1]))
  final_sorted = {}
  for data in sorted_left:
    for info in left:
      if data[3] in left:
        final_sorted[data[3]] = left[data[3]]
  return final_sorted

'''
Determine if the rule is a program rule or a stream rule
'''
def streamOrProgram(db, rule_id):
  cur = db.cursor()
  query = "select program from Program_rules where rule = %s"
  cur.execute(query, [rule_id])
  result = cur.fetchone()
  cur.close
  if result is None:
    return "STREAM"
  return "PROGRAM"

'''
Determines if the given rule name requires 'of' or 'from' string
'''
def ofOrFrom(db, data):
  cur = db.cursor()
  query = "select type from Rules where name = %s"
  cur.execute(query, [data])
  result = cur.fetchone()
  cur.close
  if result is not None and result[0] == 'PE':
    return False
  return True

'''
If there are multiple rule_ids for the same name, check
whether the rule is a program or stream rule.
'''
def selectRule(db, rule_info, program, stream):
  for i in range(len(rule_info)):
    rule_ids = getProgramRules(db, program)
    if rule_info[i][1] in rule_ids:
      return rule_info[i][1]
    stream_id = getStreamId(db, stream)
    stream_rule_ids = getStreamRules(db, stream_id)
    if rule_info[i][1] in stream_rule_ids:
      return rule_info[i][1]