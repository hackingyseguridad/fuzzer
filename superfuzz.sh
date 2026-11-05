cat http.txt | httpx-toolkit -title -status-code -tech-detect -follow-redirects -path archivos.txt -mc 200 -silent
cat http.txt | httpx-toolkit -title -status-code -tech-detect -follow-redirects -path ficheros.txt -mc 200,301,302 -silent
cat http.txt | httpx-toolkit -title -status-code -tech-detect -follow-redirects -path ficheros2.txt -mc 200,301,302 -silent
