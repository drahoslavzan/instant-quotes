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
                 name text NOT NULL UNIQUE,
                 known integer DEFAULT 0
             ); """)

c.execute("""CREATE TABLE IF NOT EXISTS tags (
                 id integer PRIMARY KEY,
                 name text NOT NULL UNIQUE
             ); """)

c.execute("""CREATE TABLE IF NOT EXISTS topics (
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

c.execute("""CREATE TABLE IF NOT EXISTS quote_topics (
                 quote_id integer NOT NULL,
                 topic_id integer NOT NULL,
                 PRIMARY KEY (quote_id, topic_id),
                 FOREIGN KEY(quote_id) REFERENCES quotes(id),
                 FOREIGN KEY(topic_id) REFERENCES topics(id)
             ); """)

#c.execute('CREATE INDEX idx_authors_name ON authors (name ASC);')
c.execute('CREATE INDEX idx_authors_known ON authors (known ASC);')
#c.execute('CREATE INDEX idx_tags_name ON tags (name ASC);')
#c.execute('CREATE INDEX idx_topics_name ON topics (name ASC);')
c.execute('CREATE INDEX idx_quotes_author ON quotes (author_id ASC);')
c.execute('CREATE INDEX idx_quotes_seen ON quotes (seen ASC);')
c.execute('CREATE INDEX idx_quotes_favorite ON quotes (favorite ASC);')
c.execute('CREATE INDEX idx_quote_tags_quote ON quote_tags (quote_id ASC);')
c.execute('CREATE INDEX idx_quote_tags_tag ON quote_tags (tag_id ASC);')
c.execute('CREATE INDEX idx_quote_topics_quote ON quote_tags (quote_id ASC);')
c.execute('CREATE INDEX idx_quote_topics_tag ON quote_tags (tag_id ASC);')

conn.commit()

######################################################################

URL = 'https://brainyquote.com'
AUTHORS = URL + '/authors'
TOPICS = URL + '/topics'

def get_author_links(content):
    soup = BeautifulSoup(content, 'html.parser')
    links = soup.find_all('a', class_='bq_on_link_cl')
    ret = {}
    for link in links:
        author = link.find('span', class_='authorContentName').text
        href = link['href']
        ret[author] = href
    return ret

def get_topic_links(content):
    soup = BeautifulSoup(content, 'html.parser')
    links = soup.find_all('a', class_='bq_on_link_cl')
    ret = {}
    for link in links:
        topic = link.find('span', class_='topicContentName').text
        href = link['href']
        ret[topic] = href
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

def get_all_quotes(content, isAuthor=False):
    info = get_req_info(content)
    ret = get_quotes(content)
    pages = info['lpageNum']
    pg = info['cpageNum'] + 1
    sid = info['domainId']
    vid = info['vid']
    while pg <= pages:
        print('    page: {} / {}'.format(pg, pages), flush=True)
        payload = {
            "typ": "author" if isAuthor else "topic",
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

page = requests.get(TOPICS)
links = get_topic_links(page.content)

for topic,link in links.items():
    print(topic)
    c.execute("INSERT INTO topics (name) VALUES (?);", (topic,))
    topic_id = c.lastrowid
    page = requests.get(URL + link)
    quotes = get_all_quotes(page.content)
    for quote in quotes:
        author = quote['author']
        qtext = quote['quote']
        c.execute("INSERT OR IGNORE INTO authors (name) VALUES (?);", (author,))
        c.execute("SELECT id FROM authors WHERE name = ?;", (author,))
        author_id = c.fetchone()[0]
        c.execute("SELECT id FROM quotes WHERE (quote, author_id) = (?, ?);", (qtext, author_id))
        quote_found = c.fetchone()
        if quote_found:
            print('Duplicate: {} - {}'.format(author, qtext))
            quote_id = quote_found[0]
        else:
            c.execute("INSERT INTO quotes (quote, author_id) VALUES (?, ?);", (qtext, author_id))
            quote_id = c.lastrowid
        for tag in quote['tags']:
            c.execute("INSERT OR IGNORE INTO tags (name) VALUES (?);", (tag,))
            c.execute("SELECT id FROM tags WHERE name = ?;", (tag,))
            tag_id = c.fetchone()[0]
            c.execute("INSERT OR IGNORE INTO quote_tags (quote_id, tag_id) VALUES (?, ?);", (quote_id, tag_id))
        c.execute("INSERT OR IGNORE INTO quote_topics (quote_id, topic_id) VALUES (?, ?);", (quote_id, topic_id))
    conn.commit()
    print("====================================\n", flush=True)

