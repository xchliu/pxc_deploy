#coding utf8
import paramiko,os
import config
c=config.GlobalConfig(1)
paramiko.util.log_to_file("ssh_conn.log",'ERROR')
class ssh_conn():
    def __init__(self):
        self.ssh=paramiko.SSHClient()
    def ssh2(self,ip,username,pwd,type):
        try:
            #print ip,username,pwd,type
            if type==1:
                key=paramiko.RSAKey.from_private_key_file(pwd)
                self.ssh.load_system_host_keys()
                self.ssh.connect(ip,22,username,pkey=key,timeout=10)
            else:
                self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                self.ssh.connect(ip,22,username,pwd,timeout=10)
            return True
        except Exception,ex:
            #l.log("CONNECTION",str(ex), 1)
            return False
    def close(self):
        self.ssh.close()
    def commmad(self,cmd):
        stdin,stdout,stderr = self.ssh.exec_command(cmd)
        out=stdout.readlines()
        err=stderr.readlines()
        return out,err
    def ssh_connect(self,ip,username,pwd,type,cmd):
        if self.ssh2(ip, username,pwd,type):
            return self.commmad(cmd)
        else:
            return False
class ssh_sftp():
    def __init__(self):
        #self.remotedir='/tmp/'
        self.remotedir=c.remote_path
    def ftp(self,ip,username,pwd,port,key,localdir):
        try:
            transfer=paramiko.Transport((ip,port))
            transfer.set_hexdump(False)
            if key == '' or key is None:
                privatekeyfile = os.path.expanduser('~/.ssh/id_rsa')
                mykey = paramiko.RSAKey.from_private_key_file(privatekeyfile)
                if pwd == '' or pwd is None:
                    transfer.connect(username=username,pkey=mykey)
                else:
                    transfer.connect(username=username,pkey=mykey,password=pwd)
            else:
                transfer.connect(username=username,pkey=key)
            files=os.listdir(localdir)
            for lfile in files:
                sftp=paramiko.SFTPClient.from_transport(transfer)
                rfile=lfile
                #l.log("TRANSFER","Tranfer file: %s" % lfile,3)
                sftp.put(os.path.join(localdir,lfile),os.path.join(self.remotedir,rfile))
            transfer.close()
            return True
        except Exception,e:
            #l.log("TRANSFER",str(e),1)
            transfer.close()
            return False

