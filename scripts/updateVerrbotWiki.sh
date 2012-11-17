cd /home/stefan/eggdrop1/data
sed -e "/^ *$/d" ./learn.dat > ./foo.dat
rm learn.dat
mv foo.dat learn.dat
 
cd /home/stefan/pywiki
python postSH.py -sh:./pipeDef.sh Benutzer:Verrbot/Definitionen/Data > /dev/null 2>&1 &
