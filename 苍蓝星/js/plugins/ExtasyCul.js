/*---------------------------------------------------------------------------*
 * 2020/01/7 shimo8
 *---------------------------------------------------------------------------*/

/*:
 * @plugindesc 快感値計算機
 * @author しもや
 * @help
 * ・プラグインコマンド
 *   ExtasyCul 部位ID 行為補正 威力補正 固定值补正
 */



(function(){
    const _Game_Interpreter_pluginCommand = Game_Interpreter.prototype.pluginCommand;
    Game_Interpreter.prototype.pluginCommand = function(command, args) {
      _Game_Interpreter_pluginCommand.call(this, command, args);
      if (command === 'ExtasyCul') {
            //プラグイン値
            var ExtasyType = args[0]
            //args[1]行為による補正
            if(args[1] != null){
                var PlayCorrect = Number(args[1])
            }else{var PlayCorrect = 1};
            //args[2]エロ威力補正
            if(args[2] != null){
                if (args[2].match(/\\v/)) {//変数を含む場合の処理
                    array = args[2].match(/[0-9]+\.?[0-9]*/g);
                    for(var i = 0; i < array.length; i++) {//戦闘の場合自動加算したい？
                        args[2] = Number(array);
                        var EroTechnic = $gameVariables.value(args[2]);
                    }
                }else{
                    var EroTechnic = Number(args[2])
                }
            }else{var EroTechnic = 1};
            if(args[3] != null){
                var PlayFix = Number(args[3])
            }else{var PlayFix = 0};			

            //各パラメータ定義
            var ExtasyPointTotal = 0//最終合計値
            var CulExtasyPoint = 0 //計算合計値
            var CulExtasyPointB = 0 //補正計算値
            var Estrus = $gameVariables.value(1027) //現在発情値 
            var AddEstrus  = 0//発情値加算用
            var ExtasyPart = 0 //部位感度(開発度)
            var Critical = 0 //部位の基礎会心一击率
            var BaseExtasy = 0 //部位の基礎感度
            var CrPointBase = 0//会心一击加算値
            var CrCorrect = 50//会心一击補正値(パーセント)
            var RangeNum = 40//乱数範囲
			var PartTole = $gameVariables.value(1098) //部位耐性
			var bodyRatio = 1; //体质增幅

            //開発度代入基礎感度は　行為判定にしてしまう？
            if(ExtasyType == "Mouth"){
                ExtasyPart = $gameVariables.value(1102);
                Critical = 0 + $gameActors.actor(1).isLearnedSkill(961) * 50;
                BaseExtasy = 1;
				bodyRatio += $gameVariables.value(1231) / 100;
				PartTole -= $gameActors.actor(1).EXT.mouth;
				$gameActors.actor(1).EXT.mouth += Math.floor(Math.random()*3) + 2;
				if($gameActors.actor(1).EXT.mouth > 100 - $gameVariables.value(1098)) $gameActors.actor(1).EXT.mouth = 100 - $gameVariables.value(1098);
				if($gameActors.actor(1).isLearnedSkill(825)) $gameVariables._data[2027] += 5;
				else if($gameActors.actor(1).isLearnedSkill(824)) $gameVariables._data[2027] += 2;
            }
            else if(ExtasyType == "Nipple"){
                ExtasyPart = $gameVariables.value(1103);
                Critical = 10 + $gameActors.actor(1).isLearnedSkill(962) * 50;
                BaseExtasy = 2;
				PartTole -= $gameActors.actor(1).EXT.nipple;
				$gameActors.actor(1).EXT.nipple += Math.floor(Math.random()*3) + 2;
				if($gameActors.actor(1).EXT.nipple > 100 - $gameVariables.value(1098)) $gameActors.actor(1).EXT.nipple = 100 - $gameVariables.value(1098);			
            }
            else if(ExtasyType == "Clit"){
                ExtasyPart = $gameVariables.value(1104);
                Critical = 10 + $gameActors.actor(1).isLearnedSkill(963) * 50;
                BaseExtasy = 2;
				PartTole -= $gameActors.actor(1).EXT.clit;
				$gameActors.actor(1).EXT.clit += Math.floor(Math.random()*3) + 2;
				if($gameActors.actor(1).EXT.clit > 100 - $gameVariables.value(1098)) $gameActors.actor(1).EXT.clit = 100 - $gameVariables.value(1098);			
            }
            else if(ExtasyType == "Vagina"){
                ExtasyPart = $gameVariables.value(1106);
                Critical = 10 + $gameActors.actor(1).isLearnedSkill(964) * 50;
                BaseExtasy = 2;
				bodyRatio += $gameVariables.value(1232) / 100;
				PartTole -= $gameActors.actor(1).EXT.vagina - 25;
				if($gameActors.actor(1).isStateAffected(41) || $gameActors.actor(1).isStateAffected(37)) PartTole -= 50;
				$gameActors.actor(1).EXT.vagina += Math.floor(Math.random()*3) + 2;
				if($gameActors.actor(1).EXT.vagina > 100 - $gameVariables.value(1098)) $gameActors.actor(1).EXT.vagina = 100 - $gameVariables.value(1098);		
            }
            else if(ExtasyType == "Anus"){
                ExtasyPart = $gameVariables.value(1105) * 1.25;
                Critical = 0 + $gameActors.actor(1).isLearnedSkill(965) * 50;
                BaseExtasy = -0.25;
				bodyRatio += $gameVariables.value(1233) / 100;
				PartTole -= $gameActors.actor(1).EXT.anus - 25;
				if($gameActors.actor(1).isStateAffected(38)) PartTole -= 50;
				$gameActors.actor(1).EXT.anus += Math.floor(Math.random()*3) + 2;
				if($gameActors.actor(1).EXT.anus > 100 - $gameVariables.value(1098)) $gameActors.actor(1).EXT.anus = 100 - $gameVariables.value(1098);				
            }
            else if(ExtasyType == "Hip"){
                ExtasyPart = $gameVariables.value(1105);
                Critical = 5;
                BaseExtasy = 2;
            }
            else if(ExtasyType == "Shame"){
                ExtasyPart = $gameVariables.value(1110);
                Critical = 0;
                BaseExtasy = 0;
            }
            else if(ExtasyType == "Semen"){
                ExtasyPart = $gameVariables.value(1111);
                Critical = 0;
                BaseExtasy = 0;
				$gameSwitches._data[2901] = false;
				$gameSwitches._data[2902] = false;
				return;
            }
            else if(ExtasyType == "Maso"){
                ExtasyPart = $gameVariables.value(1112);
                Critical = 0;
                BaseExtasy = 0;
            }
            else if(ExtasyType == "Service"){
                ExtasyPart = $gameVariables.value(1102);
                Critical = 0 + $gameActors.actor(1).isLearnedSkill(961) * 50;
                BaseExtasy = -0.5;
				bodyRatio += $gameVariables.value(1234) / 100;
				PartTole -= $gameActors.actor(1).EXT.mouth;
				$gameActors.actor(1).EXT.mouth += Math.floor(Math.random()*3) + 2;
				if($gameActors.actor(1).EXT.mouth > 100 - $gameVariables.value(1098)) $gameActors.actor(1).EXT.mouth = 100 - $gameVariables.value(1098);
				if($gameActors.actor(1).isLearnedSkill(841)) $gameVariables._data[2027] += 5;
				else if($gameActors.actor(1).isLearnedSkill(840)) $gameVariables._data[2027] += 2;
            }
            else if(ExtasyType == "Pervert"){
                ExtasyPart = $gameVariables.value(1114);
                Critical = 0;
                BaseExtasy = 0;
            }
            else if(ExtasyType == "Direct"){
                    ExtasyPart = 0;
                    Critical = 0;
                    BaseExtasy = 0;
					PartTole = $gameVariables.value(1094);
            }else{
                ExtasyPart = 0;
                Critical = 0;
                BaseExtasy = 0;
				$gameSwitches._data[2901] = false;
				$gameSwitches._data[2902] = false;
				return;
            }



            //行為による快感補正が足りない？
            //計算開始
            CulExtasyPoint += BaseExtasy //基礎感度を加算
            CulExtasyPoint += ExtasyPart //部位感度を加算
            CulExtasyPointB += PlayCorrect //部位感度を加算
            CulExtasyPointB += EroTechnic //部位感度を加算
			CulExtasyPointB += $gameVariables.value(4878) * 5;
            CulExtasyPoint *= CulExtasyPointB
			CulExtasyPoint += PlayFix
            if(ExtasyType == "Direct"){CulExtasyPoint += EroTechnic}//ダイレクトの場合、エロ威力そのまま入力



            //発情補正 発情値パーセント分の快感度を加算
            AddEstrus = CulExtasyPoint
            AddEstrus *= Estrus
            AddEstrus /= 200//係数  

            //会心一击計算
            var CriticalPart = ExtasyPart * 5;
            Critical += CriticalPart;////部位感度の5倍の値を基本値に加算
			if($gameSwitches.value(2924)){//快感暴击率补正
				Critical += 50;
				$gameSwitches._data[2924] = false;
			}
            var CriticalRandom = Math.floor(Math.random() * (101-1)+1);//1-100のランダム値
            if (Critical >= CriticalRandom) {//割合加算
                CrPointBase = CulExtasyPoint
                CrPointBase *= CrCorrect
                CrPointBase /= 100
			}
                
			//補正値加算
            CulExtasyPoint += AddEstrus //発情加算
            CulExtasyPoint += CrPointBase //会心一击加算
			CulExtasyPoint *= bodyRatio//体质乘算


            //範囲乱数化
            var BaseNum = CulExtasyPoint
            var Cul = 0
            BaseNum *= RangeNum
            BaseNum /= 100
            max = BaseNum;
            var RangeRandom = Math.floor( Math.random() * max ) ;
            Cul = RangeRandom
            if (Math.random() > 0.5){//加算か減算ランダム
                CulExtasyPoint += Cul;
            }else{
                CulExtasyPoint -= Cul;
            }

            //最終値を加算
            ExtasyPointTotal = Math.floor(CulExtasyPoint - CulExtasyPoint * PartTole / 100);
			if(ExtasyPointTotal < 1) ExtasyPointTotal = 1;
			if(ExtasyPointTotal > $gameVariables.value(1159)){
				$gameVariables._data[1159] = ExtasyPointTotal;
				$gameVariables._data[4877] = 0;
			}
			$gameVariables._data[1026] += ExtasyPointTotal
			$gameVariables._data[4992] = ExtasyPointTotal			
			$gameVariables._data[411] -= ExtasyPointTotal / 2
			if(CrPointBase > 0){
				TickerManager.show(`\\i[892]\\c[27]会心一击`);
				$gameScreen.startFlash([255,255,255,100], 20);}
			if(ExtasyPointTotal > 0) TickerManager.show(`\\i[3582]\\c[27]快感值 \\V[4992]`);
			

            $gameVariables._data[414] += ExtasyPointTotal;
			//关闭战斗技能
			$gameSwitches._data[2901] = false;
			$gameSwitches._data[2902] = false;

			if($gameParty.inBattle()){
				this.setupChild($dataCommonEvents[167].list, 0)
			}else{
				$gameSwitches._data[2921] = true;
			}
			
        }
    }
})();