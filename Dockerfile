FROM alpine:3.14
RUN apk --no-cache add curl jq bash
COPY testscript.sh /usr/local/bin/testscript.sh
COPY testdata2.csv.csv /usr/local/bin/testdata2.csv.csv
RUN chmod +x /usr/local/bin/testscript.sh
ENTRYPOINT ["/usr/local/bin/testscript.sh"]