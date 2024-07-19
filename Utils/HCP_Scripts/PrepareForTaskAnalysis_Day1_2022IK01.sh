#!/bin/bash 

SubjectList="KS041SS"
TaskNameList=""
TaskNameList="${TaskNameList} MOTOR"

DirectionList=""
DirectionList="${DirectionList} 1_PA"
DirectionList="${DirectionList} 2_PA"

StudyFolder="/home/ikimura/work/VIDA_2021IK04/qps5" # or qps50

for subject in ${SubjectList}
do
	
	for task in ${TaskNameList} 
	do
		
		for direction in ${DirectionList}
		do

			# Prepare for Level 1

			./generate_level1_fsf.sh \
				--studyfolder=${StudyFolder} \
				--subject=${subject} \
				--taskname=${task}${direction} \
				--templatedir=../fsf_template \
				--outdir=${StudyFolder}/${subject}/MNINonLinear/Results/${task}${direction}

			#./copy_evs_into_results.sh \
			#	--studyfolder=${StudyFolder} \
			#	--subject=${subject} \
			#	--taskname=${task}${direction}

		done

		# Prepare for Level 2

		mkdir -p ${StudyFolder}/${subject}/MNINonLinear/Results/${task}
		cp -v ../fsf_template/${task}_hp160_s4_level2.fsf ${StudyFolder}/${subject}/MNINonLinear/Results/${task}

	done

done
