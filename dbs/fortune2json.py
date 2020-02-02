import re
import os
import sqlite3

with open('showerthoughts.dat', 'r') as file:
    data = re.split('[\\r\\n]+%[\\r\\n]+', file.read())

data = list(filter(None, data))
db = 'showerthoughts.db'

if os.path.exists(db):
    os.remove(db)

conn = sqlite3.connect(db)
conn.text_factory = str
c = conn.cursor()

c.execute('PRAGMA foreign_keys = ON;')

c.execute("""CREATE TABLE IF NOT EXISTS quote_infos (
                 id integer PRIMARY KEY,
                 name text NOT NULL,
                 url text
             ); """)

c.execute("""INSERT INTO quote_infos VALUES (
                 1,
                 'showerthoughts',
                 'https://nullprogram.com/blog/2016/12/01/'
             ); """)

c.execute("""CREATE TABLE IF NOT EXISTS quotes (
                 id integer PRIMARY KEY,
                 info_id integer,
                 quote text NOT NULL,
                 author text,
                 date text,
                 seen integer DEFAULT 0,
                 favorite integer DEFAULT 0,
                 FOREIGN KEY(info_id) REFERENCES quote_infos(id)
             ); """)

c.execute('CREATE INDEX idx_quotes_info ON quotes (info_id ASC);')
c.execute('CREATE INDEX idx_quotes_seen ON quotes (seen ASC);')
c.execute('CREATE INDEX idx_quotes_favorite ON quotes (favorite ASC);')

conn.commit()

for d in data:
    try:
        lines = d.strip().splitlines()
        record = ()
        author, year = re.split(', *', lines.pop().strip())
        author = author[3:]
        quote = ' '.join(lines)
        record = (quote, author, year)
        c.execute("INSERT INTO quotes (quote, info_id, author, date) VALUES (?, 1, ?, ?);", record)
        conn.commit()
    except Exception as e:
        print(e)
        print(d)
        exit()

