# RClone Implementation
Documentation for implementing RClone in Tencent Cloud in product backlog [#600](https://github.com/gigascience/gigadb-website/issues/600).

### Important documents
1. GigaDB Backup Transition Plan [here](https://docs.google.com/document/d/1IzM-FkFC5xTQQIsWHWiQmzPFELiWP6Ud1tNuOznc7qo/edit#heading=h.g6xlputqtuim)
2. GigaDB Backup Procedure [here](https://docs.google.com/document/d/1YkiEGdB7gd7wkRZQpFKWPZ2yIxvN4K4GSamd13JxOg0/edit#heading=h.pfibwdizyks3)

### Steps
1. Check VPN access  
    - Log in `GlobalProtect` using BGI username and password.
    - Input `OTP`
2. Log in `smoc` account using BGI username and password, [link](https://smoc.genomics.cn/shterm/login) 
    - Scan the QR code using an Authenticator, like `Google Authenticator` for the first time    
    - Enter the code provided by the Authenticator
    - Download and install `AccessClient` tool locally
    - `xattr -rd com.apple.quarantine <app>` to grant the permission to open  
3. Log in cngb server using `AccessClient`

### Backup plan
1. Sync data in cngb server to tencent cloud  
Since `10.50.11.48` server has mounted GigaDB’s dataset files which are located on `192.168.56.61` server into the local `/data/gigadb` directory
Source: `/data/gigadb`  
Destination: `/cngb/giga/gigadb`  

2. Sync cngb data with local NAS  

3. Sync NAS data to cloud for deployment  

### Tencent `coscmd` info  
```bash
[gigadb@cngb-gigadb-bak ken]$ coscmd -h
usage: coscmd [-h] [-d] [-b BUCKET] [-r REGION] [-c CONFIG_PATH] [-l LOG_PATH]
              [--log_size LOG_SIZE] [--log_backup_count LOG_BACKUP_COUNT] [-v]
              
              {config,upload,download,delete,abort,copy,move,list,listparts,info,restore,signurl,createbucket,deletebucket,putobjectacl,getobjectacl,putbucketacl,getbucketacl,putbucketversioning,getbucketversioning,probe}
              ...

an easy-to-use but powerful command-line tool. try 'coscmd -h' to get more
informations. try 'coscmd sub-command -h' to learn all command usage, likes
'coscmd upload -h'

positional arguments:
  {config,upload,download,delete,abort,copy,move,list,listparts,info,restore,signurl,createbucket,deletebucket,putobjectacl,getobjectacl,putbucketacl,getbucketacl,putbucketversioning,getbucketversioning,probe}
    config              Config your information at first
    upload              Upload file or directory to COS
    download            Download file from COS to local
    delete              Delete file or files on COS
    abort               Aborts upload parts on COS
    copy                Copy file from COS to COS
    move                move file from COS to COS
    list                List files on COS
    listparts           List upload parts
    info                Get the information of file on COS
    restore             Restore
    signurl             Get download url
    createbucket        Create bucket
    deletebucket        Delete bucket
    putobjectacl        Set object acl
    getobjectacl        Get object acl
    putbucketacl        Set bucket acl
    getbucketacl        Get bucket acl
    putbucketversioning
                        Set the versioning state
    getbucketversioning
                        Get the versioning state
    probe               Connection test

optional arguments:
  -h, --help            show this help message and exit
  -d, --debug           Debug mode
  -b BUCKET, --bucket BUCKET
                        Specify bucket
  -r REGION, --region REGION
                        Specify region
  -c CONFIG_PATH, --config_path CONFIG_PATH
                        Specify config_path
  -l LOG_PATH, --log_path LOG_PATH
                        Specify log_path
  --log_size LOG_SIZE   specify max log size in MB (default 1MB)
  --log_backup_count LOG_BACKUP_COUNT
                        specify log backup num
  -v, --version         show program's version number and exit
  
[gigadb@cngb-gigadb-bak ken]$ coscmd list
   cngbdb/              DIR                                              
   stuff/               DIR                                              
   upload_test.log       43      DEEP_ARCHIVE      2021-02-05 14:14:03  
[gigadb@cngb-gigadb-bak ~]$ coscmd list /cngbdb/giga/gigadb/
   cngbdb/giga/gigadb/JBrowse/      DIR               
   cngbdb/giga/gigadb/pub/          DIR 
[gigadb@cngb-gigadb-bak ~]$ coscmd list /cngbdb/giga/gigadb/pub/
   cngbdb/giga/gigadb/pub/10.5524/      DIR               
   cngbdb/giga/gigadb/pub/tmp/          DIR
[gigadb@cngb-gigadb-bak ken]$ coscmd upload -h
usage: coscmd upload [-h] [-r] [-H HEADERS] [-s] [-f] [-y] [--include INCLUDE]
                     [--ignore IGNORE] [--skipmd5] [--delete]
                     local_path cos_path

positional arguments:
  local_path            Local file path as /tmp/a.txt or directory
  cos_path              Cos_path as a/b.txt

optional arguments:
  -h, --help            show this help message and exit
  -r, --recursive       Upload recursively when upload directory
  -H HEADERS, --headers HEADERS
                        Specify HTTP headers
  -s, --sync            Upload and skip the same file
  -f, --force           upload without history breakpoint
  -y, --yes             Skip confirmation
  --include INCLUDE     Specify filter rules, separated by commas; Example:
                        *.txt,*.docx,*.ppt
  --ignore IGNORE       Specify ignored rules, separated by commas; Example:
                        *.txt,*.docx,*.ppt
  --skipmd5             Upload without x-cos-meta-md5 / sync without check
                        md5, only check filename and filesize
  --delete              delete objects which exists in cos but not exist in
```

