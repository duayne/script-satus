#!/bin/bash
#
#
#####################################################
#												   	#
#	 	   SCRIP DE INSTALACAO DO TOMCAT		   	#
#													#
# Desenvolvido:  Duayne Christofher dos Santos		#
# E-mail: duayne.santos@satussistemas.com.br		#
# Data de Criação: 31/05/2016						#
# 													#
#####################################################

#INSTALACAO NO DEBIAN E UBUNTU.
# para a instalacao no ubuntu tera que usar o comando "sudo su" antes da execucao do script


#===================================================================#
#						Variaveis de ambiente						#
#===================================================================#

TOMCAT=apache-tomcat-9.0.0.M6.tar.gz
LOG=/var/log/satusweb.log
DATA=`date +%d/%m/%Y--%H:%M`
INTERVALO=4
COPIA=1


#===================================================================#
#				       Verificações de Usuário						#
#===================================================================#

if [[ $USER -ne root  ]]; then
	su - > /dev/null 2&>1
	if [[ $? = 0 ]]; then
		echo "$DATA ====Usuario Alterado para Root====" >> $LOG
	else 
		echo "$DATA ====Nao foi possivel alter o usuario para Root====" >> $LOG
		echo "Não foi possivel se logar como root"
		sleep 2
		exit
	fi
fi


#===================================================================#
#						Downloads Nessesários						#
#===================================================================#


apt-get update && apt-get install dialog

dialog --backtitle "Satus - Instalador Web" --msgbox "Olá, bem vindo ao instalador de aplicação web da Satus, nessa função vamos fazer todas a instações, configuração e verificação nessesária para o Perfeito funcionameto da aplicação." 0 0


echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list > /dev/null 2&>1
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list > /dev/null 2&>1

if [ $? -eq 0 ]; then
	echo "$DATA ====Criado a Source.list.d com o Repositório do Java====" >> $LOG
else
	echo "$DATA ====Não foi possivel criar a Source.list.d com o Repositorio do Java====" >> $LOG
	dialog --backtitle "Satus - Instalador Web" --infobox "Não foi possivel criar a Source.list.d com o Repositório do Java" 0 0
	sleep 2
	exit
fi

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 > /dev/null 2&>1

if [ $? -eq 0 ]; then
	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections > /dev/null 2&>1
	if [ $? -eq 0 ]; then
		echo "$DATA ====Criado a chave do Repositório e incluido o debconf as confirmações nessesária====" >> $LOG
	else
		echo "$DATA ====Não foi possivel incluir no debconf as confirmações nessesária====" >> $LOG
		dialog --backtitle "Satus - Instalador Web" --infobox "Não foi possivel incluir no debconf as confirmações nessesária" 0 0
		sleep 2
		exit	
	fi
else
	echo "$DATA ====Não foi possivel adicionar a chave do repositório====" >> $LOG
	dialog --backtitle "Satus - Instalador Web" --infobox "Não foi possivel adicionar a chave do repositório" 0 0
	sleep 2
	exit
fi

if [[ $? = 0 ]]; then
	dialog --backtitle "Satus - Instalador Web" --infobox "Vamos Começar a fazer os Downloads Nessesários esse processo pode levar alguns minutos..." 0 0
	apt-get update  2>&1 > /dev/null && apt-get install oracle-java8-installer oracle-java8-set-default -y 2>&1 > /dev/null
	if [[ $? = 0 ]]; then
		echo "$DATA ====Java instalador com Sucesso====" >> $LOG
	else
		echo "$DATA ====Nao foi possivel instalar o Java====" >> $LOG
		dialog --backtitle "Satus - Instalador Web" --infobox "Nao foi possivel instalar o Java" 0 0
		exit
	fi
else
	echo "$DATA ====Nao foi possivel incluir o Repositorio do Java no APT====" >> $LOG
	dialog --backtitle "Satus - Instalador Web" --infobox "Nao foi possivel incluir o Repositorio do Java no APT" 0 0
	exit
fi

if [ $? -eq 0 ]; then 
	dialog --backtitle "Satus - Instalador Web" --infobox "O Java foi instalado com sucesso!!! aguarde, agora vamos fazer a instalação do SatusWEB" 0 0
	sleep 2
	cd /opt
	
	wget -b http://www.us.apache.org/dist/tomcat/tomcat-9/v9.0.0.M6/bin/$TOMCAT > /dev/null 2&>1
	while true
  	do
		if [ -e $TOMCAT ]; then
                 break
        fi
    done
 
 	TOTAL=$(cat wget-log | head -5 | tail -1 | cut -d " " -f2)
 
 	 while [[ $COPIA -lt $TOTAL ]] 
 	 do 
        PORCENTAGEM=$(($COPIA*100/$TOTAL))
        sleep $INTERVALO
        echo $PORCENTAGEM | dialog --backtitle "Satus - Instalador Web" --title "Download SatusWEB" --gauge "Realizando o Download do SatusWEB" 8 40 0
        COPIA=$(ls -l $TOMCAT | cut -d " " -f 5)
 	done
else
	dialog --backtitle "Satus - Instalador Web" --infobox "Não foi possivel fazer o download e a instalação do SatusWEB" 0 0
	echo "$DATA ====Não foi possivel fazer o download e a instalação do SatusWEB====" >> $LOG
fi


#===================================================================#
#						Configurações Necessarias					#
#===================================================================#

if [ -e $TOMCAT ]; then
	tar xf $TOMCAT 
	echo "$DATA --------------Descompactacao realizado com sucesso-------------" >> $LOG
else
	exit
	echo "$DATA --------------Nao foi passivel encontrar o arquivo $TOMCAT-------------" >> $LOG
fi

if [[ -d apache-tomcat-9.0.0.M6 ]]; then
	mv apache-tomcat-9.0.0.M6 tomcat9
	echo "$DATA --------------Renomeando a pasta para TomCat-------------" >> $LOG
else
	exit	
	echo "$DATA --------------Nao foi passivel encontrar o arquivo $TOMCAT-------------" >> $LOG
fi


echo "---------------------------------------------------------------------------------------------"

echo "O TomCat foi instalado com sucesso, mais ainda nao acabou vamos realizar os parametros aguarde!!!"
sleep 3

echo "---------------------------------------------------------------------------------------------"





echo "export CATALINA_HOME="/opt/tomcat9"" >> /etc/environment
echo "export JAVA_HOME="/usr/lib/jvm/java-8-oracle"" >> /etc/environment
echo "export JRE_HOME="/usr/lib/jvm/java-8-oracle/jre"" >> /etc/environment
echo "export JAVA_TOOL_OPTIONS='-Dfile.encoding="UTF8"'" >> /etc/profile.local


echo "$DATA --------------Criado Variaveis de Ambiente para o funcionamento do TomCat-------------" >> $LOG

source ~/.bashrc
source /etc/profile.local

echo "<rolename="manager-gui"/>" >> /opt/tomcat9/conf/tomcat-users.xml
echo "   <role rolename="admin-gui"/>" >> /opt/tomcat9/conf/tomcat-users.xml
echo "   <user username="tomcat" password="tomcat" roles="manager-gui,admin-gui"/>" >> /opt/tomcat9/conf/tomcat-users.xml

echo "$DATA --------------Configurado os parametros para o funcionamento do TomCat-------------" >> $LOG

cd -
cp ./tomcat9 /etc/init.d/satusweb

chmod +x /etc/init.d/satusweb

update-rc.d satusweb defaults

service satusweb start


if [[ $? = 0 ]]; then
	echo "$DATA --------------Servico iniciado com sucesso-------------" >> $LOG
else
	echo "$DATA --------------Nao foi possivel iniciar o servico-------------" >> $LOG
fi

echo "---------------------------------------------------------------"
echo "Parabens o Apache TomCat e o Java estao instalado, aproveite!!!"
echo "---------------------------------------------------------------"
exit	
