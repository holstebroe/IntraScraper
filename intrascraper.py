#!/usr/bin/python
from lxml import html
import requests
import sys
import shutil

class IntraSession:
	def __init__(self, baseUrl):
		self.baseUrl = baseUrl
		self.session = requests.Session()
	
	def get(self, url):
		return self.session.get(baseUrl + url)
	
	def getStream(self, url):
		return self.session.get(baseUrl + url, stream=True)

	def post(self, url, postData):
		return self.session.post(baseUrl + url, data=postData)
	
	def getInputData(self, page):
		inputValues = {}
		tree = html.fromstring(page.content)
		inputs = tree.xpath('//input')
		for input in inputs:
			if ('value' in input.attrib and 'name' in input.attrib):
				name = input.attrib['name']
				value = input.attrib['value']
				inputValues[name] = value
		return inputValues
		
	def dumpResponse(self, fileName, response):
		with open(fileName, "w") as text_file:
			text_file.write(response.text.encode('utf-8'))		
	
	def login(self, userName, password):
		loginUrl ='/Account/IdpLogin'
		loginPage = self.get(loginUrl)
#		self.dumpResponse('loginpage.html', loginPage)
		loginData = self.getInputData(loginPage)
		loginData['UserName'] = userName
		loginData['Password'] = password
		loginData['submit'] = 'Login'

		postResponse = self.post(loginUrl, loginData)
#		self.dumpResponse('loginresponse.html', postResponse)
		tree = html.fromstring(postResponse.content)
		postReponseAction = tree.xpath('//form')[0].attrib['action']
		responseData = self.getInputData(postResponse)
		homePage = self.session.post(postReponseAction, responseData)
#		self.dumpResponse('afterlogin.html', homePage)
		
#	def findChildPages(self):
		

class IntraDownloader:
	def __init__(self, intraSession, childBaseUrl):
		self.session = intraSession
		self.baseUrl = childBaseUrl
			
	def downloadPhotoAlbum(self):
		page = self.session.get(self.baseUrl+'/contacts/students/photoalbum')
		tree = html.fromstring(page.content)
		photoImgs = tree.xpath('//div[@class="ccl-imagewithtext-column-image photo-box"]/img')
		studentTexts = tree.xpath('//div[@class="ccl-imagewithtext-title photo-title"]/text()')
		photoUrls = []
		studentNames = []
		for photoImg in photoImgs:
			photoUrls.append(photoImg.attrib['src'])
		for studentText in studentTexts:
			 studentNames.append(studentText.strip())
		namedPhotos = zip(studentNames, photoUrls)
		for namedPhoto in namedPhotos:
			studentName = namedPhoto[0]
			fileName = studentName + ".jpg"
			photoPage = self.session.getStream(namedPhoto[1])
			if photoPage.status_code == 200:
				with open(fileName, 'wb') as f:
					photoPage.raw.decode_content = True
					shutil.copyfileobj(photoPage.raw, f) 		

baseUrl = sys.argv[1]
userName = sys.argv[2]
password = sys.argv[3]
childLink = sys.argv[4]
					
intraSession = IntraSession(baseUrl)
intraSession.login(userName, password)

downloader = IntraDownloader(intraSession, '/parent/'+childLink)
downloader.downloadPhotoAlbum()