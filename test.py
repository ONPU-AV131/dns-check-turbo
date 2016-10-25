#! /usr/bin/env python3
# -*- coding: utf-8 -*-
import dns
import dns.resolver

f=open('list.dns')
for a in f:
    addr = a[:-1]
    try:
        cname = dns.resolver.query('test.'+addr, dns.rdatatype.CNAME)
    except:
        print('not ok -',addr,'- not exist')
        continue
    if cname[0].target.to_text() != addr+'.':
        print('not ok -',addr,'- wrong CNAME')
        continue
    ip = dns.resolver.query(addr,dns.rdatatype.A)
    if ip[0].address != '192.168.1.42':
        print('not ok -',addr,'- wrong A')
        continue
    print('ok -',addr)