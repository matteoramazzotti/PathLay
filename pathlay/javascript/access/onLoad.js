document.addEventListener('DOMContentLoaded', function() {
    
    document.getElementById("div_statistic").style.display = "none";
    document.getElementById('div_exec_buttons').style.display = "none";

    document.getElementById('load_exp_button').addEventListener('click', function(){
		document.getElementById('div_statistic').style.display = "block";
		document.getElementById('div_exec_buttons').style.display = "block";
	},false)

    document.getElementById('exp_select').addEventListener('change', function(){
		document.getElementById('div_statistic').style.display = "none";
		document.getElementById('div_exec_buttons').style.display = "none";
        currentPreview.initCounters();
        currentPreview.reset();
	},false)

    //document.getElementById("main_submit").addEventListener('click', function(){
	//	if (!document.getElementById('accessReportDiv')) {
	//		newSubmit();
	//	}
	//},false)

    document.getElementById("maps_db_select").addEventListener('change',function() {
        currentConf.updateMapsDB();
        checksOnCurrent.checkSubmit();
    } ,false)

    for (let dataType of dataTypes) {
        document.getElementById(`enable${dataType}`).addEventListener('click', function(){
            currentConf.updateEnabler(dataType);
            dynamicChecks()
        },false)
        document.getElementById(`${dataType}LeftEffectSizeCheck`).addEventListener('click', function(){
            currentConf.updateLeftCheck(dataType);
            dynamicChecks()
        },false)

        document.getElementById(`statistic_select`).addEventListener('change', function(){
            currentConf.updateStatisticEnabled();
            dynamicChecks()
        },false)

        document.getElementById(`${dataType}FETEnabled`).addEventListener('click', function(){
            currentConf.updateStatisticEnablers(dataType);
            checksOnCurrent.checkSubmit();
        },false)

        document.getElementById(`${dataType}RightEffectSizeCheck`).addEventListener('click', function(){
            currentConf.updateRightCheck(dataType);
            dynamicChecks()
        },false)
        document.getElementById(`${dataType}pValCheck`).addEventListener('click', function(){
            currentConf.updatepValCheck(dataType);
            dynamicChecks()
        },false)

        document.getElementById(`${dataType}IdOnlyCheck`).addEventListener('click', function(){
            currentConf.updateIdOnlyCheck(dataType);
        },false)

        document.getElementById(`${dataType}LeftThreshold`).addEventListener('change',function(){
            currentConf.updateLeftThresholdValue(dataType);
            dynamicChecks()
        },false)
        document.getElementById(`${dataType}RightThreshold`).addEventListener('change',function(){
            currentConf.updateRightThresholdValue(dataType);
            dynamicChecks()
        },false)
        document.getElementById(`${dataType}pValThreshold`).addEventListener('change',function(){
            currentConf.updatepValThresholdValue(dataType);
            dynamicChecks()
        },false)


        if (document.getElementById(`enabletfs_${dataType}`)) {
            document.getElementById(`enabletfs_${dataType}`).addEventListener('click', function(){
                currentConf.updateTfCheck(dataType);
                checksOnCurrent.checkSubmit();
            },false)
        }
        if (document.getElementById(`nodeg_select_tf_${dataType}`)) {
            document.getElementById(`nodeg_select_tf_${dataType}`).addEventListener('click', function(){
                currentConf.updateTfIdOnlyCheck(dataType);
                checksOnCurrent.checkSubmit();
            },false)
        }
        if (document.getElementById(`${dataType}NoDEFromIdOnlyCheck`)) {
            document.getElementById(`${dataType}NoDEFromIdOnlyCheck`).addEventListener('click', function(){
                currentConf.updateNoDeFromIdOnlyCheck(dataType);
                checksOnCurrent.checkSubmit();
            },false)
        }
        if (document.getElementById(`nodeg_select_${dataType}`)) {
            document.getElementById(`nodeg_select_${dataType}`).addEventListener('click', function(){
                currentConf.updateNoDeCheck(dataType);
                checksOnCurrent.checkSubmit();
            },false)
        }
    }
},false);