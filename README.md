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

### RClone cmd info
```bash
kencho@MacBook-Pro:/Volumes/kencho/rclone-implementation (main=) % rclone -h                                                       

Rclone syncs files to and from cloud storage providers as well as
mounting them, listing them in lots of different ways.

See the home page (https://rclone.org/) for installation, usage,
documentation, changelog and configuration walkthroughs.

Usage:
  rclone [flags]
  rclone [command]

Available Commands:
  about           Get quota information from the remote.
  authorize       Remote authorization.
  backend         Run a backend specific command.
  cat             Concatenates any files and sends them to stdout.
  check           Checks the files in the source and destination match.
  cleanup         Clean up the remote if possible.
  config          Enter an interactive configuration session.
  copy            Copy files from source to dest, skipping already copied.
  copyto          Copy files from source to dest, skipping already copied.
  copyurl         Copy url content to dest.
  cryptcheck      Cryptcheck checks the integrity of a crypted remote.
  cryptdecode     Cryptdecode returns unencrypted file names.
  dedupe          Interactively find duplicate filenames and delete/rename them.
  delete          Remove the files in path.
  deletefile      Remove a single file from remote.
  genautocomplete Output completion script for a given shell.
  gendocs         Output markdown docs for rclone to the directory supplied.
  hashsum         Produces a hashsum file for all the objects in the path.
  help            Show help for rclone commands, flags and backends.
  link            Generate public link to file/folder.
  listremotes     List all the remotes in the config file.
  ls              List the objects in the path with size and path.
  lsd             List all directories/containers/buckets in the path.
  lsf             List directories and objects in remote:path formatted for parsing.
  lsjson          List directories and objects in the path in JSON format.
  lsl             List the objects in path with modification time, size and path.
  md5sum          Produces an md5sum file for all the objects in the path.
  mkdir           Make the path if it doesn't already exist.
  mount           Mount the remote as file system on a mountpoint.
  move            Move files from source to dest.
  moveto          Move file or directory from source to dest.
  ncdu            Explore a remote with a text based user interface.
  obscure         Obscure password for use in the rclone config file.
  purge           Remove the path and all of its contents.
  rc              Run a command against a running rclone.
  rcat            Copies standard input to file on remote.
  rcd             Run rclone listening to remote control commands only.
  rmdir           Remove the empty directory at path.
  rmdirs          Remove empty directories under the path.
  selfupdate      Update the rclone binary.
  serve           Serve a remote over a protocol.
  settier         Changes storage class/tier of objects in remote.
  sha1sum         Produces an sha1sum file for all the objects in the path.
  size            Prints the total size and number of objects in remote:path.
  sync            Make source and dest identical, modifying destination only.
  test            Run a test command
  touch           Create new file or change file modification time.
  tree            List the contents of the remote in a tree like fashion.
  version         Show the version number.

Use "rclone [command] --help" for more information about a command.
Use "rclone help flags" for to see the global flags.
Use "rclone help backends" for a list of supported services.
kencho@MacBook-Pro:/Volumes/kencho/rclone-implementation (main=) % rclone sync -h

Sync the source to the destination, changing the destination
only.  Doesn't transfer unchanged files, testing by size and
modification time or MD5SUM.  Destination is updated to match
source, including deleting files if necessary (except duplicate
objects, see below).

**Important**: Since this can cause data loss, test first with the
`--dry-run` or the `--interactive`/`-i` flag.

    rclone sync -i SOURCE remote:DESTINATION

Note that files in the destination won't be deleted if there were any
errors at any point.  Duplicate objects (files with the same name, on
those providers that support it) are also not yet handled.

It is always the contents of the directory that is synced, not the
directory so when source:path is a directory, it's the contents of
source:path that are copied, not the directory name and contents.  See
extended explanation in the `copy` command above if unsure.

If dest:path doesn't exist, it is created and the source:path contents
go there.

**Note**: Use the `-P`/`--progress` flag to view real-time transfer statistics

**Note**: Use the `rclone dedupe` command to deal with "Duplicate object/directory found in source/destination - ignoring" errors.
See [this forum post](https://forum.rclone.org/t/sync-not-clearing-duplicates/14372) for more info.

Usage:
  rclone sync source:path dest:path [flags]

Flags:
      --create-empty-src-dirs   Create empty source dirs on destination after sync
  -h, --help                    help for sync

Use "rclone [command] --help" for more information about a command.
Use "rclone help flags" for to see the global flags.
Use "rclone help backends" for a list of supported services.

```

### Set up rclone to google drive
1. `rclone config`
```conf
[google-drive] #user define
type = drive
client_id = xxxxxxxx #user provide
client_secret = xxxxxxxx #user provide
scope = drive
root_folder_id = rclone_backup #delete this line
token = 'generated by rclone'
```
Example
1. Sync file to google-drive `rclone_backup` 
```bash
kencho@MacBook-Pro:/Volumes/kencho/rclone-implementation (main=) % rclone sync --dry-run install.sh google-drive:rclone_backup --verbose
2021/06/25 16:10:40 NOTICE: install.sh: Skipped copy as --dry-run is set (size 4.386k)
2021/06/25 16:10:40 NOTICE: 
Transferred:        4.386k / 4.386 kBytes, 100%, 40.438 MBytes/s, ETA 0s
Transferred:            1 / 1, 100%
Elapsed time:         1.6s
kencho@MacBook-Pro:/Volumes/kencho/rclone-implementation (main=) % rclone sync -i install.sh google-drive:rclone_backup --verbose 
rclone: copy "install.sh"?
y) Yes, this is OK (default)
n) No, skip this
s) Skip all copy operations with no more questions
!) Do all copy operations with no more questions
q) Exit rclone now.
y/n/s/!/q> y
2021/06/25 16:11:06 INFO  : install.sh: Copied (new)
2021/06/25 16:11:06 NOTICE: 
Transferred:        4.386k / 4.386 kBytes, 100%, 1.242 kBytes/s, ETA 0s
Transferred:            1 / 1, 100%
Elapsed time:         5.1s
```

### rclone usage
1. Primarily  
`rclone sync -i /local/path remote:path` # syncs /local/path to the remote  
2. Optional parameters  
   `--dry-run`: Do a trial run with no permanent changes. Use this to see what rclone would do without actually doing it.  
   `--interactive`: This flag can be used to tell rclone that you wish a manual confirmation before destructive operations.  
   `--update`: Skip any files that are on the remote storage that have a modified time that is newer than the file on the local computer  
   `-–transfers 30`: This sets the number of files to copy in parallel.  
   `-–checkers 8`: How many “checkers” to run in parallel. Checkers monitor the transfers that are in progress.  
   `-–contimeout 60s`: The connection timeout. It sets the time that rclone will try to make a connection to the remote storage.  
   `-–timeout 300s`: If a transfer becomes idle for this amount of time, it is considered broken and is disconnected.  
   `-–retries 3`: If there are this many errors, the entire copy action will be restarted. 
   `-–verbose`: Gives information about every file that is transferred.  