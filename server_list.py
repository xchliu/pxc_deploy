#coding utf8
import ConfigParser

class Global_Config():
	def __init__(self):
		pass
	def check_info(self):
		pass
	def data_formate(self):
		self.pxc_version=''
		self.pxc_nodes=''
class Server_List():
	def __init__(self):
		self.config=ConfigParser.ConfigParser()
		self.config.read("pxc_deploy.cnf")
		self.server_list=[]
	def server_formate(self):
		return self.server_list
	def server_check(self):
		return self.server_formate()
	def main(self):
		server={}
		global_config=Global_Config()
		for secs in self.config.sections():
			if secs == "global":
				pass
			#	global_config.pxc_version=self.config.get(secs,"pxc_version")
			else:
				server["ip"]=self.config.get(secs,"ip")
				server["user"]=self.config.get(secs,"user")
				server["pwd"]=self.config.get(secs,"pwd")
				self.server_list.append(server)
		return self.server_check()	
if __name__ == "__main__":
	S=Server_List()
	result=S.main()
	print result
