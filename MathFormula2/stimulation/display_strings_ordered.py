#! /usr/bin/env python

"""
Demo script for the matformula experiment

christophe@pallier.org
"""

import random, sys, csv
from expyriment import design, control, stimuli, io, misc

#%%
t_fixcross = 500

prime_time = 500
prime_target_interval = 500
target_time = 500

#min_max_ISI = [2000, 3000]
inter_trial_time = [3500, 4500]

#%% Load the stimuli from a csv file

prime_column = 4
target_column = 5
items = [ i for i in csv.reader(open(sys.argv[1])) if i != []]
items = items[1:]  # suppress the first line containing column names


#%%

exp = design.Experiment(name="First Experiment")
# comment the following line to get in real mode
control.set_develop_mode(True)
control.initialize(exp)


#%%

fixcross = stimuli.Circle(10)
fixcross.preload()

block = design.Block(name="block1")

selected_items = items
random.shuffle(selected_items)
for i in selected_items:
    print i
    target = stimuli.TextLine(i[prime_column - 1].decode('utf-8').lstrip().rstrip(),
                            text_size=28, text_font='Inconsolata.ttf')
    
    prime = stimuli.TextLine(i[target_column - 1].decode('utf-8').lstrip().rstrip(),
                            text_size=28, text_font='Inconsolata.ttf')

    trial = design.Trial()
    trial.add_stimulus(prime)    
    trial.add_stimulus(target)
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
        prime = trial.stimuli[0]        
        target = trial.stimuli[1]
        
        fixcross.present()
        exp.clock.reset_stopwatch()
        
        prime.preload()     #is there enough time for the preload of both?   
        target.preload()
        exp.clock.wait(t_fixcross - exp.clock.stopwatch_time)
        exp.clock.wait(200)

        prime.present()
        exp.keyboard.clear()
        exp.clock.wait(prime_time)
        exp.screen.clear()
        exp.screen.update()
        
        exp.clock.wait(prime_target_interval)        
        exp.keyboard.clear()
        
        target.present()
        exp.clock.wait(target_time)
        exp.screen.clear()
        exp.screen.update()
        
        exp.clock.wait(design.randomize.rand_int(inter_trial_time[0], inter_trial_time[1]))
        keys = exp.keyboard.read_out_buffered_keys()
        print(keys)
        #exp.data.add([keys])
#        button, rt = exp.keyboard.wait()
#       exp.data.add([trial.get_factor("Position"), 
#                      button, rt])
        

### 

control.end()
