%%% sucesor incluye costos

s(s,a,2).
s(e,f,5).
s(f,g,2).
s(g,t,2).
s(d,t,3).
s(s,e,2).
s(a,b,2).
s(b,c,2).
s(c,d,3).

%%% heurística

h(a,5).
h(b,4).
h(c,4).
h(d,3).
h(e,7).
h(f,4).
h(g,2).
h(t,0).

%%% meta

meta(t).
