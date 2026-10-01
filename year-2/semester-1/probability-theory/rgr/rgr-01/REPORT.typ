#set document(title: "РГР по теории вероятностей. Вариант 5")
#set text(font: "Times New Roman", size: 12pt, lang: "ru")
#set page(paper: "a4", margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2cm))

#include "artifacts/TITLE.typ"
#pagebreak()

#set page(numbering: "1", number-align: center)
#set par(justify: true, leading: 0.65em, first-line-indent: 1.25cm)
#set heading(numbering: "1.")
#show heading: set text(size: 14pt, weight: "bold")
#show raw: set text(font: "Consolas", size: 9pt)
#show raw.where(block: true): set block(breakable: true)
#show raw.where(block: true): set par(leading: 0.3em, first-line-indent: 0pt, justify: false)

#include "report-body.typ"
