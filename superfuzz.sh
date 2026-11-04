cat http.txt | httpx-toolkit -title -status-code -tech-detect -follow-redirects -path ficheros.txt -mc 200,301,302 -silent
