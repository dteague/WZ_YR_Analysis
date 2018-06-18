#################################
######### INPUT VARIABLES #######
#################################

work_dir=WZ_delphes
scratch=/nfs_scratch/dteague
splitting=300
input_file=Pol_WZ_decayed.lhe
submit_dir=submit

#################################
#################################

if [ ! -d $scratch/$work_dir ]; then
    mkdir $scratch/$work_dir
fi

info=$(voms-proxy-info |  awk '{if($1=="timeleft" && $3 != "0:00:00")print $3}')
if [ -z $info ]; then
    voms-proxy-init
fi
cp $(voms-proxy-info -path) $scratch/$work_dir/userproxy

if [ ! -d $scratch/$work_dir/split_files ]; then
    mkdir $scratch/$work_dir/split_files
fi
rm -f $scratch/$work_dir/split_files/*


run_events=$(grep -m 1 "Number of Events" $input_file | awk '{print $NF}')
run_events=$[ $run_events / $splitting ]
sed 's/NUMBER_EVENTS/'$run_events'/g' < $submit_dir/configLHE.cmnd > $scratch/$work_dir/configLHE.cmnd

cp submit_dir/wraper.sh $scratch/$work_dir/wraper.sh
sed "s/SPLITTING/$splitting/g" <submit_dir/submit.condor > $scratch/$work_dir/submit.condor

if [ ! -d $scratch/$work_dir/results ]; then
    mkdir $scratch/$work_dir/results
fi
#rm -f $scratch/$work_dir/results/*

echo "Do you wish to run the Splitting program?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) python lhe_splitter.py $input_file $splitting $scratch/$work_dir; break;;
        No ) break;;
    esac
done


echo "cd $scratch/$work_dir"
