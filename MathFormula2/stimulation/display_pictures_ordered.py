#! /usr/bin/env python

"""
Demo script for the matformula experiment

christophe@pallier.org
"""

import random, sys

t_fixcross = 500
targettime = 500
min_max_ISI = [2000, 3000]

if len(sys.argv)==1:
    print(sys.arg[0] + " csvfile")
    print("csvfile must be a text file containing one picture filename per line (1st column of the table, if tabular format")
    sys.exit()

import csv
stimuliList = [x[0] for x in csv.reader(open(sys.argv[1])) ]

from expyriment import design, control, stimuli, io, misc
from expyriment.misc import constants as _constants

exp = design.Experiment(name="First Experiment")

design.defaults.experiment_background_colour = misc.constants.C_GREY
design.defaults.experiment_background_colour = (50,50,50)


# comment out the following line to get in real mode
control.set_develop_mode(True)



control.initialize(exp)

#%%

fixcross = stimuli.FixCross()
fixcross.preload()

block = design.Block(name="block1")

selected_items = stimuliList
#random.shuffle(selected_items)
for path in selected_items:
    stim = stimuli.Picture(path)
    stim.blur(1)
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
