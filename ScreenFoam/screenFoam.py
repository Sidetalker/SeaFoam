from PIL import ImageGrab
import time
import datetime

x = 0
while(True):
	time.sleep(600)
	name = str(datetime.datetime.now()).replace(".", " ").replace(":", "-")
	ImageGrab.grab((0, 0, 400, 300)).save("log " + name + ".jpg", "JPEG")
	print "Captured image #" + str(x)
	x+=1