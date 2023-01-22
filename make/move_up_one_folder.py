import sys
import os
import shutil

if __name__ == '__main__':
	# first arg is where we want the file moved up to
	move_files_to = sys.argv[1]
	files_to_move_path = ''
	for x in os.walk(move_files_to):
		files_to_move_path = os.path.join(x[0], x[1][0])
		break
	for x in os.walk(files_to_move_path):
		# for each child directory
		for directory in x[1]:
			source_path = os.path.join(x[0], directory)
			shutil.move(source_path, move_files_to)

		# for each child file
		for f in x[2]:
			source_path = os.path.join(x[0], f)
			shutil.move(source_path, move_files_to)

	# delete the source path directory
	os.rmdir(files_to_move_path)