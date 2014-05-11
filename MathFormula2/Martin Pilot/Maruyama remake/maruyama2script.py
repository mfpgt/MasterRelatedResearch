#! /usr/bin/env python

"""
Demo script for the matformula experiment

christophe@pallier.org
"""

import random, sys
import pandas as pd
import numpy as np
import expyriment

#%%
t_fixcross = 500
cross_target_interval = 200
target_time = 200
max_response_time = 2000

#%% Load the experiment info from a csv pased as the first argument
df = pd.read_csv(open(sys.argv[1]))

#initialize experiment parameters

exp = expyriment.design.Experiment(name="SimpleTargetProcedure")
# comment the following line to get in real mode
#expyriment.control.set_develop_mode(True)
expyriment.control.initialize(exp)

fixcross = expyriment.stimuli.Circle(10)
fixcross.preload()

block = expyriment.design.Block(name="block1")

#build trials sequence
for i,stim in enumerate(df['target']):
    target = expyriment.stimuli.TextLine(stim.decode('utf-8').lstrip().rstrip(),
                            text_size=28, text_font='Inconsolata.ttf')

    trial = expyriment.design.Trial()
    trial.add_stimulus(target)
    trial.set_factor("csvIndex",i)
    block.add_trial(trial)

exp.add_block(block)

def wait_for_MRI_synchro():
	msgCross= expyriment.stimuli.Circle(10)
	msgCross.preload()
	msgCross.present()
	#msg = expyriment.stimuli.TextLine(text="Waiting for MRI synchro (Press 's' to continue)",text_size=32)
	#msg.preload()
	#msg.present()
	exp.keyboard.wait_char('s')
	exp.screen.clear()
	exp.screen.update()
#%%

def check_and_wait(key,clock,wait_time,to_check,first_response):
	start = clock.stopwatch_time
	response = to_check
	response_time = first_response
	while((clock.stopwatch_time < (start + wait_time)) and to_check == 0):
		if exp.keyboard.check(key) == key:
			response = 1
			response_time = clock.stopwatch_time
			to_check = 1
	clock.wait(wait_time - (clock.stopwatch_time - start))
	return (response,response_time)

expyriment.control.start(exp)

for block in exp.blocks:
    wait_for_MRI_synchro()
    exp.clock.reset_stopwatch()    
	
    for trial in block.trials:
	
	#trial initialization
	exp.keyboard.clear()
	stimIndex=trial.get_factor("csvIndex")		
	response = 0
	response_time = 0
	#wait for exact onset time
	while (exp.clock.stopwatch_time < df["onset"][stimIndex]):
               exp.clock.wait(1)
	#present cross        
	fixcross.present()
	#print exp.clock.stopwatch_time
	trial.preload_stimuli()
	#print exp.clock.stopwatch_time
	(response,response_time) = check_and_wait(114,exp.clock,t_fixcross - (exp.clock.stopwatch_time - df["onset"][stimIndex]),response,response_time)
	#print exp.clock.stopwatch_time
	
	#present target
	trial.stimuli[0].present()
	target_present_time = exp.clock.stopwatch_time      
	(response,response_time) = check_and_wait(114,exp.clock,target_time,response,response_time)
	exp.screen.clear()
	exp.screen.update()
	
	#response time
	(response,response_time) = check_and_wait(114,exp.clock,max_response_time,response,response_time)
	
	#save data
	exp.data.add([target_present_time,df["target"][stimIndex],response_time,response])
	exp.keyboard.clear()

expyriment.control.end()
