library(DiagrammeR)

grph = "
digraph dag {
graph [rankdir = LR]
node [shape = box] 
Smoking; Sex; Age; Education; Plaque; W2H

Age -> Education
Age -> Plaque
Age -> Smoking
Education -> Smoking
Sex -> Education
Sex -> Smoking
Sex -> W2H
Smoking -> Plaque
Smoking -> W2H
W2H -> Plaque
}      
"

grViz(grph)
