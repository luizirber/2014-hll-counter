DOCUMENT := 2014-hll

all: ${DOCUMENT}.tex
	pdflatex ${DOCUMENT}
	bibtex ${DOCUMENT}
	pdflatex ${DOCUMENT}

clean:
	-rm ${DOCUMENT}.{bbl,blg,dvi,log,out,aux}
