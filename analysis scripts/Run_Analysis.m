%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: Run_Analysis.m
%
% Notes:
%   * In theory, this function runs the whole analysis for a given subject 
%       and recording type (e.g. m/eeg or fmri). However, it would probably
%       be best to use it as a how to and run the parts individually.
%   * Each function should be commented such that the purpose, inputs,
%       outputs, and usage are clear. 
%   * The high-level wrapper function (i.e. those without a specific data
%       type - NM_PreprocessData v. NM_PreprocessMEEGData) are mainly to
%       demonstrate the steps that should be run to process the data. 
%       - The body of this file contains many comments that attempt to
%           explain the important parts of the analysis. 
%
% Inputs:
% Outputs:
% Usage: 
%   * Run_Analysis()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Run_Analysis()

% * Most of the functions rely heavily on global variables, for two reasons:
%   - It is easier to run them if there are no arguments. Many functions
%       (such as this one) can be run from the editor simply by selecting "run".
%   - Also, matlab is really bad with memory and copies all arguments. This
%       is bad, especially when they are m/eeg data structures.
%   * While the use of globals makes many things easier, it also provides
%       the opportunity for error, if the globals are not as expected. So,
%       please, make sure that they are. 

% * For quick identification, all globals used across functions are
%   prepended with GLA. Those (few) used only within functions are
%   prepended with GL.
% * It might worth checking / clearing these occasionally, because after
%   a while you might end up using a lot of memory by accident.

% * The first step for any analysis is to set the necessary global
%   variables. This helper function does that, but it may be easier to
%   create your own script / cell as it does not set all of them, only
%   those that are necessary. The following are necessary:
%   - GLA_subject: The NIP of the subject being analyzed. This is used to 
%       identify which data to load and folders to use.
%   - GLA_rec_type: The type of data to analyze (either 'fmri' or 'meeg')
%       - For now, we perform two separate analyses for each
%   - GLA_fmri_dir / GLA_meeg_dir: These specify the root directory for
%       either the fmri or meeg analysis. All of the other folders are
%       stored relative to the root (see NM_InitializeGlobals for details)
%       * NOTE: The full path to this directory is always returned by
%           NM_GetRootDirectory().

% * The following globals are not necessary if you use the wrappers, but
%   are integral to the analysis and useful to set beforehand:
%   - GLA_meeg_type: Either 'meg' or 'eeg'.
%       - The meg and eeg data are handled with the mostly the same functions
%           and so this is needed to specify which type to analyze.
%   - GLA_epoch_type: For timecourse data (meg, eeg, eye tracking), we need
%       to know what epochs to load (e.g. 'blinks','word_5','delay', etc.
%   - GLA_fmri_type: For now, the 'localizer' and 'experiment' are
%       processed differently but with the same functions, so this should
%       be specified.
%       - This affects the type of behavioral data loaded as well, so be
%           careful it's set to 'experiment' when analyzing fmri data, if
%           that's what you want to be doing.

NM_InitializeGlobals();


% * The first step in the analysis is to import and convert the data to a
%   usable format in a usable place.
%   - This must be done by hand for the logs and eeg data. 
%   - In theory, this can be done automatically for the eye tracking data,
%       but the edf2asc function seems to not work yet on linux...
%   - For the meg and fmri data, this can be done automatically with the
%       appropriate NM_Import functions.

% * In order to find the data to import, the appropriate sections of the
%   subject_notes.txt files must be filled out (see the functions for details).
%   - These text files are meant to allow the recording of any important
%       occurrences during the recordings, as well as be useful in the
%       analysis. As detailed within NM_InitializeSubjectData, any changes 
%       to the standard analysis are read from this file.

% * For now, max-filter is automatically applied to imported .fif files,
%   with pretty basic parameters. It would be worth fine-tuning these
%   parameters to make sure the data is optimal.

NM_ImportData()


% * The next step is to check all of the output of the experiment to make
%   sure that everything is as expected. This includes checking:
%   - The file structure of the analysis folder, and that all of the data
%       is as expected following importing.
%   - The log output such that the correct stimuli and matching were used
%   - The responses in the data file are as expected.
%   - The triggers in all of the eye tracking, meg, and eeg data
%       - Each of these (along with the stimuli log) are also checked for
%           timing to make sure that all is as expected.
% * This step must be run in its entirety for any subsequent analysis to
%   proceed smoothly, because many relationships between stimuli and
%   support data structures are assumed for the rest of the analysis.

% * NOTE: The experiment folder must be in the path as well as the analysis
%   folder, as we use experiment functions to check the data in order to
%   make sure that we're checking what should have happened.

NM_CheckData();


% * After determining the data is as expected, we preprocess the various
%   data for analysis. 
% * In general, all data types (except the fmri data, which is handled
%   primarily by spm) are subjected to the same basic pipeline and have the
%   same basic functions:
%   * NM_Initialize*Data: Creates the data structure for analysis from the
%       raw data. This will be stored in a GLA_*_data global and saved in a
%       .mat file.
%       - For timecourse data, this .mat will be marked with the type of
%           data (e.g. 'blinks', 'word_5') as well.
%       - Each GLA_*_data function has a 'settings' and 'data' field that
%           are described within the initialize functions. 
%           - The type (e.g. 'word_5', etc.) is stored in the settings field
%           - For the meg and eeg data, the 'data' fields are always
%               fieldtrip data structures that can be given directly to the
%               ft_ functions.
%           - The conditions for each trial are contained in the
%               GLA_meeg_data.data.trialinfo array 
%       - The data types are 'behavioral', 'et', 'meeg', and 'subject'
%           - The GLA_subject_data holds a condensed description of the
%               expeirment stimuli (as constructed during NM_CheckData).
%               - It also holds most of the settings for how to analyze the
%                   various data types (e.g. filter settings, etc.)
%   * NM_Clear*Data: This will delete the stored data and clear the global
%       * So, be careful with it.
%       * NOTE: The NM_Initialize*Data functions will automatically call
%           the associated clear function
%   * NM_Get*DataFilename: Simply returns the name of the .mat file the
%       data is saved to.
%   * NM_Load*Data: Sets the GLA_*_data variable correctly.
%       * Be careful, it will just use the current global value, if the
%           settings match. Be sure that is what you want. You can always
%           set the global to [] first and force a load.
%   * NM_Save*Data: Save the current GLA_*_data to the .mat file.
%       * Careful here, because there is no going back. When testing, it's
%           best to comment this line out so as not to overwrite previous
%           preprocessing steps before you're ready.

% * NM_Preprocess*Data: These are wrapper functions that demonstrate the
%   current steps used to preprocess each type of data.
%   - These are just suggestions, especially for the complex data types
%       (fmri, eeg, meg) and so should probably be tweaked.
% * The basic logic of each is to first initialize the data which organizes
%   the raw data into the useable GLA_*_data structures.
% * Then, for each we call NM_Set*Rejections
%   - This marks certain trials as possible rejections based upon data
%       specific criteria (e.g. blinks in eye tracking data,
%       ft_rejectvisual for m/eeg data).
%   * Importantly, these functions do not actually reject the trials, they
%       just store them in the 'rejections' field of GLA_*_data.
%       - The idea is to keep the full set of trials in GLA_*_data so that
%           different analyses with different rejections can be used (more below).
% * For the m/eeg data, we also clean up the data some by removing P/ICA
%   components. 
%   * Unlike the rejections, this removal is applied to the data, so make
%       sure you want it.
%       - If you run NM_RemoveMEEGComponents() on the blinks first, then 
%           the removed component can then be removed from the experiment data as well.
%       - Also, if there is eye tracking data, the correlation with blinks
%           will be shown.
%           * NOTE: If the eye tracker fails often, it would be worth
%               implementing an alternative method of marking blinks (i.e.
%               using the EEG electrodes close to the eyes) 
%       - Finally, for now the decomposition is applied to the cleaned
%           data. This can be "undone" effectively, however, by simply not
%           choosing to apply any rejections, etc. when asked at the
%           beginning of the function.
% * Also, filtering is applied at some point to the data.
% * Finally, as of now, we repair eeg channels at the beginning of the
%   preprocessing.
%   - Be aware, because the selection screen looks the same as for
%       rejecting trials, but these steps are done separately. First, bad
%       channels are rejected and repaired. Then the trial rejections can
%       be set.
%   - Also, this should probably allow the possibility of rejecting the
%       same channels from all epoch types. For now, the rejection is done
%       independently during each preprocessing. The removed channels are
%       saved in GLA_meeg_data.settings.bad_channels.

% * In summary, the preprocessing should call NM_Initialize*Data and
%   NM_Set*Rejections, and will result in a GLA_*_data structure
%   that has the fields: settings, data, and rejections.
%   - This data can then be loaded using NM_Load*Data.
%   - All permanent processing should be completed such that the data is ready to
%       be analyzed.
%   - Potentially non-permanent processing (e.g. trial rejection, baseline
%       correction, etc.) should not be applied to this data directly (see below).

% * Remember to call NM_AdjustTiming after checking all of the data, but
%   before preprocessing.
%   - This will adjust all of the triggers based upon the difference
%       between the meg triggers and the diode. It is important as no
%       adjustment is applied during the run itself.

% * If filtering crashes because 'fir1' is undefined, it probably means
%   that the signal processing toolbox is not installed. For now, ft needs
%   this function to HPF below 1Hz, so the only option is to not filter or
%   set the cutoff to at least 1Hz.

NM_PreprocessData();


% * There are a set of NM_SanityCheck*Data functions that are really just
%   examples that check to make sure the analyzed data looks reasonable.
% * For m/eeg data, the most useful function for this is
%   NM_DisplayMEEGAverages, which will display various visualizations of
%   the average of the current GLA_meeg_data. 
% * The eye tracking sanity check will plot the average position for the
%   left and right eye movements, so these epoch types must be preprocessed
%   as well as the blinks for this to run.
%   - I.e. set GLA_epoch_type to 'left_eye_movements' and run NM_PreprocessETData

NM_SanityCheckData();

% * The NM_Analyze*Data functions are also merely examples of the most
%   basic type of analysis for each data set.
%   - They are essentially just wrappers that feed calls to
%       NM_AnalyzeSingleValues and NM_AnalyzeTimeCourse, which in turn are
%       mainly place holders for demonstrating how to extract basic
%       measures from the data structures.
% * In general, analyses are intended to be performed on "clean" data,
%   which are created using the NM_CreateClean*Data functions.
%   - This function should apply any potentially analysis specific
%       processing to the data and store the result in GLA_clean_*_data,
%       which is then analyzed.
%   - Across all functions, this involves rejecting trials, suggested to
%       the user through NM_SuggestRejections. This function presents the
%       user with the opportunity to reject any of the trials identified
%       earlier with the NM_Set*Rejection functions.
%       - NOTE: The '-struct' option in the NM_Save*Data functions allows
%           for this, as it saves the GLA_*_data in pieces such that the
%           rejections can be loaded without loading the whole data.
%       * The purpose of this workflow is to allow the same trials to be
%           easily rejected across all data types.
%           - In fact, after each completion of NM_SuggestRejections, the
%               selected rejections for that trial type are saved and the
%               user is asked the next time whether the saved rejections
%               should be used.
%           - Also, the NM_CreateClean*Data functions allow the
%               specification of a set of trials to reject to avoid user
%               input each time.
%   - Other temporary modifications to the data include baseline correcting
%       for m/eeg data as well as band pass filtering.
%       - These can be automatically specified as well to avoid user intervention.

% In summary, to begin analysis, after preprocessing, call
%   NM_CreateClean*Data and perform the analysis over the resulting
%   GLA_clean*data variable.
% * NOTE: In order to analyze any eye tracking data, you must reject all
%   trials with blinks (the data is NaN).

% To add a new epoch type, the following needs to be added:
%   * NM_InitializeSubjectData: Add the appropriate GLA_subject_data.settings.*_epoch 
%   * NM_InitializeETData: Additional strcmp 
%   * NM_InitializeMEEGData: Additional strcmp
%   * NM_GetTrials: Additional strcmp 
%   * NM_GetTrialTriggerTime: Additional case
%   * NM_GetTrialCondition: Additional strcmp

% Run the basis analysis functions
NM_AnalyzeData();

% Extra notes / todo (sorry there are so many...):
%   * As mentioned above, the fmri analysis follows a different flow and is
%       basically a wrapper of Christophe Pallier's existing analysis. The
%       only difference is the folder structure, which separates out the
%       localizer and experiment into different folders (both for
%       preprocessing and analysis).
%   * Much, if not all, of this pipeline should be reexamined. For instance: 
%       - We are only smoothing one run for now, which is wrong but carried 
%           over from previous scripts, sort of.
%       - More options should be added, such as different HRF models
%   * High-pass filtering of the raw m/eeg data still needs some work.
%       - Any cutoff below 1Hz requires the 'fir' filter to work (using
%           ft_preprocessing), which can be a problem (e.g. it requires the
%           signal processing toolbox).
%       - It is incredibly slow as well. For now, we cut the data into 2
%           second epochs around the critical epoch and filter that.
%           - Probably this length should be dependent on the cutoff.
%           - Also, ft_preprocessing provides a padding option, which
%               should be explored.
%       * NOTE: PCA decomposition does not seem to work very well for the
%           eeg data on the blinks, if the data is not filtered first.
%   * Another small tweak to the filtering might be to allow different
%       widths for multiple band stop (i.e. notch) filters. For now, they
%       all share a common width.
%   * The first_ttl for each run is set during NM_CheckBehavioralData(), as
%       it is recorded by the first "response" in the run. 
%   * The NM_GetMEEGChannels function is useful for storing sensor ROIs.
%       New ROIs can be added to the appropriate m/eeg_channel_types.mat
%       variable and then retrieved later by name.
%   * The eeg triggers do not always come through well. Sometimes either
%       the first trigger in a run or missing triggers have to be specified
%       in the meeg_subject_notes.txt file. Errors in NM_CheckMEEGData
%       should indicate when this is necessary. 
%       - See subjects ap100009 and sa130042.
%       - Often, missing triggers will be filled in automatically based on
%           when they should occur. The user will be warned when this happens.
%   * Similarly, the eye tracker will sometimes lose the eye, but will not
%       mark the region as a blink. We check for this and insert a blink marker
%       - Be aware that this may happen a lot for some subjects, in which
%           case the eye tracker data should not be trusted.
%   * Changing analysis settings for a subject takes two steps.
%       - First, change the value in NM_InitializeSubjectData.
%       - Then, call NM_InitializeSubjectData(0). The 0 is important so
%           that the data will not actually be initialized (i.e. returned
%           to its original state). Only the new values will be changed.
%   * It is worth looking through the timing_report.txt file in the
%       subject analysis folder to make sure everything was ok.
%   * If you restart an analysis, remember to clear the GLA* global
%       variables. Otherwise, deleting files will have no effect.
%   * If the decomposition in NM_RemoveMEEGComponent does not line up with
%       the blinks, try changing the meeg_decomp values in NM_InitializeSubjectData
%   * If you exit NM_RemoveMEEGComponents before it finishes, make sure to
%       set GLA_meeg_data = [] before running again so that the data does
%       not become wrongly normalized.
%   * Might have to look into filtering the EEG data to get rid of the
%       apparent oscillations that ride on top of the data.
%   * When you change subjects, it's best to clear the GLA_subject_data


