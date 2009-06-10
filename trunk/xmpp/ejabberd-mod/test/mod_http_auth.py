#!/usr/bin/env python
#coding=utf-8

# Unittest for mod_http_auth ejabberd module.
# Cuong Le <cuonglb@facemain.com>

import httplib
import unittest

class TestMODHTTPAUTH(unittest.TestCase):
	def setUp(self):
		self.host = "example.com"
		self.port = 5280
		self.uri = "http-auth"
		self.body = """
				{"username":"cuonglb","password":"123456","domain":"example.com"}
		"""
		self.conn = httplib.HTTPConnection(self.host,self.port)

	def tearDown(self):
		self.conn.close()
		
	def test_modhttpauth(self):
		self.conn.request("POST", ''.join(['/',self.uri]),self.body,{"Accept":"application/json"})
		print(self.conn.getresponse().read())

def main():
    suite = unittest.TestLoader().loadTestsFromTestCase(TestMODHTTPAUTH)
    unittest.TextTestRunner().run(suite)


if __name__ == '__main__':
    main()
