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
max_response_time = 3000

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

expyriment.control.start(exp)

for block in exp.blocks:
    wait_for_MRI_synchro()
    exp.clock.reset_stopwatch()    
	
    for trial in block.trials:
	stimIndex=trial.get_factor("csvIndex")		
	
#	exp.clock.wait(df["onset"][stimIndex]-exp.clock.stopwatch_time)	
#	print(df["onset"][stimIndex])
#	print(exp.clock.stopwatch_time)

	#wait for exact onset time
	while (exp.clock.stopwatch_time < df["onset"][stimIndex]):
               exp.clock.wait(1)

	#present cross        
	fixcross.present()
        trial.preload_stimuli()
	exp.keyboard.clear() #prepare keyboard events to check for press        
        exp.clock.wait(t_fixcross - (exp.clock.stopwatch_time - df["onset"][stimIndex]))

        #present target
	trial.stimuli[0].present()
        target_present_time = exp.clock.stopwatch_time
	#print(target_present_time)      
        exp.clock.wait(target_time)
        exp.screen.clear()
        exp.screen.update()
	
        #get button press event
	#keys = exp.keyboard.read_out_buffered_keys()        
	#save trial results
	#if keys == []:
	#	key = 0
	#else:
	#	key = keys[0]		
	#print key
	#(key,response_time) = exp.keyboard.wait(None,max_response_time)
	#exp.clock.wait((df["onset"][stimIndex+1]-500)-exp.clock.stopwatch_time)
	 	
        #(key,response_time) = exp.keyboard.wait()
	exp.clock.wait(2000)
	if exp.keyboard.check(114) == 114:
		key=1
	else:
		key=0
	response_time=0
	#key=0
	#print keys
	exp.data.add([target_present_time,df["target"][stimIndex],key,response_time])
	exp.keyboard.clear()

expyriment.control.end()
