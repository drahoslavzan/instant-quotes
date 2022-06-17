import requests
import os
import re
import string
import json5
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
                 known integer DEFAULT 0,
                 profession text
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

#c.execute('CREATE INDEX idx_authors_known ON authors (known ASC);')
#c.execute('CREATE INDEX idx_quotes_author ON quotes (author_id ASC);')
#c.execute('CREATE INDEX idx_quotes_seen ON quotes (seen ASC);')
#c.execute('CREATE INDEX idx_quotes_favorite ON quotes (favorite ASC);')
#c.execute('CREATE INDEX idx_quote_tags_quote ON quote_tags (quote_id ASC);')
#c.execute('CREATE INDEX idx_quote_tags_tag ON quote_tags (tag_id ASC);')
#c.execute('CREATE INDEX idx_quote_topics_quote ON quote_tags (quote_id ASC);')
#c.execute('CREATE INDEX idx_quote_topics_tag ON quote_tags (tag_id ASC);')

conn.commit()

######################################################################

URL = 'https://brainyquote.com'
AUTHORS = URL + '/authors'
TOPICS = URL + '/topics'

def get_author_pages(content):
    soup = BeautifulSoup(content, 'html.parser')
    uls = soup.find('ul', class_='pagination')
    if not uls:
        return 1
    last = uls.find_all('li')[-2]
    return int(last.find('a').text)

def get_author_links(content):
    soup = BeautifulSoup(content, 'html.parser')
    table = soup.find('table', class_='table-bordered')
    body = table.find('tbody')
    rows = body.find_all('tr')
    ret = {}
    for row in rows:
        link, profession = row.find_all('td')
        author = link.find('a')
        ret[author.text.strip()] = {
            'profession': profession.text.strip(),
            'link': author['href']
        }
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
    return json5.loads(info)

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

for letter in list(string.ascii_lowercase):
    url = '{}/{}'.format(AUTHORS, letter)
    page = requests.get(url)
    pns = get_author_pages(page.content)
    links = get_author_links(page.content)
    for pn in range(2, pns + 1):
        url = '{}/{}{}'.format(AUTHORS, letter, pn)
        page = requests.get(url)
        more = get_author_links(page.content)
        links.update(more)
    for author,link in links.items():
        prof = link['profession'] 
        print('{} - {}'.format(author, prof))
        c.execute("INSERT INTO authors (name, profession) VALUES (?, ?);", (author, prof))
        author_id = c.lastrowid
        page = requests.get(URL + link['link'])
        quotes = get_all_quotes(page.content, isAuthor=True)
        for quote in quotes:
            author = quote['author']
            qtext = quote['quote']
            c.execute("INSERT INTO quotes (quote, author_id) VALUES (?, ?);", (qtext, author_id))
            quote_id = c.lastrowid
            for tag in quote['tags']:
                c.execute("INSERT OR IGNORE INTO tags (name) VALUES (?);", (tag,))
                c.execute("SELECT id FROM tags WHERE name = ?;", (tag,))
                tag_id = c.fetchone()[0]
                c.execute("INSERT OR IGNORE INTO quote_tags (quote_id, tag_id) VALUES (?, ?);", (quote_id, tag_id))
        conn.commit()
        print("====================================\n", flush=True)

exit()

# remove below

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

