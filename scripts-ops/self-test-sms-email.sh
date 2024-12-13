#!/bin/sh

# Script for test the sms and email transmission at tabajara Infrastructure

# Author: Ambrosia - ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com
# Dt: 31/01/2019

NUMTEL="$1"
EMAIL="$2"
JSON_SMS=`mktemp --suffix=-SMS`
JSON_EMAIL=`mktemp --suffix=-EMAIL`

TITLE="Selftest SMS e EMAIL tabajara"
DT=`date +%c`
MSG="Se chegou esta funcionando - Internamente - $DT"

# TRF SEQ
value=`/usr/bin/expr $RANDOM \% 10000000`

fn_make_mail_body()
	{ 
	# Make the body

cat > $JSON_EMAIL <<END
{
        "idHost":"software",
        "idTrns":"SITEF:9999999:AAAAA:$value",
        "numTentativas":0,
        "tempoIntervalo":0,
        "mensagens":
        [
                {
                        "contato":"$EMAIL",
                        "assunto":"$TITLE",
                        "corpo":"$MSG"
                }
        ]
}
END

##
cat > $JSON_SMS <<END
{
        "idHost":"software",
        "idTrns":"SITEF:9999999:AAAAA:$value",
        "numTentativas":0,
        "tempoIntervalo":0,
        "mensagens":
        [
                {
                        "numero":"$NUMTEL",
                        "corpo":"$MSG"
                }
        ]
}
END

}

fn_run()
	{
	curl  -i -X POST -H 'Content-Type:application/json' -d@$JSON_SMS http://127.0.0.1:3000/api/sendSMS

	curl  -i -X POST -H 'Content-Type:application/json' -d@$JSON_EMAIL http://127.0.0.1:3000/api/sendEmail
	}

# mail
fn_make_mail_body
fn_run
