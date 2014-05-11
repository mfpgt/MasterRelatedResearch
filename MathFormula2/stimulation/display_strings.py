#! /usr/bin/env python

"""
Demo script for the matformula experiment

christophe@pallier.org
"""

import random, sys

t_fixcross = 500
targettime = 200
min_max_ISI = [2000, 3000]

#%% Load the stimuli (assuming they are in 1 column csv file)

import csv
items = [ i[0] for i in csv.reader(open(sys.argv[1])) ]

#%%

from expyriment import design, control, stimuli, io, misc

exp = design.Experiment(name="First Experiment")

# comment out the following line to get in real mode
control.set_develop_mode(True)

control.initialize(exp)


#%%

fixcross = stimuli.FixCross()
fixcross.preload()

block = design.Block(name="block1")

selected_items = items
random.shuffle(selected_items)
for i in selected_items[0:20]:
    stim = stimuli.TextLine(i.decode('utf-8'),
                            text_size=28, text_font='Inconsolata.ttf')

    trial = design.Trial()
    trial.add_stimulus(stim)
    block.add_trial(trial)
    
exp.add_block(block)

def wait_for_MRI_synchro():
    msg = stimuli.TextLine(text="Waiting for MRI synchro (Press 's' to continue)",
                           text_size=32)
    msg.preload()
    msg.present()
    exp.keyboard.wait_char('s')
    exp.screen.clear()
    
#%%

control.start(exp)


for block in exp.blocks:
    wait_for_MRI_synchro()
    for trial in block.trials:
        stim = trial.stimuli[0]
        
        fixcross.present()
        exp.clock.reset_stopwatch()
        ISI = design.randomize.rand_int(min_max_ISI[0], min_max_ISI[1])
        stim.preload()
        exp.clock.wait(t_fixcross - exp.clock.stopwatch_time)

        stim.present()
        exp.keyboard.clear()
        exp.clock.wait(targettime)       
        exp.screen.clear()
        exp.screen.update()
        exp.clock.wait(ISI)
        keys = exp.keyboard.read_out_buffered_keys()
        print(keys)
        #exp.data.add([keys])
#        button, rt = exp.keyboard.wait()
#       exp.data.add([trial.get_factor("Position"), 
#                      button, rt])
        

### 

control.end()
