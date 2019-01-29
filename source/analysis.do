import delimited "../data/sample.csv", clear

ivregress 2sls live_urban age c.age#c.age female##married bp_ruralness (school_years c.bp_ruralness#c.school_years = c.bp_prim c.bp_middle c.bp_high c.bp_later c.bp_ruralness#(c.bp_prim c.bp_middle c.bp_high c.bp_later)) [pweight = perwt], r

esttab using "../out/reg_table.html", noomit nobase wide nonumbers replace html
esttab using "../out/reg_table.tex", noomit nobase wide nonumbers replace tex interaction(" $\times$ ")
