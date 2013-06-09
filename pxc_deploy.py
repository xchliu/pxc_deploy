#coding utf8
# Read the README.MD for detail
import server_list
from pro_lib import ssh_conn

class Process_List():
	def __init__(self):
		self.global_config=server_list.Global_Config()	
		self.server_list=server_list.Server_List()
		self.conn_cmd=ssh_conn.ssh_conn()
		self.conn_ftp=ssh_conn.ssh_sftp()
	def pre_config(self):
		pass
	def file_transfer(self):
		pass
	def install_run(self):
		pss
	def aft_config(self):
		pass
	def status_check(self):
		pass
	def run(self):
		pass

if __name__ == "__main__":
	P=Process_List()
	P.run()

