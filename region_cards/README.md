# Region Cards

This folder contains the code and the uploaded figures that feed into the region cards (eg: ohi logo).

These cards aim to summerize the main aspect of OHI together with presenting the most relevant OHI global results per region. 

*region_card_v2.Rnw* is the most up to date file that contains the LaTeX code that determines the layout and content of the cards. 

*region_card_src.R* it the code that needs to be run in order to create the cards. This code is written to loop into the 220 regions inorder to create 220 cards. This file also contains the code of the corresponding plots in each section (note: evaluate if its better to save the plots as png -see rgn_plots floder- and then import them to the card or keep it as it is and plot the graphs directly to the cards.)

rgn_reportclass was an initial trail for codin the cards.

???region_card.Rmd contains all text, common to all cards, that is presented in the card.

**NOTE** Other plots and figures for these cards are created in region_map folder and the rgn_plot folder.

**Sate of the Art**
Up to September 2018, this folder contains an initial template for the regional cards.
The src file fails to run probably because of "importing" figures and or creating plots.

The template looks good in terms of design but needs to be improved in tems of color, font and size of each element. 

In this link you can see what is the code doing interms of design of your template: (OverLeaf is a great resource when working with LaTeX)
https://www.overleaf.com/18637829ymhssjymqjws#/70186291/

???See region_card.Rmd for more datails about the content.

