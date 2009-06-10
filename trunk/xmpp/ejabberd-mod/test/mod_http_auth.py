#!/usr/bin/env python
#coding=utf-8

# @author Cuong Le <cuonglb@facemain.com>
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

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
