import requests
import demjson
import os
import re
import sqlite3
from bs4 import BeautifulSoup

######################################################################

db = 'database.db'
if os.path.exists(db):
    os.remove(db)

conn = sqlite3.connect(db)
#conn.text_factory = str
c = conn.cursor()

c.execute('PRAGMA foreign_keys = ON;')

c.execute("""CREATE TABLE IF NOT EXISTS authors (
                 id integer PRIMARY KEY,
                 name text NOT NULL UNIQUE
             ); """)

c.execute("""CREATE TABLE IF NOT EXISTS tags (
                 id integer PRIMARY KEY,
                 name text NOT NULL UNIQUE
             ); """)

c.execute("""CREATE TABLE IF NOT EXISTS quotes (
                 id integer PRIMARY KEY,
                 author_id integer NOT NULL,
                 quote text NOT NULL,
                 seen integer DEFAULT 0,
                 favorite integer DEFAULT 0,
                 FOREIGN KEY(author_id) REFERENCES authors(id)
             ); """)

c.execute("""CREATE TABLE IF NOT EXISTS quote_tags (
                 quote_id integer NOT NULL,
                 tag_id integer NOT NULL,
                 PRIMARY KEY (quote_id, tag_id),
                 FOREIGN KEY(quote_id) REFERENCES quotes(id),
                 FOREIGN KEY(tag_id) REFERENCES tags(id)
             ); """)

c.execute('CREATE INDEX idx_authors_name ON authors (name ASC);')
c.execute('CREATE INDEX idx_tags_name ON tags (name ASC);')
c.execute('CREATE INDEX idx_quotes_author ON quotes (author_id ASC);')
c.execute('CREATE INDEX idx_quotes_seen ON quotes (seen ASC);')
c.execute('CREATE INDEX idx_quotes_favorite ON quotes (favorite ASC);')
c.execute('CREATE INDEX idx_quote_tags_quote ON quote_tags (quote_id ASC);')
c.execute('CREATE INDEX idx_quote_tags_tag ON quote_tags (tag_id ASC);')

conn.commit()

######################################################################

URL = 'https://brainyquote.com'
AUTHORS = URL + '/authors'

def get_author_links(content):
    soup = BeautifulSoup(content, 'html.parser')
    links = soup.find_all('a', class_='bq_on_link_cl')
    ret = []
    for link in links:
        author = link.find('span', class_='authorContentName').text
        href = link['href']
        ret.append({
            'author': author,
            'link' : href
        })
    return ret

def get_req_info(content):
    search = re.search('window.infoReq.*', content.decode('utf-8'))
    info = re.sub('window.infoReq *= *({.*); *', '\\1', search.group())
    return demjson.decode(info)

def get_quotes(content):
    soup = BeautifulSoup(content, 'html.parser')
    cards = soup.find_all('div', class_='m-brick')
    ret = []
    for card in cards:
        q = card.find('div', class_='clearfix')
        kws = card.find_all('a', class_='qkw-btn')
        quote = q.find('a', class_='b-qt').text
        author = q.find('a', class_='bq-aut').text
        tags = [k.text for k in kws]
        ret.append({
            'author': author,
            'quote': quote,
            'tags': tags
        })
    return ret

def get_all_quotes(content):
    info = get_req_info(content)
    ret = get_quotes(content)
    pages = info['lpageNum']
    pg = info['cpageNum'] + 1
    sid = info['domainId']
    vid = info['vid']
    while pg <= pages:
        payload = {
            "typ": "author",
            "langc": "en",
            "v": "9.7.5:3660255",
            "ab": "a",
            "pg": pg,
            "id": sid,
            "vid": vid
        }
        r = requests.post('https://www.brainyquote.com/api/inf', json=payload)
        data = r.json()
        quotes = get_quotes(data['content'])
        ret.extend(quotes)
        pg += 1
    return ret

page = requests.get(AUTHORS)
links = get_author_links(page.content)

for link in links:
    print(link['author'], flush=True)
    c.execute("INSERT INTO authors (name) VALUES (?);", (link['author'],))
    author_id = c.lastrowid
    page = requests.get(URL + link['link'])
    quotes = get_all_quotes(page.content)
    for quote in quotes:
        c.execute("INSERT INTO quotes (quote, author_id) VALUES (?, ?);", (quote['quote'], author_id))
        quote_id = c.lastrowid
        for tag in quote['tags']:
            c.execute("INSERT OR IGNORE INTO tags (name) VALUES (?);", (tag,))
            c.execute("SELECT id FROM tags WHERE name = ?;", (tag,))
            tag_id = c.fetchone()[0]
            c.execute("INSERT INTO quote_tags (quote_id, tag_id) VALUES (?, ?);", (quote_id, tag_id))
    conn.commit()

