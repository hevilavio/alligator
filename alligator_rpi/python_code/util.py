import os
import errno
import time

log_dir="/tmp/"
log_file = open(log_dir + "alligator.log", "w", 1) 


if not os.path.exists(log_dir):
	try:
		os.makedirs(log_dir)
	except OSError as e:
		raise e


def log_info(msg):
	formatted_msg = time.strftime("%Y-%m-%d %H:%M:%S") + " - " + msg
	print(formatted_msg)
	log_file.write(formatted_msg + '\n')