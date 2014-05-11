% Roadmap for MathLangSyntax project
% Christophe@Pallier.org
%

Background
==========

Although written sentences in natural languages or mathematical expressions are typically represented by linear series of symbols, they are associated to *hierarchical tree structures*. 

Examples:


    The little dogs slept -> ((the litte dog) slept)
    The dog slept well -> ((the dog) (slept well))

    I look at the girl with a telescope -> I (look at (the girl (with a telescope)))
    I look at the girl with a telescope -> I (look at (the girl)) (with a telescope)


    1 * 2 + 3  -> (1*2)+3 
    1 + 3 * 2  -> 1+(3*2)

Remarks:


- For sentences, classic arguments for the existence of such structures come from Linguistics (see, e.g. Chomsky *Syntactic structures*, Jackendoff. *Patterns in the mind*. Baker, *Atoms of language*).

- For Maths, the structure can (and sometimes *needs to*) be cued by parentheses.  For *spoken utterances*, there is also some cueing of grouping of words by prosody, although it is important to know that there are mismatches between prosodic ans syntactic structures. See e.g. Nespor). For written text, commas can cue grouping of words, but they are often optional.

- We are focusing here on the *constituent structures* of sentences and expressions. Other types of representations certainly *coexist* (e.g. conceptual representations), with structures that may more or less parallel the constituent structure. 


- These tree structures are associated to context free grammars: in a generative grammar framework, they represent the history of derivation of the sentence. It is therefore important to know about CFG grammars and the associated parsing strategies (bottom-up, top-down. See Jurafsky & Martin. *Speech and Language Processing: An introduction to natural language processing, computational linguistics, and speech recognition.) Yet, it is important to realize that tree structures do not necessarily come from a generative CFG. 


Questions of interest
---------------------

1. Are these constituant structures actually encoded in the brain? (note that this is debated; see e.g, Frank, S. L., and R. Bod. 2011. “Insensitivity of the Human Sentence-Processing System to Hierarchical Structure.” Psychological Science 22 (6): 829–834.).  

2. Are they automatically computed upon seeing a sentence or a formula? 

3. Which brain areas are involved in parsing sentences (e.g. the operation that assigns structure to a string)? Note that the minimal parsing operation is the merging, or unification, or composition of two words.

4. Which brain areas are involved in parsing mathematical formula? Are they the same than for sentences parsing?

5. How are these structures encoded by neural networks? How is the neural activity pattern associated to two merged symbols related to the activities elicited byindividual symbols? 


Directions
==========

1. Are these constituent structures actually encoded in the brain?

It is a working hypothesis on our part that these structures exist in the brain (at least for the simple ones). As long as our experiments 'work', it is supporting the hypothesis. 

2. Are these structures automatically computed upon seeing a sentence or a formula? 

* In language, this is still an open question (from *my* point of view).
  - Some psycholinguists argue against the notion of automatic and systematic computation of the syntactic structure (see, e.g. Townsend and Bever. Sentence Comprehension: The Integration of Habits and Rules.)
  - We have evidence that may be taken against the view that automatic computation (Devauchelle, Pallier, Rizzi & Dehaene, 2009; Pattamadilok, Dehaene & Pallier, submitted).  
  - I suspect that simple, local, structures may be computed automatically but not necessraily the ones spanning longer distances.

* What is the evidence for Maths?

We could run a simple behavioral experiment on this issue:
Asking Subjects to detect substrings "2 + 3" or "3 * 5" in an expression like "2 + 3 * 5". If they rely on a strctured representation, they should be faster for 3 * 5 which is a phrasal constituant than for "2 + 3" which is not. This si actually more or less what Jansen et al. (Jansen, Marriot, Yelland (2000, Constituent Structure in Mathematics) did: they presented a formula for 2.5 se and 1 second later an expression that could be a phrasal constituent or not, or a fragment not matching the expression.


3. Bemis & Pylkkanen (2011) published an experiment on simple composisition that we tried to improve upon by:
- using an incremental design from 1 to 4 words.
- avoiding the block design with different tasks for composition and list.
These data remain to be checked for quality (compare localizer between this experiment and dansestruct) and analysed. 

4. Maruyama et al. (2012) presented more or less structured mathematical formulas manipulated the an experiment but that the short-term memory component may have hidden the parsing complexity. 

We want to:
- rerun the Maruyama experiment without a taxing task and adding a condition with symbols replacing figures to diminish the potentiel role of automatic computations.
- run another fMRI experiment, manipulating the complexity (rather than the legality) of syntactic trees, trying our best to equate visual complexity.
- out of fMRI, find behavioral correlates of parsing complexity of Math formula.


5. There are few proposals for the encoding of symbolic structures in the neural networks (Smolensky. *The Harmonic Mind* and Plate, *Holographics Reduced Representations*).  Can they be used to generate testable predictions for fMRI, MEG, EGG, in terms of syntactic complexity effects?





