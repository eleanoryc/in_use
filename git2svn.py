#!/usr/bin/python

import sys
import argparse
# the .git2svn is the directory to store gitrepo, svn repo, and this script
sys.path.append("./.git2svn")
import subprocess_2_7
import subprocess
import os
import pwd
import re
import logging
import time
import shutil

logger = logging.getLogger()

# declare global variables
CUR_DIR = os.path.expanduser("~") + '/.git2svn'
ROOT_DIR = CUR_DIR + '/' + time.strftime("%Y%m%d_%H%M%S")
#GIT_DIR = CUR_DIR + '/gitrepo/'
SVN_DIR = ROOT_DIR + '/imtncc/'
# list of git repos currently support
GIT_REPO = [ 'NCC_service_def_files', 'connectivity-checker', 'netutils', 'pod_ncc', 'estates', 'tools' ]

#GIT_PULL_CMD= 'git pull'
# git log command will be changed, 
#GIT_LOG_CMD= "git log <previous tag>...<current tag> --pretty=format: --name-status"
GIT_LOG_CMD= ''
GIT_REV_CMD = 'git rev-parse HEAD'

USERID = pwd.getpwuid( os.getuid() ).pw_name
SVNBINARY = "/usr/bin/svn" 
SVNAUTH = '--username ' + USERID
#SVNAUTH = '--username falsetestuser'
SVNARGS = '--non-interactive --trust-server-cert --no-auth-cache '
#SVN_UP = 'svn up ' + SVNAUTH + " " + SVNARGS 

SVN_CO_CMD = SVNBINARY + " " + SVNAUTH + " " + SVNARGS + "co https://vc-commit.ops.sfdc.net/subversion/tools/imtncc"
DISABLE_CRON = "crontab -l | sed '/^[^#].*git2svn.py/s/^/#/' | crontab -"

# error email contents
EMAIL_ERROR_MESSAGE = ""
EMAIL_SUMMARY_MESSAGES = ""

# svn commit flag
SVN_COMMIT_FLAG = True

def init(git_repo_list):

    global EMAIL_ERROR_MESSAGE

    os.makedirs(ROOT_DIR)
    os.chdir(ROOT_DIR)

    # import svn module
    try:
        svnco_output = subprocess_2_7.check_output(SVN_CO_CMD,shell=True)
        logger.info("Checking out svn")
    except subprocess.CalledProcessError as e:
        print("Exception Cmd : " + str(e.cmd))
        print("Cmd Return Code : " + str(e.returncode))
        logger.error("Error raise when running svn co command.")
        logger.error("Exception Cmd : "  + str(e.cmd))
        logger.error("Exception Output : '" +  str(e.output) + "'")
        subprocess.check_call(DISABLE_CRON,shell=True)
        logger.warn("Disabled cronjob")
        EMAIL_ERROR_MESSAGE += "Error raise when running svn co command.\nDisabled cronjob."
        return False

    # for each git repo, do git clone
    for git_repo in git_repo_list:
        if git_repo == 'estates':
            GIT_CLONE_CMD = 'git clone https://git.soma.salesforce.com/estates/'
        elif git_repo == 'tools':
            GIT_CLONE_CMD = 'git clone https://git.soma.salesforce.com/echeung/'
        else:
            GIT_CLONE_CMD = 'git clone https://git.soma.salesforce.com/imt/'

        try:
            gitclone_output = subprocess_2_7.check_output(GIT_CLONE_CMD+git_repo,shell=True)
            print "Running GIT_CLONE_CMD command: " + GIT_CLONE_CMD+git_repo
            logger.info('Running git clone command ' + GIT_CLONE_CMD+git_repo)
        except  subprocess.CalledProcessError as e:
            print("Exception Cmd : " + str(e.cmd))
            print("Cmd Return Code : " + str(e.returncode))
            logger.error("Error raise when running git clone command.")
            logger.error("Exception Cmd : "  + str(e.cmd))
            logger.error("Exception Output : '" +  str(e.output) + "'")
            subprocess.check_call(DISABLE_CRON,shell=True)
            logger.warn("Disabled cronjob")
            EMAIL_ERROR_MESSAGE += "Error raise when running git clone command.\nDisabled cronjob."
            return False

def cleanup():
    # remove the date-time dir
    print "removing working directory" + ROOT_DIR
    shutil.rmtree(ROOT_DIR)

def writeGitVersionFile(git_repo_list):
     # foreach git module
     # cd to the git dir
     # get the git version
     # write the git version
    global EMAIL_ERROR_MESSAGE

    for git_repo in git_repo_list:
        RevFile = CUR_DIR + '/' + git_repo + '_rev.txt'
        print "RevFile in writeGitVersionFile : " + RevFile
        os.chdir(ROOT_DIR + '/' + git_repo)
        try:
            rev_new = subprocess_2_7.check_output(GIT_REV_CMD,shell=True)
            logger.info('Revision number is ' + rev_new)
        except subprocess_2_7.CalledProcessError as e:
            print("Exception Cmd : " + str(e.cmd))
            print("Cmd Return Code : " + str(e.returncode))
            logger.error("Error raise when getting current revision for " + repo )
            logger.error("Exception Cmd : "  + str(e.cmd))
            logger.error("Exception Output : '" +  str(e.output) + "'")
            subprocess.check_call(DISABLE_CRON,shell=True)
            logger.warn("Disabled cronjob")
            EMAIL_ERROR_MESSAGE += "Error raise when getting current revision for " + repo + "\nDisabled cronjob."
            return False   

        try:
            fw = open(RevFile,'w')
            fw.write(rev_new)
            logger.info('Revision number is written in ' + RevFile)
        except IOError:
            print("Problem writing to " + RevFile)
            logger.error("Error raise when writing to " + RevFile)
            subprocess.check_call(DISABLE_CRON,shell=True)
            logger.warn("Disabled cronjob")
            EMAIL_ERROR_MESSAGE += "Error raise when writing to " + RevFile + "\nDisabled cronjob."
            return False
        finally:
            fw.close

def main():

    global EMAIL_ERROR_MESSAGE

    argv = sys.argv[1:]
    ArgParser = argparse.ArgumentParser()
    ArgParser.add_argument('--repo_list', help='List of repo to sync from GIT into SVN(comma separated). eg. tools,connectivity-checker,netutils')
    ArgParser.add_argument('--email_list',help='E-mail addresses (comma separated).  SVN update will sent to the list of email addresses.')
    args = ArgParser.parse_args(args=argv)

    global EMAIL_LIST
    if args.email_list:
        EMAIL_LIST = args.email_list
    else:
        print ("email_list is required.")
        sys.exit(0)
    if args.repo_list:
        git_repos = args.repo_list
        git_repo_list = git_repos.split(",")
        for x in git_repo_list:
             if not x in GIT_REPO:
                  print x + " is not in the supported list of git repo to sync."
                  print "Please type one of the git repos to sync into svn: " + str(GIT_REPO)
                  sys.exit(0)
    
    #Setup the logger utility
    configureLogging(CUR_DIR,logging.INFO)
    logger.info("-" * 100)
    logger.info('Executing: ' + str(sys.argv))
    logger.info("-" * 100)
    
 # call init()
    if(init(git_repo_list) == False):
        sendEmail(EMAIL_ERROR_MESSAGE)
        sys.exit(1)        

 #  for git_repo in git_repo_list:
    gitlog = ''
    global repo
    for git_repo in git_repo_list:
        repo = git_repo + '/'

        gitlog = ''
        RevFile =  CUR_DIR + '/' + repo.strip('/') + '_rev.txt'
        with open(RevFile,'r') as fr:
            rev_old = fr.readline().strip()

        print "cd to the git dir: " + repo
        os.chdir(ROOT_DIR + '/' + repo)

        #  get the new ver
        try:
            rev_new = subprocess_2_7.check_output(GIT_REV_CMD,shell=True)
            logger.info('Getting new revision number : ' + rev_new)
        except subprocess_2_7.CalledProcessError as e:
            print("Exception Cmd : " + str(e.cmd))
            print("Cmd Return Code : " + str(e.returncode))
            logger.error("Error raise when getting current revision for " + repo )
            logger.error("Exception Cmd : "  + str(e.cmd))
            logger.error("Exception Output : '" +  str(e.output) + "'")
            subprocess.check_call(DISABLE_CRON,shell=True)
            logger.warn("Disabled cronjob")
            EMAIL_ERROR_MESSAGE += "Error raise when getting current revision " + repo + "\nDisabled cronjob."

        if rev_old == rev_new:
            next
        #  get git log
        else:
            GIT_LOG_CMD = 'git log ' + rev_old + '...' + rev_new + ' --pretty=format: --name-status'
            try:
                gitlog = subprocess_2_7.check_output(GIT_LOG_CMD,shell=True)
                print gitlog
                logger.info("The git log for " + repo + " between revisions " + rev_old + " and " + rev_new )
                logger.info(gitlog)
            except subprocess_2_7.CalledProcessError as e:
                print("Exception Cmd : " + str(e.cmd))
                print("Cmd Return Code : " + str(e.returncode))
                logger.error("Error raise when getting git log for " + repo + " between revisions " + rev_old + " and " + rev_new )
                logger.error("Exception Cmd : "  + str(e.cmd))
                logger.error("Exception Output : '" +  str(e.output) + "'")
                subprocess.check_call(DISABLE_CRON,shell=True)
                logger.warn("Disabled cronjob")
                EMAIL_ERROR_MESSAGE += "Error raise when getting git log for " + repo + " between revisions " + rev_old + " and " + rev_new  + "\nDisabled cronjob."

        global SVN_COMMIT_FLAG
        if gitlog:
            if(examineGitLog(gitlog) == False):
                SVN_COMMIT_FLAG = False
                return False
    
    if SVN_COMMIT_FLAG:
        svnCommit()       
        writeGitVersionFile(git_repo_list)

    if not EMAIL_ERROR_MESSAGE == "":
        sendEmail(EMAIL_ERROR_MESSAGE)

    if not EMAIL_SUMMARY_MESSAGES == "":
        sendEmail(EMAIL_SUMMARY_MESSAGES)
 
    cleanup()

    exit(0)

def examineGitLog(gitlog):

    # dict will have the filenames changed in git.  filename is the key and mode is the value
    dict = {}
    print repo
    #repo = repo + '/'
    lines = re.split('\n',gitlog)
    for line in reversed(lines):

         if re.search('\S',line):
             # TODO:  need to handle the case if the files have spaces
             mode,filename = line.split()
             print mode,filename
             # if it is a newfile(key) in dict,
             if not filename in dict:
                 dict[filename] = mode
             else:
                 #  Note here the mode from  A -> A or D -> D or D -> M or M -> A will never happen
                 if mode == 'M':
                     if dict[filename] == 'D':
                         dict[filename] = 'M'
                     if dict[filename] == 'A':
                         dict[filename] = 'A'
                     if dict[filename] == 'M':
                         dict[filename] = 'M'
                 if mode == 'A':
                     if dict[filename] == 'D':
                         dict[filename] = 'M'
                     if dict[filename] == 'M':
                         dict[filename] = 'M'
                     if dict[filename] == 'A':
                         dict[filename] = 'A'
                 if mode == 'D':
                     if dict[filename] == 'M':
                         dict[filename] = 'D'
                     if dict[filename] == 'D':
                         dict[filename] = 'D'
                     # A -> M -> M -> D, no action, and remove key from dictionary.
                     if dict[filename] == 'A':
                         del dict[filename]

    # now based on the value for each key in dictionary, call rsync and syncGitSvn functions
    for filename, mode in dict.iteritems() :
        if dict[filename] == 'D':
            svncmd = "delete -q "
            #no need to call rsync or remove file, svn delete will take care of removing file locally
            if(syncGit2Svn(svncmd + " " + repo + '/' +filename) == False):
                return False

        if dict[filename] == 'A':
            svncmd = "add -q "
            filetoadd = ''
            for path_segment in filename.split('/'):
                 if filetoadd:
                     filetoadd += '/'
                 filetoadd += path_segment
                 if not os.path.isdir(SVN_DIR + repo + filetoadd):
                     # We found the first segment in the path that isn't an existing folder
                     #print SVN_DIR + repo + filetoadd
                     break

            if(rsync(filetoadd) == False):
                return False
            if(syncGit2Svn(svncmd + " " + repo + filetoadd) == False):
                return False

        if dict[filename] == 'M':
            svncmd = "update -q "
            if(rsync(filename) == False):
                return False
            if(syncGit2Svn(svncmd + " " + repo+filename) == False):
                return False

    #print dict
    return True

def rsync(filename):
    global EMAIL_ERROR_MESSAGE
    global SVN_COMMIT_FLAG
    src_file_path = ROOT_DIR + '/' + repo
    dest_file_path = SVN_DIR + repo
    RSYNC_CMD = 'rsync -avR ' + filename + " " + dest_file_path
    os.chdir(src_file_path)
    try:
        rsyncOutput = subprocess_2_7.check_output(RSYNC_CMD,shell=True)
        logger.info("Running RSYNC command " + RSYNC_CMD)
    except subprocess.CalledProcessError as e:
        print("Exception Cmd : " + str(e.cmd))
        print("Cmd Return Code : " + str(e.returncode))
        logger.error("Error raise when running rsync command.")
        logger.error("Exception Cmd : "  + str(e.cmd))
        logger.error("Exception Output : '" +  str(e.output) + "'")
        subprocess.check_call(DISABLE_CRON,shell=True)
        logger.warn("Disabled cronjob")
        # update email error var
        EMAIL_ERROR_MESSAGE += "Exception Cmd : " + str(e.cmd) + "\n" + "Exception Output : " +  str(e.output) +  "\nDisabled cronjob."
        SVN_COMMIT_FLAG = False
    #### update the commit flag
    return True

def syncGit2Svn(cmdline):
    global EMAIL_ERROR_MESSAGE
    global SVN_COMMIT_FLAG

    #print "from syncGit2Svn"
    src_file_path = ROOT_DIR + repo
    dest_file_path = SVN_DIR + repo
    SVN_CMD = SVNBINARY + " " + cmdline

    os.chdir(SVN_DIR)
    print(os.getcwd() + "\n")
    print SVN_CMD
    try:
        syncOutput = subprocess_2_7.check_output(SVN_CMD,shell=True)
        logger.info("Running SVN command " + SVN_CMD)
    except subprocess.CalledProcessError as e:
        print("Exception Cmd : " + str(e.cmd))
        print("Cmd Return Code : " + str(e.returncode))
        logger.error("Error raise when running svn command.")
        logger.error("Exception Cmd : "  + str(e.cmd))
        logger.error("Exception Output : '" +  str(e.output) + "'")
        subprocess.check_call(DISABLE_CRON,shell=True)
        logger.warn("Disabled cronjob")
        # update the email error str
        EMAIL_ERROR_MESSAGE += "Exception Cmd : " + str(e.cmd) + "\n" + "Exception Output : " +  str(e.output) + "\nDisabled cronjob."
        SVN_COMMIT_FLAG = False
    ##### update the commit flag
    return True

def svnCommit():

    global EMAIL_SUMMARY_MESSAGES
    SVNCMD = ' commit -m '
    SVNCMDMSG = 'Syncd from gitrepo into svn'
    SVNCOMMITCMD = SVNBINARY + SVNCMD + "'" + SVNCMDMSG + "'" 
    # cd to svn directory
    os.chdir(SVN_DIR)
    SVNSTATUS = SVNBINARY + ' status'
    svnstatusOutput = subprocess_2_7.check_output(SVNSTATUS,shell=True)
    print svnstatusOutput
    # check svn status, if there are changes, then commit.  if not, don't commit, and exit
    if svnstatusOutput:
        try:
            svnCommitOutput = subprocess_2_7.check_output(SVNCOMMITCMD,shell=True)
            print "output :" + svnCommitOutput
            logger.info("Committing the change in SVN: " + svnCommitOutput)
            EMAIL_SUMMARY_MESSAGES = SVNBINARY + SVNCMD + SVNCMDMSG + '\n\n' + svnCommitOutput + '\nExecution completed'
        except subprocess.CalledProcessError as e:
            logger.error("Error raise when committing changes in SVN.")
            logger.error("Exception Cmd : "  + str(e.cmd))
            logger.error("Exception Output : '" +  str(e.output) + "'")
            subprocess.check_call(DISABLE_CRON,shell=True)
            logger.warn("Disabled cronjob")
            EMAIL_SUMMARY_MESSAGES = e.cmd + '\nExecution failed.\nDisabled cronjob.'
            sys.exit(1)

def sendEmail(content):

    print "The updated files will be emailed to the following users : " + EMAIL_LIST
    email_msg = content
    print email_msg
    email_sub = "NCC Sync from gitrepo into SVN"
    email_sub = """ " """ + email_sub + """  " """
    email_cmd = "mailx -s %s %s <<<'%s' " % (email_sub, EMAIL_LIST, email_msg)
    try:
        subprocess.check_call(email_cmd,shell=True)
        logger.info("Email is sent to " + EMAIL_LIST)
    except subprocess.CalledProcessError as e:
        print("Exception Cmd : "  + str(e.cmd))
        print("Cmd Return Code : " +  str(e.returncode))
        ##### log this error
        logger.error("Exception Cmd : "  + str(e.cmd))
        logger.error("Exception Output : '" +  str(e.output) + "'")
    #exit(0)

def configureLogging(dirName,logLevel=logging.INFO):
    global logger
    #Check if we have write permission in this dir
    if not os.access(dirName, os.W_OK):
        dirName = "/tmp"
    logDir = dirName + "/log" 
    logFile = "git2svn_update_" + time.strftime("%Y%m%d")
    if not os.path.exists(logDir):
        os.makedirs(logDir)

    logging.basicConfig(
        filename=logDir + '/' + logFile,
        level=logLevel,
        format='[%(asctime)s] ' + str(os.getpid()) + ' %(levelname)s %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S %Z',
    )
    handler = logging.StreamHandler()
    handler.setLevel(logLevel)
    logger.addHandler(handler)

if __name__ == '__main__':
    main()


