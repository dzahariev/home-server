# MacMini specific settings

## Fan control
Fan speed control should be installed, as the defaults are too pesimistic and machine overheating easy despite the fact that machine is quite noisy.

```
sudo apt-get install mbpfan
```

Configuration:
```
sudo vi /etc/mbpfan.conf
```
Add values:
```
min_fan1_speed = 1800	# put the *lowest* value of "cat /sys/devices/platform/applesmc.768/fan*_min"
max_fan1_speed = 6200	# put the *highest* value of "cat /sys/devices/platform/applesmc.768/fan*_max"

# temperature units in celcius
low_temp = 55			# if temperature is below this, fans will run at minimum speed
high_temp = 65			# if temperature is above this, fan speed will gradually increase
max_temp = 75			# if temperature is above this, fans will run at maximum speed
polling_interval = 1	# default is 1 seconds

```
